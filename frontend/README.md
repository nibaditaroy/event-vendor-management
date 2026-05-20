# Event Vendor Management Portal - Frontend App

This is the cross-platform client application for the Event Vendor Management Portal, built using **Flutter** and **Dart**. It provides custom dashboards for both **Event Organizers** and **Service Vendors**.

---

## 📱 Features
* **Role-Based Experience**:
  * **Organizers**: Browse vendor categories, view vendor profiles, book services, track request status, pay, and review vendors.
  * **Vendors**: Manage business profile, add and edit service listings, accept or reject booking requests, and track earnings.
* **State Management**: Built on the **Provider** pattern for reactive UI updates.
* **Asset Uploads**: Profile images and service cover photos uploaded to backend & Cloudinary.
* **Persistent Authentication**: Token-based login using device storage via `SharedPreferences`.

---

## ⚙️ Prerequisites
* **Flutter SDK** (`>=3.0.0 <4.0.0` as per `pubspec.yaml`)
* **Dart SDK**
* **Target Environment**:
  * **Mobile**: Android Studio (Emulator) / Xcode (iOS Simulator) / Physical device.
  * **Web**: Chrome Browser.

---

## 🚀 Setup & Execution

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Retrieve package dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   * **Auto-detect device** (runs on active emulator/simulator or web if none are open):
     ```bash
     flutter run
     ```
   * **Run on Chrome Web Browser**:
     ```bash
     flutter run -d chrome
     ```
   * **Run on specific Android device/emulator**:
     ```bash
     flutter run -d <emulator-id>
     ```

---

## 🏗️ Codebase Structure

The frontend application follows a clean modular directory structure:

```
lib/
├── core/             # Themes, styles, and global constants
├── models/           # Dart data objects deserialized from API JSON
│   ├── booking.dart
│   ├── category.dart
│   ├── service.dart
│   └── user.dart
├── providers/        # ChangeNotifiers for state and business logic
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   ├── category_provider.dart
│   ├── service_provider.dart
│   └── vendor_provider.dart
├── routes/           # Routing configuration & route names
├── screens/          # App pages grouped by domains
│   ├── auth/         # Login & registration screens
│   ├── booking/      # Booking details & scheduler screens
│   ├── organizer/    # Organizer home, category lists, vendor profiles
│   ├── vendor/       # Vendor home, request manager, service editor
│   └── profile/      # User profile configurations
├── services/         # API HTTP communication services
│   └── api_service.dart
└── main.dart         # Flutter application entrypoint
```

---

## 📡 API URL Auto-Resolution

Inside [api_service.dart](file:///Users/rahul/Projects/event-vendor-management/frontend/lib/services/api_service.dart), the base URL is dynamically determined based on the target platform:

```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:5001/api';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:5001/api'; // Android Emulator redirects localhost to host
  } else {
    return 'http://localhost:5001/api'; // iOS Simulator & Desktop
  }
}
```

> [!WARNING]
> If testing on a **physical mobile device**, ensure your device is connected to the **same Wi-Fi network** as the backend host. Update the IP address in `api_service.dart` to match your development machine's local IP address (e.g. `http://192.168.1.XX:5001/api`).