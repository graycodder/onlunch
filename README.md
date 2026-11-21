# OneLunch – Flutter Mobile Application
**By Rinus Food Products**

A production-ready Flutter mobile application for browsing daily lunch menus, customizing orders, placing lunch bookings, and tracking order history in real time.

---

## 📱 Features

1. **Brand Identity & Splash Screen**:
   - Official Rinus Food Products emblem & green badge.
   - Tagline: *"Good Food. Great Mood."*
   - Automatic session restoration checking Firebase Auth.

2. **Mobile OTP Login**:
   - Indian mobile number validation (`+91` prefix).
   - Firebase Phone Authentication (`verifyPhoneNumber`).
   - 30-second resend countdown timer with automatic cooldown.
   - 6-digit auto-advancing OTP input.
   - Guest "Explore Menu" mode.

3. **Home Dashboard**:
   - Forest Green theme (`#075B25`) with hamburger menu and live cart counter badge.
   - Promotional video banner featuring YouTube player integration.
   - Live daily lunch availability banner and cutoff time indicator (`11:30 AM`).
   - "Our Lunch Menu" horizontal carousel with dynamic price and instant item inspection.
   - Quick Customer Services: "Watch Our Video", "Customer Support", "Special Offers".
   - Persistent 3-tab bottom navigation (Home, Orders, Profile).

4. **Food Details Screen**:
   - Immersive hero food photography (Kerala sadhya / banana leaf).
   - Real-time subtotal calculation.
   - Interactive quantity stepper (`[ - ]  quantity  [ + ]`).
   - One-tap "Add to Cart" with visual notification.

5. **Shopping Cart & Checkout**:
   - Cart item list with thumbnail, unit price, quantity stepper, and remove action.
   - Live Firebase Cart synchronization under `onelunch/carts/{uid}`.
   - Delivery address and corporate drop point input.
   - Configurable payment options (Cash on Delivery / Lunch Counter & Online).
   - Duplicate order submission prevention.

6. **Order History & Realtime Tracking**:
   - Segmented filter tabs: **Pending** vs **Completed**.
   - Live order stream from Firebase Realtime Database (`onelunch/orders/`).
   - Human-readable unique Order IDs (e.g. `#OL1001`).
   - Status indicators: `Pending`, `Accepted`, `Preparing`, `Ready`, `Completed`, `Cancelled`.

7. **Order Confirmation & Details**:
   - Clean confirmation banner with timer icon.
   - Itemized breakdown with thumbnails, quantities, and price summary.
   - Quick return to home navigation.

8. **Customer Profile & Support**:
   - Avatar with editable profile details (Name, Address, Email).
   - Order history access.
   - Direct phone hotline to Rinus Food Products support (`+919995226139`).
   - Terms & Conditions and Privacy Policy documentation.
   - Session logout.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.47.1 / Dart 3.13.1
- **State Management**: GetX (Controllers, reactive `Rx` states, Dependency Injection, routing)
- **Design System**: Material 3 + Custom Forest Green & Cream Palette (`#075B25`, `#FFFDF2`, `#153B22`)
- **Typography**: Google Fonts (Poppins & Caveat)
- **Backend**: Firebase Realtime Database & Firebase Phone Authentication
- **Firebase Project**: `rfproducts-e76ce`
- **Database Root**: `onelunch/` (completely isolated from existing Rinus web data)

---

## 📂 Project Structure

```text
lib/
  ├── main.dart
  ├── core/
  │    ├── constants/
  │    │    ├── colors.dart
  │    │    ├── strings.dart
  │    │    └── assets.dart
  │    ├── theme/
  │    │    └── app_theme.dart
  │    └── routes/
  │         ├── app_routes.dart
  │         └── app_pages.dart
  ├── data/
  │    ├── models/
  │    │    ├── user_model.dart
  │    │    ├── product_model.dart
  │    │    ├── category_model.dart
  │    │    ├── cart_item_model.dart
  │    │    ├── order_model.dart
  │    │    ├── banner_model.dart
  │    │    └── settings_model.dart
  │    └── repositories/
  │         ├── auth_repository.dart
  │         ├── product_repository.dart
  │         ├── cart_repository.dart
  │         ├── order_repository.dart
  │         ├── banner_repository.dart
  │         └── settings_repository.dart
  ├── features/
  │    ├── auth/
  │    │    ├── controllers/auth_controller.dart
  │    │    └── screens/
  │    │         ├── splash_screen.dart
  │    │         ├── welcome_login_screen.dart
  │    │         └── otp_verification_screen.dart
  │    ├── home/
  │    │    ├── controllers/home_controller.dart
  │    │    ├── screens/
  │    │    │    ├── main_nav_screen.dart
  │    │    │    └── home_screen.dart
  │    │    └── widgets/
  │    │         ├── video_banner_widget.dart
  │    │         ├── menu_card_widget.dart
  │    │         └── service_card_widget.dart
  │    ├── products/
  │    │    ├── controllers/product_details_controller.dart
  │    │    └── screens/
  │    │         ├── product_details_screen.dart
  │    │         └── menu_catalog_screen.dart
  │    ├── cart/
  │    │    ├── controllers/cart_controller.dart
  │    │    └── screens/cart_screen.dart
  │    ├── orders/
  │    │    ├── controllers/orders_controller.dart
  │    │    └── screens/
  │    │         ├── my_orders_screen.dart
  │    │         └── order_details_screen.dart
  │    ├── profile/
  │    │    ├── controllers/profile_controller.dart
  │    │    └── screens/profile_screen.dart
  │    └── common/
  │         └── widgets/
  │              ├── custom_button.dart
  │              ├── custom_header.dart
  │              └── leaf_background.dart
  └── firebase/
       ├── firebase_options.dart
       └── firebase_service.dart
```

---

## 🔒 Firebase Security Rules

Add the following security rules to Firebase Realtime Database to secure `onelunch/`:

```json
{
  "rules": {
    "onelunch": {
      "products": {
        ".read": true,
        ".write": "auth != null && auth.token.admin === true"
      },
      "categories": {
        ".read": true,
        ".write": "auth != null && auth.token.admin === true"
      },
      "banners": {
        ".read": true,
        ".write": "auth != null && auth.token.admin === true"
      },
      "settings": {
        ".read": true,
        ".write": "auth != null && auth.token.admin === true"
      },
      "users": {
        "$uid": {
          ".read": "auth != null && auth.uid === $uid",
          ".write": "auth != null && auth.uid === $uid"
        }
      },
      "carts": {
        "$uid": {
          ".read": "auth != null && auth.uid === $uid",
          ".write": "auth != null && auth.uid === $uid"
        }
      },
      "orders": {
        ".read": "auth != null",
        ".indexOn": ["userId", "timestamp"],
        "$orderId": {
          ".read": "auth != null && (data.child('userId').val() === auth.uid || auth.token.admin === true)",
          ".write": "auth != null && (!data.exists() || data.child('userId').val() === auth.uid)"
        }
      }
    }
  }
}
```

---

## 🚀 How to Run

1. Clone or open `/Users/vimaldas/Desktop/onelunch`.
2. Ensure Flutter SDK is installed and on path:
   ```bash
   flutter doctor
   ```
3. Get packages:
   ```bash
   flutter pub get
   ```
4. Run on connected Android / iOS device or Simulator:
   ```bash
   flutter run
   ```
5. Build Release APK:
   ```bash
   flutter build apk --release
   ```
