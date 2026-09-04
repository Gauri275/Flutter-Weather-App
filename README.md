# 🌤️ Flutter Weather App

A beautiful, modern, and highly responsive weather application built with Flutter. This app provides real-time weather data, 5-day forecasts, and Air Quality Index (AQI) tracking using a polished, animated Glassmorphism interface.

## ✨ Features

* **Dynamic Gradient Backgrounds:** The app's UI automatically smoothly transitions between rich, 3-color gradients based on the current temperature and active weather conditions (e.g., dark, moody blues for thunderstorms).
* **Glassmorphism UI:** Implements modern frosted-glass design principles using `BackdropFilter` for a clean, uniform, and premium look.
* **Contextual Weather Emojis:** Uses WMO (World Meteorological Organization) weather codes to display accurate, dynamic emojis reflecting the current and forecasted weather.
* **Multiple API Integrations:** Concurrently fetches data from Open-Meteo's Forecast API, Geocoding API, and Air Quality API.
* **Local Data Persistence:** Uses `shared_preferences` to cache the user's last searched location, automatically loading it on startup to save battery and reduce network calls.
* **GPS & City Search:** Users can fetch their local weather via device GPS (`geolocator`) or search for any global city via the Geocoding API.
* **Pull-to-Refresh & Animations:** Features standard mobile pull-to-refresh functionality and smooth implicit animations (`AnimatedSwitcher`, `AnimatedContainer`) for seamless state transitions.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Weather & AQI Data:** [Open-Meteo API](https://open-meteo.com/) (Free, no API key required)
* **Key Packages:**
  * `http`: For asynchronous API requests and JSON parsing.
  * `geolocator`: For handling device GPS permissions and location tracking.
  * `shared_preferences`: For local device storage and caching.
  * `intl`: For standardizing and formatting dates and times.

## 📸 Screenshots

<img width="1887" height="872" alt="image" src="https://github.com/user-attachments/assets/a2c53f82-c6a8-4f85-b62d-3755dbca896e" />

<img width="1917" height="716" alt="image" src="https://github.com/user-attachments/assets/49d913af-3d01-40aa-96d9-802039dddff1" />


## 🚀 Getting Started

To run this project locally on your machine, ensure you have the Flutter SDK installed.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Gauri275/Flutter-Weather-App.git
   
2. **Navigate to directory**
   cd weather_app
   
3. **Install Dependencies**
   flutter pug get
   
4. **Run the App**
   flutter run


This project is a starting point for a Flutter application.
