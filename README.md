# 🛡️ CheckOutApp

CheckOutApp is a modern cross-platform mobile application built with **Flutter** and **Dart**. It is specifically designed to eliminate leaving-home or workplace anxiety by guiding users through a strict, step-by-step physical security checklist.

## ✨ Features

- **Multi-Mode Operation:**
  - 🏠 **Evden Çıkış Mode:** Tracks windows, plugs, stoves, and final door locking. Includes a "Uzun Süreli / Tatil Modu" toggle.
  - 🌙 **Gece Rutini Mode:** Ensures the house is secure before going to sleep for a peaceful night.
  - 🏬 **İşyerinden Çıkış Mode:** Tracks electronics, alarms, keys, and main gates. Includes a "Hafta Sonu / Uzun Kapanış" toggle.
- **Custom Task Creation:** Users can dynamically add and delete their own specific security checkpoints.
- **Local Persistence:** Uses `SharedPreferences` to save and display the exact date and time of the last completed check.
- **Haptic Feedback:** Vibrates on every successful check to give a concrete sense of assurance.

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (Cross-platform)
- **Language:** Dart
- **State & Storage:** SharedPreferences (Local JSON encoding/decoding)
- **Services:** Local Notifications & Haptic Feedback UI integration

## 🚀 How to Run Locally

1. Clone the repository:
```bash
   git clone https://github.com/Erentk/checkout-app.git
```

2. Navigate to the project folder and fetch dependencies:
```bash
   flutter pub get
```

3.Run the application:
```bash
   flutter run
```
