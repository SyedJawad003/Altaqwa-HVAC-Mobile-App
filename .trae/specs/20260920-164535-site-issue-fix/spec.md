# Site Issue Collection & Permission Fix - Specification

## Problem

Technicians are encountering a `[cloud_firestore/permission-denied] PERMISSION_DENIED: Missing or insufficient permissions` error when attempting to submit site photos and details from the Share Site Details screen. Additionally, the user requires that all site photos and details be stored in a new Firestore collection named `site_issue` (replacing the current `customer_site_details`), and that these records are properly visible to supervisors and admins in their existing dashboards.

## Users

- **Technician**: Captures site photos, writes site analysis notes, and submits the site issue record.
- **Supervisor**: Reviews the submitted site details and photos to prepare cost estimates.
- **Admin**: Views site details and photos alongside request details when managing bookings and quotations.

## Goals

1. **Resolve the Firestore permission-denied error** so technicians can successfully submit site details.
2. **Migrate to the `site_issue` collection** as the authoritative store for site inspection data (photos + description + metadata).
3. **Ensure supervisors and admins can read** the submitted site data from the new collection in the existing job detail screens.
4. **Fix nested FieldValue.serverTimestamp() bug** that causes silent or explicit failures when writing the `siteDetails` map into `customer_service_requests`.
5. **Handle photo payloads robustly** (especially base64 data URLs) so that large photo payloads do not exceed Firestore document limits unexpectedly.
6. **Preserve backward compatibility**: Existing screens that read `watchSiteDetailsForRequest()` continue working without UI changes beyond data source rename.

## Non-Goals

- Rewriting the photo storage to use Firebase Cloud Storage (keeps base64/URL approach but documents limits).
- Changing the authentication or role-router flow.
- Rebuilding the site details UI from scratch; only bug fixes and wiring.
- Batch-migrating historical records from `customer_site_details` into `site_issue` (old collection remains readable as fallback only).

## Functional Requirements

### FR-1: Technician submits site issue without permission error
- Given a technician is signed in and assigned to a booking,
- When the technician fills in site notes or adds at least one photo and taps "Send Details to Supervisor",
- Then the submission completes without a `permission-denied` Firestore error.

### FR-2: Data stored in `site_issue` collection
- Each successful submission writes one document in the `site_issue` Firestore collection.
- The document ID equals the booking `requestId` (1:1 with booking).
- The document MUST contain the following fields:
  - `requestId`: string reference to `customer_service_requests`
  - `description`: string (site analysis/notes)
  - `photoUrls`: list of strings (URLs or base64 data URLs)
  - `technicianName`: string
  - `technicianUid`: string
  - `customerName`: string
  - `serviceName`: string
  - `sharedAt`: timestamp (when site issue was submitted)
  - `status`: string, default `'pending_review'`
  - `createdAt`: timestamp (server)
  - `updatedAt`: timestamp (server)

### FR-3: Booking document mirror (soft copy)
- After writing `site_issue`, the `customer_service_requests` document is updated with a clean (server-timestamp-free) copy of the site issue data under the field `siteDetails` and a timeline event `site_inspected`.
- This mirror update must not use `FieldValue.serverTimestamp()` inside nested maps/arrays; instead use `Timestamp.now()` (client time) for nested timestamps, or store server timestamps only at the top level of the booking document.

### FR-4: Read access for supervisors and admins
- In the supervisor job detail screen, `watchSiteDetailsForRequest(requestId)` returns the latest site issue for a booking, preferring the new `site_issue` collection, with a fallback to the booking's embedded `siteDetails` for compatibility.
- In the admin request details screen, site details are rendered the same way as they were before but sourced from `site_issue` when present.
- Read access is permitted for the owning technician, any supervisor, any admin, and the customer owner of the request.

### FR-5: Write access (Firestore rules)
- Create: admin OR supervisor OR technician (signed-in technician who exists in the `technicians` collection or matches the `technicianUid` on the request OR is listed as `technicianName` in `technicians`).
- Update: admin OR supervisor OR the owning technician.
- Read: admin OR supervisor OR the owning technician OR the technician assigned to the related request OR the customer who owns the request.
- Delete: admin only.

### FR-6: Robust error handling and validation
- Client-side validation: at least one photo or a non-empty description is required before submission.
- Photo payload size guard: warn/error if total encoded payload exceeds ~800KB (to keep well under Firestore 1MB doc limit).
- Errors (including permission-denied, quota exceeded, payload-too-large) are surfaced to the technician in an actionable snack bar with the raw error text preserved for debugging.

### FR-7: Notifications
- After a successful site issue submission, create a notification with `audience: 'supervisors'` so supervisors see the "Site details received" event, matching the existing `_notifySupervisors` pattern.

## Non-Functional Requirements

### NFR-1: Security
- No hard-coded secrets.
- Firestore security rules for `site_issue` follow the same role-based pattern as `customer_site_details` and `job_issues`.
- Technicians can only create/update `site_issue` documents for bookings they are actually assigned to.

### NFR-2: Maintainability
- Collection name is defined as a single constant in `booking_service.dart` (so future renames are one-line changes).
- Read methods prefer the new collection but fall back to embedded data for backward compatibility with any records already embedded on bookings.

### NFR-3: Performance
- Watch streams return the document snapshot directly from Firestore listeners (no re-fetch on every build).
- Site issue document size is kept small by warning on oversized photo payloads.

## Constraints, Dependencies, Assumptions

- **Constraint**: The project uses `cloud_firestore: ^6.8.0` with Flutter 3.13 SDK; no new packages beyond what is in `pubspec.yaml`.
- **Constraint**: Photos are base64-encoded data URLs or URLs; Firebase Storage is not configured in the current project, so we must not add Storage uploads.
- **Dependency**: The existing `SiteDetails` data class is reused with `status`, `createdAt`, and `updatedAt` optional fields to fit the `site_issue` schema.
- **Assumption**: Technician records are stored in the `technicians` Firestore collection with at least `uid`, `name`, `email`, `phone`; technicians that are correctly assigned by `technicianUid` in the booking should pass rules even if some fields are missing.
- **Assumption**: User (customer) bookings store `customerUid` to allow customer read access if ever needed.

## Open Questions

1. Should technicians be allowed to *update* a site issue after submission (e.g., to add more photos)? Current design says yes (owning technician can update).
2. Should a second submission for the same booking overwrite or create a new site issue doc? Design keeps 1:1 (set with merge), so edits overwrite.

## Acceptance Criteria

### Rule AC-1
Technician taps "Send Details to Supervisor" on Share Site Details screen with at least 1 photo or description, and the result is a success snack bar ("Site details successfully shared with supervisor!") with no permission-denied error.

**Evidence**: Reproduce the flow with a technician account and inspect Firestore; `site_issue/<requestId>` document exists, and `customer_service_requests/<requestId>` has `siteDetails` populated plus a `site_inspected` timeline entry.

### Rule AC-2
Firestore rules for `site_issue` allow the correct roles and reject unauthenticated / unauthorized access.

**Evidence**: Unit of rule verification via emulator or at minimum the rules file contains match block for `/site_issue/{issueId}` with proper role checks matching NFR-1; test read/write behavior manually against dev project after deploy.

### Rule AC-3
Supervisor opens the job detail page for a booking that has a submitted site issue and can see the technician name, description, and all photos (tapping opens full-screen view).

**Evidence**: Screen renders `Site Analysis & Inspection` panel populated with data visible on device.

### Rule AC-4
Admin opens the Request Details page for a booking that has a submitted site issue and can see the "Site Inspection Details" card with description and photos.

**Evidence**: Admin UI renders the site details card; clicking a photo opens the interactive full-screen image dialog without error.

### Rule AC-5
`flutter analyze` completes with zero new errors (or pre-existing only) in the modified files.

**Evidence**: Run `flutter analyze` from project root; output shows no issues in `booking_service.dart`, `share_site_details_screen.dart`, `technician_dashboard_screen.dart`, `supervisor_job_detail.dart`, `admin_requests_screen.dart`.

### Rubric AC-6 (Payload robustness, 0-2)
- `2`: Client-side prevents submission if total photo payload exceeds safe Firestore size and shows a friendly "Too many / too large photos – remove or reduce quality" message with guidance.
- `1`: Payload is unchecked but at least error is shown if Firestore rejects due to size (no silent failure).
- `0`: Oversized payloads cause silent failures or uncatchable crashes.
**Pass threshold**: 1 or better.

### Rule AC-7
No `FieldValue.serverTimestamp()` is used inside any array element or nested map (e.g. inside `siteDetails`, inside `timeline` events). Only top-level document fields or explicitly safe positions use `FieldValue.serverTimestamp()`; nested `at:` fields use `Timestamp.now()`.

**Evidence**: Grep `booking_service.dart` shows no `FieldValue.serverTimestamp()` inside the inline `timeline` event maps or inside any payload map that becomes a nested document/map field; uses `Timestamp.now()` for nested times.
