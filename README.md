# Kijani PGC App

## Overview

The **Kijani PGC App** is a Flutter-based mobile application designed for Plantation Growth Coordinators (PGCs) to streamline data collection and editing tasks. The app enables PGCs to update garden data, perform survival checks, and manage related information efficiently. It integrates with Airtable for data storage, supports image uploads to S3, and provides offline capabilities through local storage.

### Key Features
- **Data Collection**: Collect garden data, including survival checks, with support for geolocation and image capture.
- **Data Editing**: Update existing garden data and sync changes with Airtable.
- **Offline Support**: Store data locally using `get_storage` for offline access and sync when online.
- **Image Handling**: Capture images, manage EXIF data, and upload to S3 storage.
- **User Authentication**: Secure login and user management for PGCs.
- **In-App Updates**: Notify users of available updates using `in_app_update`.

---

## Folder Structure

The project follows a clean and modular architecture to ensure maintainability and scalability. Below is an explanation of the folder structure with emojis for better visualization:

```
lib/
├── 📁 components/           # Reusable UI components (e.g., buttons, cards, forms)
├── 📁 controllers/          # Business logic controllers (e.g., GetX controllers for state management)
├── 📁 models/               # Data models (e.g., Parish, User, Garden)
├── 📁 repositories/                 # Repositories for data operations (e.g., fetching/saving data to Airtable or local storage)
├── 📁 routes/               # Navigation routes and screen definitions
|── 📁 screens/              # Main app screens (e.g., Auth, Home, Parish, Reports, Syncing)
│   ├── 📁 auth/             # Authentication screens (e.g., login, signup)
│   ├── 📁 home/             # Home screen for the app
│   ├── 📁 parish/           # Screens for managing parish-related data
│   ├── 📁 reports/          # Screens for viewing and generating reports
│   └── 📁 syncing/          # Screens for data synchronization (online/offline)
├── 📁 services/             # Services for external integrations (e.g., Airtable, S3, storage)
├── 📁 utilities/            # Helper functions and utilities (e.g., constants, formatters)
└── 📄 main.dart             # Entry point of the application
```

### Folder Details
- **📁 `components/`**: Contains reusable UI widgets like buttons, text fields, and loading indicators to maintain consistency across the app.
- **📁 `controllers/`**: Houses GetX controllers that manage the app's state and business logic, such as form validation or API calls.
- **📁 `models/`**: Defines data models (e.g., `Parish`, `User`) used to structure data fetched from Airtable or stored locally.
- **📁 `repositories/`**: Contains repository classes that handle data operations, such as fetching parishes from Airtable or saving them locally.
- **📁 `routes/`**: Manages navigation and screen definitions:
  - **📁 `screens/`**: Organizes the app's main screens into subfolders:
    - **📁 `auth/`**: Screens for user authentication (e.g., login, logout).
    - **📁 `home/`**: The main dashboard screen for PGCs.
    - **📁 `parish/`**: Screens for managing parish data, such as garden updates.
    - **📁 `reports/`**: Screens for generating and viewing reports on garden data.
    - **📁 `syncing/`**: Screens for handling data synchronization between local storage and Airtable.
- **📁 `services/`**: Includes service classes for interacting with external APIs (e.g., Airtable, S3) and local storage (e.g., `get_storage`).
- **📁 `utilities/`**: Stores helper functions, constants, and utilities like date formatters or network checkers.
- **📄 `main.dart`**: The entry point of the app, where the app is initialized and the root widget is defined.

---

## Dependencies

The app relies on several Flutter packages to provide its functionality. Below is a list of the dependencies and their purposes:

### Dependencies
- **in_app_update: ^4.2.3**: Enables in-app updates for Android, notifying users of new versions.
- **google_fonts: ^6.2.1**: Allows the use of Google Fonts for consistent typography.
- **loading_animation_widget: ^1.2.1**: Adds customizable loading animations for better UX.
- **get: ^4.6.6**: A state management, dependency injection, and navigation library for Flutter.
- **image_picker: ^1.1.2**: Enables image selection from the gallery or camera.
- **geolocator: ^13.0.1**: Provides geolocation services to capture the user's location.
- **s3_storage**: Custom package for uploading images to AWS S3 (sourced from GitHub).
- **native_exif: ^0.6.0**: Manages EXIF data for images (e.g., adding geolocation metadata).
- **path_provider: ^2.1.5**: Provides access to device file paths for storing files.
- **hugeicons: ^0.0.10**: A library for additional icons used in the app.
- **airtable_crud: ^1.2.4**: Simplifies CRUD operations with Airtable as the backend.
- **badges: ^3.1.2**: Adds badge widgets (e.g., for notifications or counts).
- **get_storage: ^2.1.1**: A lightweight key-value storage solution for offline data persistence.


---

## Setup Instructions

### Prerequisites
- **Flutter SDK**: Version 3.5.3 or higher.
- **Dart SDK**: Included with Flutter.
- **IDE**: Android Studio, VS Code, or any IDE with Flutter support.
- **Airtable Account**: For backend data storage.
- **AWS S3**: For image storage (configure credentials in the app).

### Installation
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd kijani_pgc_app
   ```

2. **Install Dependencies**:
   Run the following command to install all required packages:
   ```bash
   flutter pub get
   ```

3. **Configure Airtable**:
   - Create an Airtable base with the required tables (e.g., `Parishes`, `Gardens`).
   - Obtain your Airtable API key and base ID.
   - Update the `services/airtable_services.dart` file with your Airtable credentials.

4. **Configure S3 Storage**:
   - Set up an AWS S3 bucket for image storage.
   - Configure AWS credentials in the app (e.g., in `services/s3_service.dart`).

5. **Run the App**:
   - Connect a device or start an emulator.
   - Run the app:
     ```bash
     flutter run
     ```

### Building for Release
To build the app for release (e.g., for Android):
```bash
flutter build apk --release
```
The APK will be generated in `build/app/outputs/flutter-apk/app-release.apk`.

---

## Usage

1. **Login**: PGCs must log in using their credentials via the authentication screens.
2. **Home Screen**: Access the main dashboard to navigate to different sections (e.g., Parish, Reports).
3. **Data Collection**:
   - Navigate to the `Parish` section to collect garden data.
   - Use the camera to capture images and geolocation to tag the location.
4. **Data Editing**:
   - Update existing garden data or perform survival checks.
   - Changes are saved locally and can be synced with Airtable.
5. **Syncing**:
   - Use the `Syncing` screen to upload local data to Airtable when online.
6. **Reports**:
   - View and generate reports on garden data and survival checks.

