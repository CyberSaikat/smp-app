<p align="center">
  <img src="https://raw.githubusercontent.com/CyberSaikat/smp-app/main/assets/images/Smart.png" alt="Leading Image" width="100%">
</p>

# 🎓 Student Management Portal (SMP)

Student Management Portal (SMP) is a comprehensive mobile application built with Flutter, designed to streamline the management of students and teachers in educational institutions. The app offers a user-friendly interface that allows both students and teachers to perform various tasks related to their academic activities efficiently.

## ✨ Features

### 🧑‍🎓 Student Features

- **📝 Registration and Login**

  - Secure registration and login process.
  - Option for admin approval or immediate account activation.
  - Ability to reinstate deleted accounts.

- **📅 Dashboard**

  - View daily class schedule with subject, time, and other relevant details.
  - QR Scanner feature for easy attendance marking.

- **🔔 Notification Page**

  - Stay updated on class rescheduling or other important information.

- **👤 Profile Management**
  - View and update personal information.

### 🧑‍🏫 Teacher Features

- **📝 Registration and Login**

  - Secure registration and login process.
  - Option for admin approval or immediate account activation.
  - Ability to reinstate deleted accounts.

- **📅 Dashboard**

  - Filter and view daily class schedules based on semester and department.
  - Take attendance using the QR Scanner feature.

- **📋 Student List Management**

  - View students by filtering based on semester and department.
  - Verify newly registered students and update their status.

- **📚 Subject Management**

  - Add or remove subjects within their respective departments.

- **🗓️ Class Rescheduling**

  - Reschedule classes when necessary.

- **🗒️ Class Schedule Management**

  - Set the weekly schedule for subjects.

- **🔗 Generate QR Codes**

  - Generate QR codes for attendance with details like subject, department, and semester.

- **📊 Export Data**
  - Generate and export Excel files containing attendance records or other relevant data.

## 🛠️ Technologies Used

- **🎨 Frontend**: Flutter (Dart)
- **🔥 Backend**: Firebase (Firestore, Authentication)
- **🔗 QR Code Generation**: Third-party library or API
- **📊 Excel File Generation**: Third-party library or API

## 🚀 Installation and Setup

1. **📂 Clone the repository**:
   ```bash
   git clone https://github.com/CyberSaikat/smp-app.git
   ```
2. **📦 Install dependencies**:
    ```bash
    flutter pub get
    ```
3. **⚙️ Set up Firebase**:
    - Go to the Firebase Console, create a new project, and add your Android/iOS app.
    - Download the google-services.json file for Android or GoogleService-Info.plist file for iOS and place them in the respective directories of your Flutter project.
    - Configure Firebase Authentication, Firestore, and any other necessary services.
4. **🔧 Set up environment variables**:
    - Configure any necessary API keys or configuration in a .env file.
5. **▶️ Run the app**:
    ```bash
    flutter run
    ```
6. **📦 Build for production**:
    - Use the following command to create a production build:
    ```bash
    flutter build apk
    ```
    - The APK will be located in the build/app/outputs/flutter-apk/ directory.
## **🤝 Contributing**
Contributions to the Student Management Portal project are welcome! If you encounter any issues or have suggestions for improvements, feel free to open a new issue or submit a pull request.

## **📄 License**
This project is licensed under the MIT License.