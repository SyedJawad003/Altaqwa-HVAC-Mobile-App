# Spec: Fix Site-Issue Permission Error + Admin Technicians Panel

## Problem

The Al Taqwa Flutter app has two user-visible issues:

1. **Persistent PERMISSION_DENIED on technician site submission** — even after firestore.rules updates, when a technician taps "Send Details to Supervisor" on the Share Site Details screen, the red error banner still shows:
   > `Error sharing site details: [cloud_firestore/permission-denied] PERMISSION_DENIED: Missing or insufficient permissions.`
   Root cause diagnosis (from code inspection): the `site_issue` write and booking update succeed, but the trailing `_notifySupervisors()` call inside `shareSiteDetails()` writes to the `notifications` collection using the rule `allow create: if isAdmin() || isSupervisor() || isTechnician()`. The `isTechnician()` helper requires a doc at `/technicians/<uid>`. If the technician was assigned by name only (no matching `technicians/<auth-uid>` doc) or their profile is missing from the `technicians` collection entirely, the notification write fails with PERMISSION_DENIED. Because this happens **after** the site_issue doc was saved (and is inside a regular `await`, not a try/catch), the whole `shareSiteDetails()` Future throws and the UI reports the entire operation as failed. This makes technicians think their photos and notes were never saved.

2. **Admin "Technicians" menu item is a placeholder** — the Admin Navigation Drawer currently shows a Technicians entry (line 124 of `admin_navigation_drawer.dart`) via `_menuItem(...)` which only shows a snack bar "Technicians section is ready for the next admin module." The user explicitly wants a **fully working Admin Technicians panel** that shows all registered technicians and their details.

## Users / Stakeholders

- **Technicians** — submit site photos and notes (need PERMISSION_DENIED fixed, actually know when submit succeeded).
- **Admins** — manage the workforce; need a Technicians screen listing all registered technicians with profile fields, job counts, availability/status indicators; also need to be able to quickly navigate from technician → assigned requests.
- **Supervisors** — (indirectly) benefit because technician site details reliably flow into the existing supervisor view now that notifications don't throw.
- **Customers** — (indirectly) benefit from faster, reliable technician site inspections.

## Goals

- AC-G1: Technician taps submit → **green success snack bar** when site_issue doc is saved, regardless of notification failures.
- AC-G2: Admin drawer → Technicians entry opens a real, data-driven **Admin Technicians Panel** listing every registered technician from `/technicians/*` with full details.
- AC-G3: No compile errors; `flutter analyze` reports zero issues in modified/new files; `GetDiagnostics` returns `[]`.
- AC-G4: Existing functionality (supervisor review, admin requests, PDF quotations) must not regress.

## Non-Goals

- NOT building a create/edit technician form in the admin panel in this change — admins view the list + details, account creation still goes through the registration screen. (Quick availability toggle is in-scope.)
- NOT changing Firebase Storage strategy for photos (keep base64 inline per existing project convention).
- NOT rewriting admin dashboard or supervisor screens beyond what's needed to wire the new technicians screen into navigation.
- NOT deploying Firestore rules from the IDE environment. Rules file is updated; user runs `firebase deploy --only firestore:rules` separately.

## Functional Requirements

### FR-1: Robust site_issue submission (no false failures)

- `BookingService.shareSiteDetails()` must save to `site_issue/<requestId>` and update the `customer_service_requests/<requestId>` booking document (mirror + timeline).
- Any step AFTER the critical two writes (site_issue write + booking update) MUST NOT throw and prevent user success. Specifically:
  - Writing to the legacy `customer_site_details/<requestId>` remains best-effort (already wrapped in try/catch).
  - `_notifySupervisors()` call must be wrapped in a best-effort try/catch; catch silently logs or swallows (don't rethrow).
- Site-issue rules must also survive a "missing technician doc" scenario for the `notifications` collection. As a defense-in-depth rule fix, the `notifications` create rule SHALL also allow: any signed-in user creating a notification where `senderUid == request.auth.uid` (so they can always send notifications they authored, regardless of role collection membership).
- Site-issue write rules: keep existing `/site_issue` block behavior (no changes beyond what already exists).
- Technician UI snack bar success copy: "Site details successfully shared with supervisor!" (already present). On error: still show permission help tip (already present + helps debug future cases).

### FR-2: Admin Technicians Panel data sources

- Admin technicians screen SHALL read all docs from Firestore collection `/technicians` as a reactive stream (StreamBuilder).
- For each technician, enrich the list with a count of currently assigned jobs from `customer_service_requests where technicianUid == <techUid>` OR `technicianName == <tech.name>` (since assignments can be by UID or by name). Count can be per-technician `FutureBuilder` inside each list tile OR a single aggregate stream over bookings. Implementation chooses whichever avoids O(n) per-row reads on the RTDB/Firestore budget.
- Technician model fields displayed: name, email, phone, role (always 'technician'), status badge (active/inactive based on `data.status ?? 'active'`), availability chip (available / unavailable based on `data.available ?? true`), createdAt / updatedAt as formatted dates if present.

### FR-3: Admin Technicians Panel UI

- Screen scaffold: `AdminGradientAppBar` (same app bar style as CustomersScreen) with title "Technicians" and subtitle "Registered technicians and workload overview."
- Top of body: stat cards (Total technicians, Active, Available) using the same white-card + gold-CTA pattern as CustomersScreen.
- Body list: ListView.separated of technician cards. Each card shows:
  - Leading circle avatar with technician initials (fallback Icon if no name, navy background, white text)
  - Title: technician name (fontWeight.w800, navy)
  - Subtitle: email • phone
  - Chips row: Status (active green / inactive grey), Availability (if available: green "Available", else amber "On break")
  - Assigned jobs: small row with icon + count like "3 assigned jobs"
  - Optional trailing quick action: IconButton toggle for `available` switch (admin can mark technician available/unavailable inline; writes back to `/technicians/<id>` with SetOptions merge:true, only updates `available` + `updatedAt: FieldValue.serverTimestamp()`).
- Empty state: Text "No registered technicians yet." when list is empty.
- Error state: Centered Text with snapshot error like CustomersScreen pattern.
- Drawer integrated: include `const AdminNavigationDrawer()` as the scaffold Drawer.

### FR-4: Admin navigation wiring

- `AdminNavigationDrawer` line 124: replace `_menuItem(context, Icons.engineering_outlined, 'Technicians')` with a real ListTile that navigates to `AdminTechniciansScreen`.
- Keep leading `Icons.engineering_outlined` (matches the engineer / technician role visual theme), fontWeight.w700 label, navy color.
- Ensure the new screen is imported at the top of `admin_navigation_drawer.dart`.

## Non-Functional Requirements

- NFR-1 (Error resilience): optional follow-on writes (notifications, legacy collection mirror) never prevent the primary user-intent success.
- NFR-2 (Firestore rules safety): any rule relaxation must not introduce privilege escalation. Specifically, the notifications rule extension only allows self-authored notifications (`senderUid == request.auth.uid`).
- NFR-3 (No hard regressions): supervisor_job_detail and admin_requests_screen StreamBuilders for SiteDetails remain untouched.
- NFR-4 (Code quality): no TODOs or print debug statements in production code paths. Follow admin_theme / app_theme conventions.
- NFR-5 (Cost): admin technicians list uses a single StreamBuilder over `collectionGroup('technicians')` / `collection('technicians')` with appropriate ordering; avoid N+1 query patterns where possible — if per-technician job count requires one Future per row that's acceptable (low technician cardinality expected).

## Constraints

- Rules file syntax must be `rules_version = '2'`; helpers kept inside the match block as existing pattern.
- Data model in `technicians` collection: from `AuthService.saveUserProfile` we know fields: `uid, name, email, phone, role='technician', available: true, status: 'active', createdAt, updatedAt`. Admin panel must handle missing fields (use defaults).
- Assignments can be stored either as `technicianUid` (Auth UID) OR `technicianName` (free-text) on each booking request — job counting must match both paths.
- Notification audience rules must continue to gate reads (admins read all, supervisors read audience='supervisors' or direct UID, others read direct UID only). Only CREATE rule is relaxed slightly for self-authored notifications.

## Dependencies / Assumptions

- Assumes Firebase Auth + Firestore are initialized in the app (already true; BookingService constructor handles).
- Assumes Flutter dependencies `cloud_firestore`, `firebase_auth`, `flutter` with image_picker are already in `pubspec.yaml` (verified).
- Assumes admin user can already open the admin drawer (logged in as `admin@altaqwa.com` or with `/admins/<uid>` doc).
- Rules file must be deployed by user via `firebase deploy --only firestore:rules` — outside repository environment.
- Assumes bookings collection keeps same fields (`technicianUid`, `technicianName`).

## Open Questions (Answered)

- Q1: Do we need edit/delete technician actions in admin panel? A: No, out of scope for this fix (non-goal). Quick availability toggle inline is allowed as a nice-to-have if trivial.
- Q2: Does technician PERMISSION_DENIED happen during site_issue write or later? A: Code analysis traces to `_notifySupervisors()` inside shareSiteDetails AFTER successful site_issue write and booking update — wrapped notifications will fix it.
- Q3: Rules or code fix preferred? A: BOTH — defense in depth: (a) code fix (best-effort notifications) guarantees no false failure even if rules aren't deployed yet; (b) rule fix (notifications create allow senderUid match) aligns with principle of least privilege for future robustness after deploy.

## Acceptance Criteria

| ID | Type | Description | Pass Condition |
|---|---|---|---|
| AC-1 | rule | Technician submit never shows false permission error from notification write | `shareSiteDetails()` completes successfully (green snack bar) after site_issue write + booking update even when `_notifySupervisors()` internally throws PERMISSION_DENIED. |
| AC-2 | rule | Notifications firestore.rules allow self-authored creates | In firestore.rules, notifications `allow create:` includes `signedIn() && request.resource.data.senderUid == request.auth.uid`. |
| AC-3 | rule | Admin Technicians screen exists and shows list of technicians | `admin/admin_technicians_screen.dart` exists, extends Stateless/StatefulWidget, includes StreamBuilder on `technicians` collection, renders list. |
| AC-4 | rule | Admin Navigation Drawer Technicians opens new screen | `lib/admin/admin_navigation_drawer.dart` line ~124 no longer uses `_menuItem` placeholder; tapping Technicians navigates to `AdminTechniciansScreen`. |
| AC-5 | rule | Technician card displays required fields | Each list tile shows: name, email, phone, status badge (active/inactive), availability chip, assigned job count. |
| AC-6 | rule | Modified/new files have zero analyzer errors | Run `flutter analyze` → zero warning/error/info entries in files: `booking_service.dart`, `admin_navigation_drawer.dart`, `admin_technicians_screen.dart`, `firestore.rules`. (Pre-existing unrelated lints in other files OK.) |
| AC-7 | rule | GetDiagnostics returns zero issues | Run IDE diagnostics → `[]`. |
| AC-8 | rubric | End-user robustness quality | Scale 0-2: 0 = notification failure still breaks flow; 1 = notification failure swallowed but no rule-layer support; 2 = notification failure swallowed code-side AND notifications rule layer extended for self-authored sends. **Pass ≥ 2.** |
