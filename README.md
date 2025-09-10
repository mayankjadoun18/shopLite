
# 🛒 ShopLite (Flutter E-Commerce App)

## 📌 Overview
ShopLite is a lightweight e-commerce app built with **Flutter**.  
It demonstrates end-to-end app flow with **authentication, catalog browsing, product detail, cart, favorites, and offline caching**.  

✅ Features:  
- Login & logout (token-based authentication with Fake Store API)  
- Catalog with **pagination, search, and category filters**  
- Product detail with **images, title, price, description, and rating**  
- **Favorites** saved across app restarts  
- **Cart** with add/remove/update & total calculation  
- **Checkout flow** with success screen  
- **Offline-first caching** (Hive + CachedNetworkImage)  
- Error handling & clean state management  

---

## 🖼️ Demo(video) & Screenshots 
https://drive.google.com/drive/folders/1y-I3WOWqXAsZ2Z90MeEALTYRhjW9OM_N?usp=sharing




## 🏗️ Architecture


flowchart TD
  UI[Presentation Layer\n(Screens, Widgets)] --> State[State Management\n(Riverpod/Provider)]
  State --> Repo[Repositories\n(API + Local Cache)]
  Repo --> API[Remote API\n(Fake Store API)]
  Repo --> Cache[Local Cache\n(Hive, Cache Manager)]


- **UI Layer** → Flutter screens, widgets, navigation  
- **State Layer** → Riverpod (chosen for simplicity & testability)  
- **Data Layer** → Repository pattern (separates API + local caching)  

---

## ⚡ State Management
- **Riverpod** used for reactive state (favorites, cart, auth).  
- Chosen because it’s:  
  - Test-friendly  
  - Removes boilerplate vs Provider  
  - Supports fine-grained state listening  

---

## ▶️ How to Run

### Android
```bash
flutter pub get
flutter run
```

 





## 🧪 Running Tests
```bash
flutter test
```
- Unit tests for repositories & providers  
- Widget tests for UI components  

---

## 📦 Caching & Offline Strategy
- **Products & details** cached in Hive (30 min TTL)  
- **Images** cached with CachedNetworkImage (disk cache)  
- When offline:  
  - Last catalog & product details load from cache  
  - Offline banner is shown  
  - API calls skipped until reconnect  

---

## ⚠️ Trade-offs & Limitations
- Uses Fake Store API (no real orders placed).  
- Authentication limited to demo accounts.  
- Caching is TTL-based, not advanced invalidation.  
- No push notifications or payments (future work).  

---

## 👨‍💻 Tech Stack
- **Flutter** (Dart)  
- **Riverpod** (State Management)  
- **Dio** (Networking)  
- **Hive** (Local Storage)  
- **CachedNetworkImage** (Image caching)  

---

## 🚀 Getting Started
1. Clone the repo  
   ```bash
   git clone https://github.com/mayankjadoun18/shopLite.git
   ```
2. Install dependencies  
   ```bash
   flutter pub get
   ```
3. Run on emulator or device  
   ```bash
   flutter run
   ```





## 🔑 Login Credentials (Fake Store API)
Test accounts (use these as username + password)
Use these credentials to log in and test authentication:

- **Username:** `mor_2314`  
  **Password:** `83r5^_`

- **Username:** `johnd`  
  **Password:** `m38rmF$`

- **Username:** `donero`  
  **Password:** `ewedon`


⚠️ Note: The Fake Store API uses **username** for authentication.  
In this app, enter the username in the **Email field** along with the password.
⚠️ These credentials are provided by [Fake Store API](https://fakestoreapi.com/) and are **only for testing purposes**.



Note: DummyJSON / Fake Store auth endpoints expect username (not an email). Using these strings as username will work for testing.
