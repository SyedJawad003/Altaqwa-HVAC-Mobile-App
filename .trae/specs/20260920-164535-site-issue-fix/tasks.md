# Implementation Tasks - Site Issue Fix

Parent spec: [spec.md](./spec.md)

## Task 1: Update Firestore Security Rules

**Priority**: high
**Status**: pending
**Acceptance Criteria covered**: AC-1, AC-2
**Dependencies**: None (first task)

### Work
- In `firestore.rules`, add a new `match /site_issue/{issueId}` block with full CRUD permission rules:
  - Helper functions: `issueBelongsToTechnician()`, `issueRequestAssignedToTechnician()`, `issueRequestBelongsToCustomer()`.
  - `allow read`: if `isAdmin() || isSupervisor() || issueBelongsToTechnician() || issueRequestAssignedToTechnician() || issueRequestBelongsToCustomer()`.
  - `allow create`: if `isAdmin() || isSupervisor() || (isTechnician() && request.resource.data.technicianUid == request.auth.uid)`.
  - Also allow create for technicians assigned to the request by name match (as existing `isAssignedTechnician` pattern).
  - `allow update`: if `isAdmin() || isSupervisor() || (signedIn() && resource.data.technicianUid == request.auth.uid)`.
  - `allow delete`: if `isAdmin()`.
- Robustness: Keep existing `customer_site_details` rules unchanged for backward read compatibility; only add new `site_issue` block.
- Ensure `isTechnician()` helper fallback handles assignments by name as in `isAssignedTechnician()`.

### Local Test Requirements
- **Rule TR-1 (rule)**: The rules file must parse without syntax errors. Evidence: `firebase deploy --only firestore:rules --dry-run` equivalent sanity (or at minimum: inspect file syntax with balanced braces, correct `rules_version='2'` block preserved).
- **Rule TR-2 (rule)**: `/site_issue/{issueId}` match block exists and contains `allow read`, `allow create`, `allow update`, `allow delete` declarations. Evidence: grep file for each verb.

---

## Task 2: Refactor booking_service.dart for site_issue collection

**Priority**: high
**Status**: pending
**Acceptance Criteria covered**: AC-1, AC-3, AC-4, AC-7
**Dependencies**: Task 1 (logical; code can proceed in parallel but both needed for full success)

### Work
- Rename the collection constant: change `siteDetailsCollectionName = 'customer_site_details'` to a NEW constant `siteIssueCollectionName = 'site_issue'`. Keep old constant as deprecated alias for read fallbacks.
- Update `_siteDetailsCollection` getter to use `siteIssueCollectionName`. For backward read fallback, add a new getter `_legacySiteDetailsCollection` pointing to old name for fallback reads.
- Update `SiteDetails` class to include optional fields `status` (String), `createdAt` (DateTime?), `updatedAt` (DateTime?). Update `fromMap` and `toMap` accordingly.
- **Critical fix**: In `shareSiteDetails()`:
  - Build TWO payloads: one for the `site_issue` document (which CAN have top-level `FieldValue.serverTimestamp()` for `sharedAt`, `createdAt`, `updatedAt`), and a SECOND clean payload `siteDetailsMirror` for embedding into the booking document. The mirror MUST use `Timestamp.now()` for ALL dates (no `FieldValue` anywhere inside nested maps).
  - Write the `site_issue` doc first with `set(..., SetOptions(merge: true))`.
  - Then perform the booking update using the clean mirror. The mirror must have no `FieldValue.serverTimestamp()` — nested `sharedAt` should be `Timestamp.now()`.
  - The timeline event `site_inspected` array entry uses `Timestamp.now()` (not `FieldValue.serverTimestamp()`) per project hard constraint in `project_memory.md`.
  - Wrap booking update in try/catch but rethrow if it's NOT a silent-only non-critical failure; ensure failures are surfaced (do not silently swallow write errors).
- Update `watchSiteDetailsForRequest()`: first read from `site_issue` collection (new source), if null fallback to legacy `customer_site_details`, if still null fallback to embedded `siteDetails` on booking is done at the UI layer (already).
- Update `getSiteDetailsForRequest()` with the same cascade.

### Local Test Requirements
- **TR-2a (rule)**: grep `booking_service.dart` for `FieldValue.serverTimestamp()` and verify NONE appear inside the inline `timeline` array event maps or inside `siteDetails` mirror payload. All nested `at:` or timestamps inside maps use `Timestamp.now()`.
- **TR-2b (rule)**: The constant `siteIssueCollectionName = 'site_issue'` exists and is used by the `_siteDetailsCollection` (renamed to `_siteIssueCollection` or alias) getter.
- **TR-2c (rule)**: `shareSiteDetails()` body contains TWO separately-built payloads or clearly separated logic for (a) site_issue doc and (b) booking embedded siteDetails, and the booking embedded payload uses only `Timestamp` values (no `FieldValue`).
- **TR-2d (rubric - 0-2)**: Error propagation quality. `2` = booking update try/catch logs + notifies user, does not silently swallow; `1` = at least site_issue write throws on failure and errors surface; `0` = any error swallowed silently. Pass threshold: 1.

---

## Task 3: Fix SiteDetails.toMap() nested timestamp usage

**Priority**: high
**Status**: pending
**Acceptance Criteria covered**: AC-7
**Dependencies**: None (can be done alongside Task 2)

### Work
- `SiteDetails.toMap()` currently writes `'sharedAt': sharedAt != null ? Timestamp.fromDate(sharedAt!) : FieldValue.serverTimestamp()`.
- Issue: When `toMap()` is used for the booking embedded `siteDetails` field, the `FieldValue.serverTimestamp()` in a nested map can cause permission failures or odd write behavior.
- Fix: Add an optional named parameter, e.g. `Map<String, dynamic> toMap({bool forNested = false})`. When `forNested == true`, return `sharedAt != null ? Timestamp.fromDate(sharedAt!) : Timestamp.now()` (no FieldValue ever). When for top-level standalone write (default), keep the existing server timestamp for NEW documents only when sharedAt is null.
- Also apply same pattern to `CostEstimate.toMap()` and `Quotation.toMap()` as a preventive fix (used as nested in booking).

### Local Test Requirements
- **TR-3a (rule)**: `SiteDetails.toMap` signature includes a nesting-safe option (or a separate method `toNestedMap()`), and its output when called with nested-safe flag contains ZERO `FieldValue.*` references.
- **TR-3b (rule)**: Preventive: `CostEstimate.toMap` and `Quotation.toMap` also use nested-safe pattern (no FieldValue when destined for a map inside a document).

---

## Task 4: Improve Technician UI - photo payload safety and error UX

**Priority**: medium
**Status**: pending
**Acceptance Criteria covered**: AC-1, AC-6
**Dependencies**: None (parallel)

### Work
- In `share_site_details_screen.dart` `_submit()`:
  - Before calling `BookingService().shareSiteDetails`, compute a rough payload size: sum lengths of `description` + all `_photos` string entries (characters ~= bytes for ASCII/base64 ASCII).
  - If size >= ~800,000 chars (~800KB for base64), abort submission, show a red SnackBar: "Photos too large (total ~X KB). Please take lower-quality photos or remove some photos (Firestore document limit is 1MB)."
  - Add per-picker compression note: The existing `imageQuality: 50` + `maxWidth/Height: 900` already compresses; confirm these values are used (yes, currently set). Document via comment (in the spirit of the rule we don't add comments; just keep the values).
  - Better error surface: in `catch (e)`, if the error string contains "permission" tell the user "Permission error: ask your admin to ensure your technician account is registered in the technicians collection."
- In `_pickImage`, keep existing behavior but make `base64` encode optional safety: guard against empty bytes.

### Local Test Requirements
- **TR-4a (rule)**: `_submit()` contains a size check before calling the service, and the check is short-circuited with `return;` after showing the snack bar when oversized.
- **TR-4b (rubric - AC-6)**: Quality of payload limit handling. Scoring: `2` = size estimate + guidance in error message; `1` = at least Firestore errors are surfaced (no silent catch); `0` = errors swallowed silently.

---

## Task 5: Verify Supervisor and Admin screens read correctly

**Priority**: medium
**Status**: pending
**Acceptance Criteria covered**: AC-3, AC-4
**Dependencies**: Task 2 (reads use updated service)

### Work
- In `supervisor_job_detail.dart`: The `StreamBuilder<SiteDetails?>` already uses `BookingService().watchSiteDetailsForRequest(current.id)`. This already maps correctly after Task 2.
  - Verify: no changes needed to rendering; confirm site details panel card shows up when `job.siteDetails != null`.
- In `admin_requests_screen.dart` `_AdminRequestDetailsScreenState.build`: The `StreamBuilder` already calls `watchSiteDetailsForRequest(widget.request.id)`, then merges with `widget.request.siteDetails`. Confirm wiring is preserved.
  - Rendering in `_SiteDetailsCard` uses `overrideSiteDetails ?? request.siteDetails`; this is compatible.
- If any UI shows ONLY the embedded `request.siteDetails` without the StreamBuilder, add one. (Currently both screens already have the StreamBuilder pattern — good.)
- No UI rebuild required; just inspection and, if needed, a tiny fallback refactor.

### Local Test Requirements
- **TR-5a (rule)**: Supervisor detail page AND admin detail pages both contain a `StreamBuilder<SiteDetails?>` whose stream is `BookingService().watchSiteDetailsForRequest(<id>)`. Evidence: code location in each screen file with line reference.
- **TR-5b (rubric 0-2)**: Fallback depth. `2` = site_issue → legacy collection → embedded. `1` = at least site_issue → embedded (no legacy but acceptable). `0` = only reads embedded, ignoring the new collection. Pass threshold: 1.

---

## Task 6: Flutter static analysis and compile sanity

**Priority**: high
**Status**: pending
**Acceptance Criteria covered**: AC-5
**Dependencies**: Tasks 1-5 complete

### Work
- Run `flutter pub get` (to ensure dependencies healthy).
- Run `flutter analyze` from project root.
- Fix any new analyzer errors (e.g., unused imports, missing parameters, rename-side-effect issues).
- Optional smoke: `flutter build web --release` or at minimum `flutter build apk --debug` (time permitting; analyze is required minimum).

### Local Test Requirements
- **TR-6a (rule)**: `flutter analyze` exits with 0 issues in modified files OR only pre-existing issues that were there before (same count or fewer).
- **TR-6b (rule)**: No new `member not found`, `undefined class`, `type mismatch`, or `missing required argument` errors in `booking_service.dart` and UI screens.
