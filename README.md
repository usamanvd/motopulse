# 🏍️ MotoPulse: Smart Bike & Khaata

[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-5.0%2B-green.svg?logo=android)](https://android.com)
[![Material 3](https://img.shields.io/badge/Design-Material%20You%20(Pixel)-teal.svg)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

**MotoPulse** is a personal motorcycle management and financial ledger application built with **Flutter** and styled strictly around Google Pixel's **Material You (Material 3)** design language.

It combines **fuel mileage tracking**, **odometer-based maintenance alerts**, **live countdown timers**, and a **Khaata expense ledger** into a mobile experience with Google Cloud syncing.

---

## ✨ Features

### 1. ⛽ Smart Fuel & Mileage Tracker
* **Fill-up Logging**: Log date, current odometer reading (KM), amount spent, and fuel volume (Litres).
* **Automatic Formula Calculations**:
  * **Distance Traveled**: $\text{Current KM} - \text{Previous KM}$
  * **Mileage Average**: $\text{Distance (KM)} \div \text{Litres}$ (e.g., **46.5 KM/L**)
  * **Cost per KM**: $\text{Amount Spent} \div \text{Distance}$ (e.g., **Rs. 6.10 / KM**)
* **Lifetime Statistics**: Running total of fuel spent, liters consumed, and overall fleet average.
* **Auto-Khaata Integration**: Automatically logs fuel expenses directly into your Khaata ledger with one tap.

### 2. 🛢️ 1,000 KM Oil Change Reminder
* Dynamically calculates distance traveled since last oil change against the **1,000 KM threshold**.
* Real-time remaining distance counter (e.g., `350 KM remaining`).
* **Visual Status Indicators**:
  * **Safe (Green)**: Above 150 KM remaining.
  * **Due Soon (Orange)**: Under 150 KM remaining.
  * **Overdue (Red Alert)**: Urgent banner on dashboard & badge on navigation bar.
* **1-Tap Reset**: "Log Oil Change Done" resets the counter and records oil expense in Khaata.
* **Customizable Threshold**: Set your own distance interval (e.g. 800 KM, 1,200 KM, 1,500 KM).

### 3. 🔧 2-Month Tuning & Service Reminder
* Tracks date of last tuning and automatically schedules a reminder **60 days (~2 months)** later.
* Reverse days remaining indicator (e.g., `18 Days Remaining` or `Tuning Overdue!`).
* Configurable interval days and 1-tap reset action.

### 4. ⏳ Custom Reverse Days Countdown Timers
* Create countdown timers for any vehicle or personal task (*Chain Lube*, *Air Filter Cleaning*, *Bike Insurance*, *Token Tax*).
* **Live 1-Second Ticking Clock**: Real-time display of `DAYS : HOURS : MIN : SEC`.
* **Quick Presets**: `+3 Days`, `+7 Days`, `+15 Days`, `+30 Days`, `+60 Days`, or custom date & time picker.
* Visual percentage progress bar and alarm banner when expired.

### 5. 💰 Khaata (Personal Ledger, Salary & Full Reports)
* **Inflow**: Log monthly salary, freelance, business income, or bonus.
* **Outflow**: Log daily expenses categorized by *Fuel & Bike*, *Maintenance*, *Food*, *Grocery*, *Bills*, *Shopping*, etc.
* **Net Balance & Savings Card**: Live calculation of $\text{Balance} = \text{Total Income} - \text{Total Expenses}$.
* **Comprehensive Financial Report**: Category-wise breakdown with amounts, percentages, and color-coded visual progress bars.

### 6. 🎨 Google Pixel Material You (M3) Design
* Pixel Emerald and Coral dynamic tonal palettes.
* Rounded squircle cards (`BorderRadius.circular(24)`).
* 5-destination Google Pixel `NavigationBar` with pill indicators and notification alert badges.
* Full **Pixel OLED Dark Mode** and **Light Mode** toggle.

### 7. 🎬 Animated Welcome & Google Sign-In Flow
* **Animated Splash Screen**: Custom vector emblem scale-up, pulsating radar glow, and brand title reveal.
* **Google Account Chooser**: Official Google account picker modal displaying available Google accounts.
* **First-Time Vehicle Setup Wizard**: Configures bike model, number plate, tank capacity in liters, baseline odometer, and reminder intervals.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (version 3.24+ / 3.47+)
* Java OpenJDK 17
* Android SDK (API 34+)

### Run Locally on Laptop (Web)
```bash
flutter run -d chrome
```

### Run on Android Device / Emulator
```bash
flutter run
```

### Build Android Release APK
```bash
flutter build apk --release
```
The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk` (and in [`app/motopulse.apk`](app/motopulse.apk)).

---

## 📂 Project Structure
```
lib/
├── main.dart                          # App entrypoint & Pixel navigation shell
├── theme/
│   └── app_theme.dart                 # Google Pixel Material 3 Light & Dark themes
├── models/
│   ├── fuel_entry.dart                # Fuel & mileage data model
│   ├── maintenance_settings.dart      # 1,000 KM oil & 2-month tuning settings
│   ├── countdown_timer_item.dart      # Reverse days timer data model
│   ├── khaata_entry.dart              # Salary & expense ledger model
│   └── user_profile.dart              # Gmail profile & cloud sync model
├── providers/
│   └── app_provider.dart              # Central reactive state manager
├── services/
│   ├── storage_service.dart           # Offline persistence via SharedPreferences
│   └── sync_service.dart              # Cloud sync & data export service
├── screens/
│   ├── splash_screen.dart             # Animated welcome screen
│   ├── google_sign_in_screen.dart     # Google account chooser screen
│   ├── vehicle_setup_screen.dart      # First-time bike onboarding wizard
│   ├── home_dashboard_screen.dart     # Pixel home dashboard & urgent alerts
│   ├── fuel_tracker_screen.dart       # Fuel fill-ups & mileage average tracker
│   ├── reminders_screen.dart          # Maintenance & reverse days timers
│   ├── khaata_screen.dart             # Salary, expenses & financial report
│   └── profile_sync_screen.dart       # Google account, sync & bike settings
└── widgets/
    ├── motopulse_logo.dart            # Custom vector logo & app icon
    ├── pixel_stat_card.dart           # Reusable metric card
    ├── countdown_card.dart            # Live ticking reverse countdown card
    ├── maintenance_card.dart          # Oil change & tuning progress card
    ├── add_entry_sheets.dart          # Bottom sheets for data entry
    └── report_and_settings_dialogs.dart # Financial report & settings dialogs
```

---

## 📄 License
This project is open-source under the MIT License.
