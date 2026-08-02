# MedicalHand - Healthcare Appointment & Management App

![Project Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Flutter_iOS_%26_Android-blue)
![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28)

**MedicalHand** is a mobile application developed in **Flutter** with a **Firebase** backend, designed for patients, families, and caregivers seeking a more agile, reliable, and transparent healthcare experience. The application streamlines medical scheduling and enhances accessibility.

The main objective is to empower users with limited time, chronic patients, caregivers, and older adults by providing a centralized and accessible digital healthcare tool.

---

## Key Features

| Feature | Description |
|---------------|-------------|
| **Appointment Scheduling** | Select specialty, healthcare center/hospital, date, and time. |
| **Appointment Management** | View, modify, or cancel confirmed appointments. |
| **Basic Medical History** | View registered diagnoses, past appointments, and treatments. |
| **User Profile** | Personal data, contact information, and preferred center/guardian preferences. |
| **Reminders** | Automated push notifications (24h / 48h prior to appointments). |
| **Virtual Queues** | Allows users to join a virtual queue for administrative assistance. |
| **Authentication** | Secure Email/Password and Google Sign-In via Firebase Auth. |
| **File Storage** | Upload document photos and relevant medical images. |
| **Connectivity Handling** | Offline alerts and basic network state management. |

---

## Tech Stack & Requirements

- **Language / Framework**: Dart / Flutter (SDK version 3.35.3)
- **Backend Services**: Firebase (Auth, Firestore, Storage, Messaging, App Check, Functions)

### Core Dependencies:
- State Management: `provider`, `get_it`
- Firebase Integration: `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`, `firebase_app_check`
- UI & Assets: `cupertino_icons`, `lottie`, `hugeicons`, `google_fonts`, `shimmer`
- Utilities: `image_picker`, `connectivity_plus`, `intl`, `flutter_local_notifications`

*(See `pubspec.yaml` for the complete list of dependencies).*

---

## Installation & Setup

Follow these steps to configure the project locally:

1. **Install Flutter SDK:** Ensure you have Flutter version ≥ 3.35.3 installed.
   Verify your installation and environment configuration:
   ```bash
   flutter --version
   flutter doctor
Clone the repository:

Bash
git clone [https://github.com/ogarcore/MedicalHand.git](https://github.com/ogarcore/MedicalHand.git)
cd MedicalHand
Install dependencies:

Bash
flutter pub get
Configure Firebase:

Create a project in the Firebase Console.

Add the required credentials for Android (google-services.json) and iOS (GoogleService-Info.plist).

Enable the following services: Firestore, Authentication, Storage, Messaging, App Check, and Functions.

Configure appropriate Firestore security rules.

Run the application:
Launch an emulator or connect a physical device, then run:

Bash
flutter run
Project Structure
The codebase follows a clear separation of concerns, structured primarily into data, view, and view-model layers:

Plaintext
/lib
  ├── app/          # App configuration and routing
  ├── data/         # Models, repositories, and API/Firebase services
  ├── view/         # UI components, screens, and widgets
  ├── view_model/   # State management and business logic
  ├── firebase_options.dart
  └── main.dart
Best Practices & Future Improvements
Implement robust error handling with offline fallback mechanisms.

Add Internationalization (i18n) support for multiple languages.

Enhance accessibility features for users with visual or motor limitations.

Implement backend versioning and separate development/production environments.

Contributing
Contributions are welcome! To contribute:

Fork the repository.

Create a new branch (feature/your-feature-name or bugfix/issue-name).

Commit your changes and ensure everything works correctly.

Open a Pull Request detailing your improvements.

Note: Use flutter analyze and flutter format to maintain code cleanliness before submitting a PR.

License
This project is licensed under the MIT License. You are free to use and adapt it, though it is provided without warranties of any kind.

Developed by: Oliver García (Alter Default)
