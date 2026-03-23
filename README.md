# Skin Disease Diagnosis System

A mobile application built with **Flutter** and a **Flask + TensorFlow** backend that helps users perform preliminary skin disease detection from uploaded skin images. The system predicts possible skin conditions using a trained deep learning model and stores user detection records in **Firebase**.

## Technologies Used

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## Project Overview

This project was developed to provide a simple and accessible way for users to upload skin images and receive an early prediction of possible skin diseases. The application combines a mobile frontend, a machine learning inference backend, and Firebase services for authentication, storage, and data management.

The system is designed for **preliminary screening only** and should not be used as a replacement for professional medical diagnosis.

## UI Preview

## Features

- 🔐 User authentication with Firebase
- 🖼️ Upload skin images from gallery
- 🤖 Skin disease prediction using deep learning model
- 📊 Detection result display with confidence
- ☁️ Store user records in Firebase
- 📚 Skin disease information library
- 🩺 Treatment suggestion display

## System Architecture

### Firebase
Firebase is used for:
- Authentication
- Firestore database
- Image storage
- Detection record history

## Folder Structure

```bash
Skin-Disease-Diagnosis-System/
├── backend/
│   ├── flask/
│   │   └── app.py
│   └── requirements.txt
├── frontend/
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
└── README.md
```

## Local Deployment on Android Device

To achieve better performance and more accurate testing, this project should be run on a **physical Android phone** rather than a simulator or emulator. A real device provides a smoother experience for image upload, navigation, and end-to-end prediction flow.

Since the application depends on a **Flask backend model** for skin disease prediction, the backend service must be started first before launching the Flutter application. The mobile app sends the uploaded image to the backend API, so without the backend running, the prediction feature will not function properly.

### Setup Flow
1. Run the Flask backend server locally.
2. Ensure the Android phone and backend server are connected to the same network.
3. Configure the Flutter application to use the correct local IP address of the backend machine.
4. Launch the Flutter app on the physical Android device.
5. Test the full image upload and prediction process.

### Reminder
The backend server must remain active throughout the testing session, as the Flutter frontend relies on it for inference and result retrieval.

## 📬 Contact

I am actively seeking opportunities in software development, data engineering, and AI-related roles.
Feel free to reach out if you'd like to discuss this project or potential opportunities! 

- 👤 Zhu Ying  
- 📧 Email: angzhuying0301@gmail.com  
- 💼 LinkedIn: www.linkedin.com/in/ang-zhu-ying

⭐ Thank you for visiting this repository!

