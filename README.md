# E-Bike Admin App — Setup Guide

## 1. Create a Firebase project
1. Go to https://console.firebase.google.com and create a new project (for example, `ebike-rental`).
2. Open Build > Firestore Database > Create database (production mode, then choose the nearest region).
3. Open Build > Storage > Get started (you will need this later for document uploads).

## 2. Connect Firebase to the Flutter app
```
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart`. Then uncomment these lines in `main.dart`:
```dart
// import 'firebase_options.dart';
// options: DefaultFirebaseOptions.currentPlatform,
```

## 3. Create the admin account manually
In the Firestore Console, create a collection manually:
- Collection: `admins`
- Document (auto id): `{ username: "your_admin_name", password: "your_password" }`

Use this username and password to log in to the app.

## 4. Packages install
```
flutter pub get
```

## 5. Run
```
flutter run
```

## ⚠️ Important note — Security
In this version, passwords are stored in Firestore as plain text, and login is checked by querying the `admins`/`clients` collections directly from the client side (no Firebase Auth, as requested). This is fine for getting started, but before production you should at least consider the following:
- If Firestore Security Rules are not configured, anyone who knows the app URL or data structure may be able to read or edit the full client list (name, phone, documents). At minimum, use rules to block read/write access and allow only the intended admin app. We can address that in a later step.
- Storing hashed passwords instead of plain text is a better practice. That can be added later; it is omitted here for simplicity.

## What is already included
- Admin login (Firestore-based, no Firebase Auth)
- Dashboard: summary cards (total / active / due soon / blocked)
- Create client (username, password, + optional basic info)
- Client list with search (name / phone / bike number / username)
- Client detail: view + edit all info, confirm client, block/unblock, send notification
- Dark theme throughout

## What is still left (next step)
- Document upload (passport / récépissé-séjour / domicile) — via Firebase Storage
- Automated payment reminder (Cloud Function)
- Customer app (separate project, using the same Firestore)
- Firestore Security Rules
