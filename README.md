# AL TAQWA Cooling System

**HVAC service management for customers and service teams.** This Flutter project includes customer-facing mobile app workflows, separate admin and supervisor portals, and a public Flutter Web landing page. Firebase powers authentication and the shared service-request data.

## Features

- **Customers:** Register and sign in, browse HVAC services, schedule maintenance, request quotations with job details and photos, view quotations, and contact support through in-app chat.
- **Technicians:** Review assigned jobs, update job progress, add notes and completion details, and share site information and photos.
- **Supervisors:** Review team jobs and progress, provide cost estimates, verify completed work, raise or follow up on issues, and request revisits.
- **Administrators:** Monitor requests, assign technicians, manage quotations and customers, oversee technician availability, handle customer chats, and review supervisor issues.
- **Landing page:** Responsive company and service information, app links, contact details, and WhatsApp contact.
- **Shared backend:** Firebase Authentication, Cloud Firestore, and Firebase Storage integrations.

## Tech Stack

- **Application framework:** Flutter
- **Language:** Dart (`^3.13.1`, as declared in `pubspec.yaml`)
- **Authentication:** Firebase Authentication
- **Database:** Cloud Firestore
- **File storage:** Firebase Storage
- **Other packages:** `shared_preferences`, `url_launcher`, `image_picker`, `pdf`, and `printing`
- **Platforms configured in the app:** Android, iOS, and Web
- **Android build:** Gradle Kotlin DSL; Java 17 compile target

## Prerequisites

- Flutter SDK with Dart 3.13.1 or later in the Dart 3.x range.
- Android Studio and Android SDK for Android builds, or Xcode on macOS for iOS builds.
- Chrome for running or building the web apps.
- A Firebase project configured with Email/Password Authentication, Cloud Firestore, and Cloud Storage.
- Firebase CLI only if you intend to deploy the Firestore rules or indexes.

Check the local Flutter and platform setup with:

```bash
flutter doctor -v
```

## Getting Started

### 1. Clone the repository and install packages

```bash
git clone https://github.com/SyedJawad003/Altaqwa-HVAC-Mobile-App.git
cd Altaqwa-HVAC-Mobile-App
flutter pub get
```

### 2. Configure Firebase

The app uses generated Firebase options in `lib/firebase_options.dart`; Android also has a Google Services configuration at `android/app/google-services.json`. The Firebase project must have Email/Password sign-in enabled, Firestore created, and Cloud Storage enabled for workflows that upload photos.

To connect a different Firebase project, configure its Android, iOS, and Web apps with FlutterFire CLI and replace the generated platform configuration. Review `firebase.json`, `firestore.rules`, and `firestore.indexes.json` before deploying backend configuration. For example, with the Firebase CLI logged in and the intended project selected:

```bash
firebase use YOUR_FIREBASE_PROJECT_ID
firebase deploy --only firestore:rules,firestore:indexes
```

Do not deploy the supplied rules to a production project without reviewing them against your organization’s access-control requirements. The repository does not define a `.env`-based configuration system. Keep private credentials and production-specific settings out of source control.

### 3. Run an app

The entry points are separate. Run one at a time:

```bash
# Customer app (default entry point)
flutter run -t lib/main.dart

# Admin web portal
flutter run -t lib/main_admin.dart -d chrome

# Supervisor app
flutter run -t lib/main_supervisor.dart

# Public landing page
flutter run -t lib/landing_page.dart -d chrome
```

The customer app routes signed-in technician accounts to the technician dashboard. Supervisor accounts use the dedicated supervisor portal. Admin, technician, and supervisor access depends on the corresponding Firebase Authentication account and role/profile data; set up and secure those accounts for your environment before use.

To build:

```bash
flutter build apk -t lib/main.dart
flutter build web -t lib/main_admin.dart
flutter build web -t lib/landing_page.dart
```

Web builds use `build/web/`; build and deploy each web entry point separately so one build does not overwrite another.

## Main Workflows

1. **Customer request:** A customer creates an account or signs in, browses services, then submits a scheduled service request or quote request. Quote requests can include photos and are shared with the admin and supervisor for review.
2. **Review and assignment:** Admin staff review incoming requests, prepare and send a quotation where appropriate, and assign accepted work to a technician.
3. **Service delivery:** The technician views assigned work, updates its progress, and records site details, notes, photos, and completion information.
4. **Supervision:** Supervisors monitor jobs, prepare cost estimates, review completion, and can request follow-up work or a revisit.
5. **Customer updates:** Customers can review requests and quotations in the customer app and exchange messages with support through chat.

## Project Structure

```text
lib/
├── main.dart                         # Customer app entry point
├── main_admin.dart                   # Admin web portal entry point
├── main_supervisor.dart              # Supervisor portal entry point
├── landing_page.dart                 # Public Flutter Web landing page
├── firebase_options.dart             # Generated Firebase platform options
├── config.dart                       # Landing page links and contact configuration
├── customer/
│   ├── screens/                      # Customer authentication, services, bookings, chat
│   ├── services/                     # Authentication, booking, chat, role routing
│   ├── theme/
│   └── widgets/
├── admin/                            # Admin portal, requests, quotes, customers, chat
├── supervisor/                       # Supervisor login, job review, and dashboard
├── technician/                       # Technician dashboard and site details
├── sections/                         # Public landing-page content sections
├── widgets/                          # Shared landing-page widgets
└── theme/                            # Landing-page theme
assets/                               # Brand and screen imagery
android/, ios/, web/, windows/        # Platform projects
test/                                 # Flutter tests
tool/                                 # Developer utilities
firebase.json                         # Firebase project and Firestore configuration
firestore.rules                       # Firestore security rules
firestore.indexes.json                # Firestore indexes
```

## Configuration Notes

- **Firebase:** Firebase options are generated in `lib/firebase_options.dart`. Reconfigure them for your own Firebase project, and ensure the project’s Authentication, Firestore, and Storage services are enabled.
- **Firestore:** Review and deploy the checked-in rules and indexes with the Firebase CLI as described above.
- **Storage:** Photo-upload features require Firebase Storage and appropriate Storage security rules in the Firebase project. No Storage rules file is currently included in this repository.
- **Landing page links:** Update `customerPanelUrl`, `appStoreUrl`, `playStoreUrl`, and `whatsappUrl` in `lib/config.dart` when production destinations are available. Phone, email, and location display content is in `lib/sections/contact_section.dart`.
- **Role accounts:** Protect admin, technician, and supervisor access by managing Firebase accounts and their role/profile records securely. Do not rely on demo or development credentials in a production deployment.
- **Supported Firebase options:** `lib/firebase_options.dart` currently configures Android, iOS, and Web; desktop Firebase options are not configured.

## Tests

Run the Flutter test suite with:

```bash
flutter test
```

## License and Copyright

There is no `LICENSE` file in this repository, so no open-source license is specified. Treat the application and its assets as proprietary and obtain permission from the project owner before redistributing or reusing them.
