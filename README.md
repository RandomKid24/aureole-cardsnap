<div align="center">
  
  # 📇 CardSnap
  
  **Scan. Save. Connect.**
  
  *A premium, on-device business card scanner built with Flutter and the Beforth Brand Design System.*

  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
    <img src="https://img.shields.io/badge/ML%20Kit-4285F4?style=for-the-badge&logo=google&logoColor=white" />
    <img src="https://img.shields.io/badge/Drift-SQLite-blue?style=for-the-badge" />
  </p>
</div>

---

## ⚡ Overview

**CardSnap** is a highly optimized, beautifully designed application that instantly digitizes business cards. Using **Google ML Kit Document Scanner** and an intelligent on-device parsing engine, it securely extracts contact information entirely on your device—no internet connection required.

## ✨ Features

- **📸 Instant Scanning:** Hardware-accelerated document scanning with auto-crop and multi-page support.
- **🧠 Local Parsing Engine:** Fast and robust Regex-based extraction engine to identify names, phones, emails, and social media.
- **🎨 Premium UI/UX:** Built meticulously with the **Beforth Design System** featuring crisp typography, glassmorphism hints, and a custom dot-grid aesthetic.
- **🗃️ Complete Contact Management:** Save favorites, organize with tags, and set follow-up reminders.
- **🔄 Import & Export:** Share your entire library via `vCard (.vcf)` or `CSV` with a single tap.
- **🔒 100% On-Device:** Total privacy. Your contacts never leave your phone.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Local Database:** [Drift (SQLite)](https://drift.simonbinder.eu/)
- **State Management:** Provider
- **Routing:** GoRouter
- **Machine Learning:** Google ML Kit (Text Recognition & Document Scanning)
- **Styling:** Google Fonts (`Bebas Neue` & `Inter`), Custom Painters

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0 <4.0.0)
- iOS 12.0+ / Android 7.0+

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/bizman.git
   ```
2. **Navigate to project directory:**
   ```bash
   cd bizman
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🎨 Design System

CardSnap strictly adheres to the **Beforth Brand Guidelines**. 
See the detailed [DESIGN.md](./DESIGN.md) for typography logic, color palettes, and component styles.

---
<div align="center">
  <i>Crafted with passion using Flutter.</i>
</div>
