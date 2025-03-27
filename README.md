# 💱 Real-Time Currency Exchange Tracker

This is a SwiftUI mobile application built for the **AHB Mobile Engineer Assignment**. It allows users to track real-time exchange rates for selected fiat and crypto currencies with persistent state, offline fallback, and reactive updates.

Please Note: Rates API is very unstable for free version

Demo
https://youtube.com/shorts/pPfhyMQneM0?feature=share


---

## 📌 Features

- View a list of selected fiat and crypto currencies with live exchange rates
- Add or remove assets from your personalized list
- Search for currencies using a searchable screen
- Persist selected assets between app launches
- Fallback to previously cached rates from local database (Core Data)
- Auto-refresh rates every 60 seconds
- Error handling for network/API issues
- Basic unit test examples provided

---

## 🧠 Architecture

The app follows a **Clean Architecture** structure, promoting a clear separation of concerns between:

- **Presentation Layer** — built with `SwiftUI`, `MVVM`, and a `Coordinator` pattern for navigation and dependency injection
- **Domain Layer** — contains business logic and use cases (e.g., search, observe, delete, save)
- **Data Layer** — manages fetching data from network APIs and Core Data

---

## 🔁 Concurrency

The app uses **Combine** as the main concurrency and reactive programming tool. All use cases and data flows are built with publishers to ensure reactivity and composability.

---

## 🛠 Tech Stack

- **SwiftUI** for UI and navigation
- **Combine** for reactive logic and state updates
- **MVVM + Coordinator** for presentation
- **Core Data** for persistence and caching
- **CoinGecko API** for real-time FX and crypto rates (free tier)
- **OpenExchangeRates API** for real-time FX rates (free tier)

---

## 🧪 Unit Tests

Included unit test examples to demonstrate use case testing and dependency injection.

- Mocked repositories
- Use cases isolated with test data

---

## 🧩 Design Decisions

- The **single source of truth** for exchange data is the **local database**, ensuring the app can operate with previously fetched data if offline.
- API responses are saved into Core Data and reused in fallback scenarios.
- The refresh interval is set to **60 seconds** due to **harsh request limits** imposed by the free tier of public APIs (especially CoinGecko).
- The app fetches and coordinates data from two public APIs. The two data sources are combined into a unified currency model and presented seamlessly to the user. This architecture allows for separation of logic between gateways while maintaining a single source of truth for all assets in the app.

---

## 🚧 Limitations

- Free APIs (like CoinGecko) have low rate limits, which may lead to occasional delays or missing updates and errors.
- No backend integration — all data is pulled client-side.
- Exchange rate updates are not precisely "real-time" due to the rate limit restrictions.

---

## 🧪 Setup Instructions

1. Clone or unzip the repository
2. Open in Xcode 15+
3. Run on iOS Simulator or device (iOS 16+)
4. No API key required (CoinGecko is used without auth)

---

## 📷 Screenshots (Optional)

![IMG_9180](https://github.com/user-attachments/assets/7c73ccdc-fb2c-473a-846f-833b7d06940a)
![IMG_9181](https://github.com/user-attachments/assets/89f9fd01-6585-45d7-9eb9-d6e285cc33ab)
![IMG_9182](https://github.com/user-attachments/assets/9acc493e-82da-483d-a417-d33e9f90fac0)

---

## 📦 Dependencies

- None (uses built-in Apple frameworks only)

---

## 📄 License

This project is provided as part of a coding assignment and is not intended for production use.
