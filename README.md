# E-Bike Admin App — Setup Guide

## 1. Firebase project বানাও
1. https://console.firebase.google.com এ গিয়ে নতুন project বানাও (e.g. `ebike-rental`)
2. Build > Firestore Database > Create database (production mode, nিয়ারest region select করো)
3. Build > Storage > Get started (পরে document upload যোগ করার সময় লাগবে)

## 2. Flutter app এর সাথে Firebase কানেক্ট করো
```
dart pub global activate flutterfire_cli
flutterfire configure
```
এটা `lib/firebase_options.dart` জেনারেট করবে। এরপর `main.dart` এ এই লাইন দুটো uncomment করো:
```dart
// import 'firebase_options.dart';
// options: DefaultFirebaseOptions.currentPlatform,
```

## 3. Admin account manually তৈরি করো
Firestore Console এ গিয়ে হাতে একটা collection বানাও:
- Collection: `admins`
- Document (auto id): `{ username: "your_admin_name", password: "your_password" }`

এই username/password দিয়েই app এ লগইন করবে।

## 4. Packages install
```
flutter pub get
```

## 5. Run
```
flutter run
```

## ⚠️ গুরুত্বপূর্ণ নোট — Security
এই ভার্সনে password গুলো Firestore এ plain text এ রাখা হচ্ছে, এবং client-side থেকে সরাসরি `admins`/`clients` collection query করে login check করা হচ্ছে (কোনো Firebase Auth নেই, তোমার request অনুযায়ী)। এটা শুরু করার জন্য ঠিক আছে, কিন্তু production এ যাওয়ার আগে অন্তত এইগুলো ভেবে দেখা উচিত:
- **Firestore Security Rules** সেট না করলে যে কেউ তোমার পুরো client list (নাম, ফোন, ডকুমেন্ট) পড়তে/এডিট করতে পারবে যদি তারা app URL/এর data structure জানে। কমপক্ষে rules দিয়ে read/write বন্ধ করে শুধু নির্দিষ্ট admin app থেকেই allow করা উচিত — এটা নিয়ে পরে আলাদা করে বলব যখন এই ধাপে আসবো।
- Password hash করে রাখা (plain text না রাখা) ভালো অভ্যাস — এটাও পরের ধাপে যোগ করা যায়, আপাতত simplicity এর জন্য বাদ রাখা হয়েছে।

## এখন পর্যন্ত যা আছে
- Admin login (Firestore-based, no Firebase Auth)
- Dashboard: summary cards (total / active / due soon / blocked)
- Create client (username, password, + optional basic info)
- Client list with search (name / phone / bike number / username)
- Client detail: view + edit all info, confirm client, block/unblock, send notification
- Dark theme throughout

## এখনো বাকি (পরের ধাপে)
- Document upload (passport / récépissé-séjour / domicile) — Firebase Storage দিয়ে
- Automated payment reminder (Cloud Function)
- Customer app (আলাদা project, একই Firestore ব্যবহার করবে)
- Firestore Security Rules
