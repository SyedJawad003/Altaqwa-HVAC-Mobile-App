# AL TAQWA Cooling System — Mobile App Landing Website

Production-quality, responsive Flutter Web landing website for **AL TAQWA Cooling System** (`https://www.altaqwacoolingsystem.com/`).

Designed with a high-end UAE HVAC identity featuring deep royal navy, subtle metallic gold accents, crisp white sections, realistic pure-widget smartphone mockups, and dynamic cooling airflow particle animations.

---

## 🚀 Quick Start (Running the Website)

You can run the landing website in Chrome using either of the following commands:

```bash
# Default entrypoint
flutter run -d chrome

# Or targeting landing_page.dart directly
flutter run -t lib/landing_page.dart -d chrome
```

### Building for Production Web Deployment

```bash
flutter build web
# or
flutter build web -t lib/landing_page.dart
```

The compiled production files will be output to `build/web/`.

---

## ⚙️ Configuration & Customization Guide

All URLs, contact details, and app store links are centrally managed.

### 1. Connecting the Customer Panel URL (`customerPanelUrl`)

File: [`lib/config.dart`](file:///lib/config.dart)

Every **"Download App"** button (in the sticky navbar, mobile drawer, hero section, app showcase, customer experience, and footer) connects to this single handler via `openCustomerPanel()`.

```dart
// Replace 'CUSTOMER_PANEL_URL' with your live URL:
const customerPanelUrl = 'https://your-customer-portal-domain.com';
```

> **Note**: While set to `'CUSTOMER_PANEL_URL'` or left empty, clicking any "Download App" button will gracefully display a non-crashing snackbar: *"Customer panel link coming soon"*.

---

### 2. Apple App Store & Google Play Store Links

File: [`lib/config.dart`](file:///lib/config.dart)

```dart
// Provide store URLs when available:
const appStoreUrl = 'https://apps.apple.com/app/your-app-id';
const playStoreUrl = 'https://play.google.com/store/apps/details?id=your.bundle.id';
```

> **Automatic Fallback**: If either `appStoreUrl` or `playStoreUrl` is empty, the buttons in the Download CTA section automatically fall back to opening the Customer Panel via `openCustomerPanel()`.

---

### 3. Contact Details & Official WhatsApp

File: [`lib/config.dart`](file:///lib/config.dart) and [`lib/sections/contact_section.dart`](file:///lib/sections/contact_section.dart)

- **WhatsApp**: Verified official number configured in `config.dart`:
  ```dart
  const whatsappUrl = 'https://wa.me/971506109894';
  ```
  *(Clickable from the sticky floating WhatsApp button on every screen, the Contact section, and the Footer).*

- **Phone, Email, Location**: Set to `"To be confirmed"` as requested (no fabricated numbers or emails). When ready to update, edit [`lib/sections/contact_section.dart`](file:///lib/sections/contact_section.dart).

---

### 4. Updating the Brand Logo

The official logo has been fetched directly from the live site and is stored in `assets/logo2x.png` and declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/logo2x.png
    - assets/altaqwa_logo.png
```

To replace the logo:
1. Place your new PNG in `assets/logo2x.png`.
2. Both [`StickyNavbar`](file:///lib/widgets/navbar.dart) and [`FooterSection`](file:///lib/sections/footer_section.dart) will automatically load it, with automatic fallback to `assets/altaqwa_logo.png` or a gold snowflake emblem if unavailable.

---

## 📁 Architecture & File Structure

```text
lib/
├── config.dart                     # Central URLs & openCustomerPanel() handler
├── main.dart                       # Web application entry point
├── landing_page.dart               # Single-page coordinator with smooth scrolling
├── theme/
│   └── landing_theme.dart          # Deep Navy, Royal Blue, Metallic Gold, and UAE styling
├── widgets/
│   ├── airflow_painter.dart        # 60fps HVAC airflow curves & cooling particles
│   ├── floating_whatsapp.dart      # Pulsing WhatsApp action widget (wa.me/971506109894)
│   ├── glass_card.dart             # Frosted glassmorphism container
│   ├── navbar.dart                 # Sticky glass navbar + Mobile drawer
│   └── phone_mockup.dart           # Realistic pure-widget smartphone mockups
└── sections/
    ├── hero_section.dart           # 1. Hero with 3 floating mockups & live status chips
    ├── why_app_section.dart        # 2. "HVAC Service, Simplified" 4 feature cards
    ├── services_section.dart       # 3. 6 Professional Cooling Services cards
    ├── app_showcase_section.dart   # 4. 5 Overlapping phones + App capability pills
    ├── how_it_works_section.dart   # 5. 4-step responsive timeline (horizontal/vertical)
    ├── technician_section.dart     # 6. Connected Service Platform workflow diagram
    ├── customer_experience_section.dart # 7. Large phone + 4 staggered notification cards
    ├── trust_section.dart          # 8. "Reliable Cooling. Professional Service" trust cards
    ├── download_section.dart       # 9. App Store & Google Play CTA + dual mockups
    ├── contact_section.dart        # 10. Verified WhatsApp & support channels
    └── footer_section.dart         # 11. Dark Navy footer with navigation & policy modals
```

---

## 🎨 Visual Identity & Strict Design Rules

- **Brand Colors**: Deep Navy (`#061A3D`, `#040E22`), Royal Blue (`#0B3A8C`), Sky Blue (`#4F8FE0`), and Metallic Gold (`#C9A24A`, `#E8CF8A`).
- **No Red**: In strict accordance with the brand specification, red is nowhere in the palette.
- **Pure Widget Mockups**: All smartphone screens (Login, Dashboard, Booking, Tracking, Notifications) are rendered natively with Flutter widgets, ensuring ultra-crisp resolution on 4K monitors and mobile viewports alike.
- **Responsive Layout**: Fluid adaptation across desktop (`>=1024px`), tablet (`640px-1023px`), and mobile screens (`<640px`).
