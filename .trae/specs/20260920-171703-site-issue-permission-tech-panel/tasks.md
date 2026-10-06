# Implementation Tasks

Implementation order: Task 1 → Task 2 → Task 3 → Task 4 → Task 5 (Verify).

---

## Task 1: Permission Resilience (Notification Wrapper + Rules)

**Priority**: high
**Parent ACs**: AC-1, AC-2, AC-8
**Status**: pending

### Description
Fix the root cause of the persistent PERMISSION_DENIED error during technician site submission: the trailing `_notifySupervisors()` call can throw when the technician has no `/technicians/<uid>` doc, which makes the entire `shareSiteDetails()` Future appear to fail (even though site_issue + booking data WAS saved). Also extend notifications create rule for defense-in-depth.

### Test Requirements
| TR | Type | Pass Condition | Evidence |
|---|---|---|---|
| TR-1.1 | rule | After code change, `_notifySupervisors` call in `shareSiteDetails` is wrapped in try/catch that swallows | Code inspection: line around `booking_service.dart:1208` uses `try { await _notifySupervisors(...); } catch (_) {}` pattern |
| TR-1.2 | rule | Legacy `customer_site_details` write remains already-wrapped + booking update still throws on REAL failure | Code inspection: booking update try/catch still throws wrapped error; NOT swallowed (critical writes can fail and notify user) |
| TR-1.3 | rule | Firestore.rules notifications create rule now includes `signedIn() && request.resource.data.senderUid == request.auth.uid` | Code inspection in `firestore.rules:82`: rule clause exists as a disjunct |

### Completion Evidence
_To be filled after self-verification_

---

## Task 2: Technicians Data Access Layer Helpers

**Priority**: high
**Parent ACs**: AC-3, AC-5
**Status**: pending

### Description
Add a Technician data model + stream accessors in BookingService for use by Admin Technicians Screen. Include:
- Typed `Technician` data class (name, email, phone, uid, role, status, available, createdAt, updatedAt)
- `watchTechnicians()` → `Stream<List<Technician>>` ordered by `name`
- `watchJobsForTechnician(String uid, String name)` → `Stream<List<BookingRequest>>` or aggregate count helper (can be `Future<int>` for simplicity since cardinality is small)
- `toggleTechnicianAvailable(String uid, bool currentValue)` → `Future<void>` writes `available`, `updatedAt` with SetOptions(merge: true)

Helper can live in `booking_service.dart` (near other collection getters) to avoid creating new files unnecessarily.

### Test Requirements
| TR | Type | Pass Condition | Evidence |
|---|---|---|---|
| TR-2.1 | rule | `Technician` model with fromMap/toMap or just fromMap + typed fields exists in booking_service.dart (or admin-only utility file) | Code inspection shows class with required 8 fields |
| TR-2.2 | rule | `watchTechnicians()` getter / method → Stream, correctly uses `FirebaseFirestore.instance.collection('technicians').orderBy('name').snapshots()` mapped via fromMap | Code inspection |
| TR-2.3 | rule | Admin can toggle availability inline: method toggles `available` and sets `updatedAt: FieldValue.serverTimestamp()` via merge true | Code inspection + SetOptions(merge:true) usage |
| TR-2.4 | rubric | Data access cost quality (scales with low cardinality). Scale 0-2: 0 = N+1 Firestore reads per list without caching; 1 = acceptable one read per row (small cardinality OK); 2 = single collection-group stream + client-side booking aggregation (preferred). Pass ≥ 1. | Implementation review |

### Completion Evidence
_To be filled after self-verification_

---

## Task 3: Admin Technicians Screen (UI)

**Priority**: high
**Parent ACs**: AC-3, AC-4, AC-5, AC-6
**Status**: pending

### Description
Create `lib/admin/admin_technicians_screen.dart` following the exact pattern of `CustomersScreen`:
- Scaffold with `backgroundColor: Color(0xFFF8FAFC)`, `drawer: const AdminNavigationDrawer()`
- `AdminGradientAppBar(title: 'Technicians', subtitle: 'Registered technicians and workload overview.')`
- Top summary card: "Technician Overview" → 3 stats: Total techs, Active (status == 'active'), Available (available == true)
- Gold FilledButton: "Open Requests" navigates to AdminRequestsScreen (same as CustomersScreen)
- Expanded → StreamBuilder<List<Technician>> → ListView.separated
- Each Technician card includes:
  - CircleAvatar (navy bg, initials from name; fallback Icon(Icons.person) if no name)
  - Title: name, Subtitle: email • phone
  - Wrap of 3 chips: Status (green=active/grey=inactive), Availability (green=Available/amber=On break), Assigned jobs count (navy chip with count "3 assigned")
  - Trailing IconButton: Icons.toggle_on / toggle_off → calls toggleTechnicianAvailable, shows snackBar with confirmation/error
- Empty state, error state, waiting state (CircularProgressIndicator with navy color)
- Use existing constants: `navy`, `navyDeep`, `gold` from app_theme.dart/admin_theme.dart

### Test Requirements
| TR | Type | Pass Condition | Evidence |
|---|---|---|---|
| TR-3.1 | rule | File exists at `lib/admin/admin_technicians_screen.dart` and defines `AdminTechniciansScreen` widget usable in navigator | File presence + widget declaration |
| TR-3.2 | rule | Summary card displays total/active/available counts derived from stream data | Screen render via code review |
| TR-3.3 | rule | List tile displays all 6 required UI elements: avatar, name, email•phone, status chip, availability chip, assigned-jobs count + toggle button | Code review of listTile / card builder |
| TR-3.4 | rule | Availability toggle writes back to Firestore on tap via service method and triggers snackBar confirmation | onPressed handler inspection |
| TR-3.5 | rule | Empty / Error / Loading states all match the pattern from CustomersScreen (exact same widget types) | Code side-by-side comparison |

### Completion Evidence
_To be filled after self-verification_

---

## Task 4: Wire Admin Navigation Drawer

**Priority**: medium
**Parent ACs**: AC-4
**Status**: pending

### Description
In `lib/admin/admin_navigation_drawer.dart`:
- Add `import 'admin_technicians_screen.dart';` at top
- Replace line 124 `_menuItem(context, Icons.engineering_outlined, 'Technicians'),` with a regular `ListTile` identical in pattern to the Supervisors entry, navigating to `const AdminTechniciansScreen()`
- Keep same leading icon, title font weight, color convention (navy)

### Test Requirements
| TR | Type | Pass Condition | Evidence |
|---|---|---|---|
| TR-4.1 | rule | `_menuItem(...)` placeholder call REMOVED from build method; ListTile takes its place | Code inspection: no `_menuItem` in Technicians area; `_open(context, const AdminTechniciansScreen())` exists |
| TR-4.2 | rule | Import of `admin_technicians_screen.dart` is present and linted (no unused import warning) | flutter analyze for file has no unused_import on new import |

### Completion Evidence
_To be filled after self-verification_

---

## Task 5: Verify & Analyze

**Priority**: high
**Parent ACs**: AC-6, AC-7
**Status**: pending

### Description
Run static verification on the workspace.
- `flutter analyze` → filter results for our changed/new files; zero warning/error/info in: `booking_service.dart`, `admin_navigation_drawer.dart`, `admin_technicians_screen.dart`, `firestore.rules` (rules not checked by analyzer, we'll use code review).
- `GetDiagnostics` → expect `[]`
- Manual code review for no regressions: `watchSiteDetailsForRequest` cascade still intact, `toMap(forNested)` still used in CostEstimate & Quotation.

### Test Requirements
| TR | Type | Pass Condition | Evidence |
|---|---|---|---|
| TR-5.1 | rule | flutter analyze: no warnings/errors/infos in OUR 4 paths above | terminal output grep |
| TR-5.2 | rule | GetDiagnostics returns `[]` | IDE diagnostics |
| TR-5.3 | rule | No regression: `submitCostEstimate` / `createQuotation` still call `toMap(forNested: true)` when embedding in booking | Code inspection in booking_service.dart |

### Completion Evidence
_To be filled after self-verification_
