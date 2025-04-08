
# 📱 Smart Shelf System

An intelligent shopping app inspired by Amazon Go – built with **Flutter**, **Firebase**, and optional **Python (OpenCV)** backend. It supports real-time product tracking, cart management, and receipt generation.

---

## 🚀 Features

- 🔐 Firebase Auth login/signup (Web & Android)
- 🛒 Real-time shopping cart summary
- 📦 Product management (admin panel)
- 💸 Wallet with transaction history
- 📷 QR Code scanning for item interaction
- 📁 Receipt generation and download
- 📤 Firebase Storage for profile pictures
- 🎛️ Firebase Firestore for user and product data

---

## ⚙️ How It Works

1. **User Signup/Login (Flutter App)**  
   Users can register or log in using Firebase Authentication.

2. **Entry QR Code Generation**  
   After login, the app generates an **entry QR code**.

3. **QR Scan to Begin Shopping**  
   The Python script (`shelf_with_cart.py`) runs a camera scanner. When it scans the entry QR code, the cart summary screen opens for that user.

4. **Product Shelf Interaction (Live Camera)**  
   - When a **product QR code** is **in front of the camera**, it is considered “on the shelf”.
   - When the product is **removed from view**, it is **added to the cart**.

5. **Checkout Process**
   - After adding products, the user taps the **checkout** button in the app.
   - If the wallet has **sufficient balance**, a **checkout QR code** is generated.
   - Scanning the checkout QR code confirms purchase and completes the session.

---

## 📂 Project Structure

```bash
frontend_interface/       # Flutter frontend (Web + Android)
  ├── lib/
  ├── android/
  ├── web/
  ├── firebase.json
  └── pubspec.yaml

shelf_system/             # Python backend with OpenCV + Firebase
  ├── shelf_with_cart.py
  ├── firebase-adminsdk.json   # 🔒 Do not commit!
  ├── cart_summary.json
  └── products.json
```

---

## 🔧 Getting Started

### Flutter Setup

```bash
flutter pub get
flutter run -d chrome   # Or use Android emulator
```

### Python Backend

```bash
cd shelf_system
pip install -r requirements.txt
python shelf_with_cart.py
```

---

## 🔐 Firebase Setup

1. Add your `google-services.json` in `android/app/`
2. Add your `firebase_options.dart` using FlutterFire CLI
3. Ensure Firestore & Storage rules are set

---

## 📸 Screenshots

### 🔐 Login Screen
![Login](assets/screenshots/login.jpeg)

### 💳 Entry
![Entry](assets/screenshots/entry.jpeg)

### 🛒 Cart Summary
![Cart Summary](assets/screenshots/cart_summary.jpeg)

### 💳 Wallet
![Wallet](assets/screenshots/wallet.jpeg)

### 💳 Checkout
![Checkout](assets/screenshots/Checkout.jpeg)

### 🧾 Receipt
![Receipt](assets/screenshots/receipt.jpeg)

---

## ⚠️ Security Note

This repo uses Firebase – **DO NOT** commit:
- `firebase-adminsdk.json`
- `google-services.json`
- `.env` files with API keys or credentials

---

## 🧠 Author

- **HASIN SWALAH VP** – Developer & Creator of Smart Shelf System

---

## 📄 License

Copyright © 2025 HASIN SWALAH VP

All rights reserved.

This source code is proprietary and confidential. Unauthorized copying, modification, distribution, or use of this code in any form is strictly prohibited without express permission from the author.

