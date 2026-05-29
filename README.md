# 🚀 SpendSnap

**SpendSnap** is a smart personal finance and expense tracking app built with Flutter.

It simplifies expense management using:

* 📷 QR-based UPI scanning
* ⚡ Smart autofill
* 🧠 Dynamic category management
* 📊 Intelligent insights
* 🔐 User authentication
* ☁️ Scalable architecture

---
# ✨ Features

## 📷 QR-Based Expense Tracking

* Scan UPI QR codes
* Automatically extracts:

  * Amount 💰
  * Description 📝
  * Merchant details 🏪
* Supports direct UPI payment flow

---

## ⚡ Smart Expense Creation

* Pre-filled expense form after scanning
* One-tap save workflow
* Dynamic categories
* Edit existing expenses
* Delete expenses

---

## 🔐 Authentication

* Google Sign-In using Firebase Authentication
* User-specific expense isolation
* Secure personalized experience

---

## 🧠 Dynamic Categories

Users can:

* Create categories
* Edit categories
* Delete categories
* Customize:

  * Colors 🎨
  * Icons 🧩
  * Detection keywords 🏷️

Examples:

* Food 🍔
* Travel 🚗
* Shopping 🛍️
* Investment 📈

---

## 📊 Insights Dashboard

* Today / Weekly / Monthly totals
* Category-wise expense breakdown
* Spending trend analysis
* Smart weekly insights

Examples:

* “You spent more than last week”
* “You saved compared to last week”

---

## 💾 Offline-First Architecture

Uses:

* Drift (SQLite)

Benefits:

* Fast local performance
* Works offline
* Reliable persistence
* User-isolated local data

---

# 📱 Screens

* Home Screen
* Insights Screen
* Add/Edit Expense Screen
* QR Scanner Screen
* Login Screen
* Profile Screen
* Manage Categories Screen

---

# 🛠️ Tech Stack

| Technology     | Purpose            |
| -------------- | ------------------ |
| Flutter        | Cross-platform UI  |
| Drift (SQLite) | Local database     |
| Firebase Auth  | Authentication     |
| Mobile Scanner | QR scanning        |
| url_launcher   | UPI payment launch |
| Google Sign-In | Login              |
| Firebase       | Future cloud sync  |

---

# 🔄 App Flow

1. Login with Google
2. Scan QR or add expense manually
3. Auto-fill expense details
4. Auto-select category
5. Save expense
6. View insights instantly

---

# 🎯 Core Product Philosophy

> Scan → Auto-fill → Categorize → Save → Analyze

SpendSnap aims to reduce friction in personal finance tracking while keeping the experience fast and intuitive.

---

# 🧠 Smart Architecture Highlights

* User-isolated local database
* Dynamic category-driven UI
* Reusable add/edit flows
* DB-driven icons & colors
* Scalable Firebase-ready architecture

---

# 🚧 Upcoming Features

## ☁️ Cloud Sync

* Firebase Firestore sync
* Multi-device support

---

## 🤖 Smart Detection

* Keyword-based category detection
* AI-powered categorization

---

## 📈 Advanced Analytics

* Monthly reports
* Trend charts
* Savings analysis

---

## 📤 Export Features

* CSV export
* PDF reports

---

## 🎨 Personalization

* Themes
* Currency settings
* Budget goals

---

# 📦 Installation

## Clone Repository

```bash
git clone https://github.com/arunkumar-js25/spendsnap.git
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Run App

```bash
flutter run
```

---

# 🔧 Developer Commands

## Rebuild Drift Database

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Generate Release APK

```bash
flutter build apk --release
```

---

## Generate Play Store AAB

```bash
flutter build appbundle --release
```

---

## Clean Project

```bash
flutter clean
flutter pub get
```

---

# 🔐 Firebase Setup

1. Create Firebase project
2. Add Android app
3. Download:

   * `google-services.json`
4. Place inside:

   * `android/app/`
5. Enable:

   * Google Authentication

---

# 🤝 Contribution

Contributions, ideas, and feature suggestions are welcome!

Feel free to:

* Fork the repo
* Open issues
* Submit pull requests

---

# 📄 License

MIT License

---

# 👨‍💻 Author

**Arun Kumar**

GitHub:
https://github.com/arunkumar-js25

---

⭐ If you like this project, consider giving it a star!
