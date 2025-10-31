# 🌏 Language Learning App

<div align="center">
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.6.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-3.6.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

  **An interactive Flutter application for learning Tamil language with engaging lessons, quizzes, and progress tracking.**

</div>

---

## 📖 About

The **Language Learning App** is a comprehensive mobile application built with Flutter that helps users learn Tamil through structured lessons, interactive quizzes, and personalized progress tracking. The app leverages Firebase for authentication, cloud storage, and real-time data synchronization.

### ✨ Key Features

- 🔐 **User Authentication** - Secure sign-up/login with Firebase Auth and Google Sign-In
- 📚 **Interactive Lessons** - Structured Tamil language lessons with detailed content
- 🎯 **Quiz System** - Test your knowledge with interactive quizzes after each lesson
- 📊 **Progress Tracking** - Real-time progress monitoring with completion percentages
- 👤 **User Profiles** - Personalized user profiles with customizable avatars
- 🔊 **Audio Support** - Text-to-speech functionality for pronunciation
- 🎤 **Speech Recognition** - Practice speaking with speech-to-text capabilities
- 🎨 **Beautiful UI** - Modern, animated interface with Google Fonts and Flutter Animate
- 💾 **Cloud Storage** - All data synced with Cloud Firestore

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.6.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (3.6.0 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Account** - [Create Firebase Project](https://firebase.google.com/)
- **Git** - [Install Git](https://git-scm.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/iamyoganathan/language_learning_app.git
   cd language_learning_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   > ⚠️ **Important**: You need to set up your own Firebase project
   
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add an Android and/or iOS app to your Firebase project
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`
   - Enable **Firebase Authentication** (Email/Password and Google Sign-In)
   - Enable **Cloud Firestore** database
   - Set up Firestore security rules as needed

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

> *Add your app screenshots here to showcase the UI*

| Home Screen | Lessons | Quiz | Profile |
|------------|---------|------|---------|
| ![Home](https://via.placeholder.com/200x400) | ![Lessons](https://via.placeholder.com/200x400) | ![Quiz](https://via.placeholder.com/200x400) | ![Profile](https://via.placeholder.com/200x400) |

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── models/
│   └── lesson_model.dart        # Data models for lessons and quizzes
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # User login interface
│   │   └── signup_screen.dart   # User registration interface
│   ├── home_screen.dart         # Main dashboard
│   ├── lesson_screen.dart       # Lesson listing screen
│   ├── lesson_detail_screen.dart # Detailed lesson view
│   ├── quiz_screen.dart         # Interactive quiz interface
│   └── profile_screen.dart      # User profile management
├── services/
│   ├── auth_service.dart        # Authentication logic
│   └── lesson_service.dart      # Lesson data management
└── assets/
    └── images/
        └── profile.png          # Default profile image
```

---

## 🛠️ Technologies & Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.12.0 | Firebase initialization |
| `firebase_auth` | ^5.5.0 | User authentication |
| `cloud_firestore` | ^5.6.4 | Cloud database |
| `google_sign_in` | ^6.2.2 | Google authentication |
| `google_fonts` | ^6.2.1 | Custom typography |
| `flutter_animate` | ^4.5.2 | Animations |
| `flutter_animator` | ^3.2.2 | Advanced animations |
| `audioplayers` | ^6.2.0 | Audio playback |
| `flutter_tts` | ^4.2.2 | Text-to-speech |
| `speech_to_text` | ^7.0.0 | Speech recognition |
| `string_similarity` | ^2.1.1 | Text comparison |

---

## 🔥 Firebase Configuration

### Firestore Database Structure

```javascript
// Users Collection
users/{userId}
  ├── name: string
  ├── email: string
  ├── profilePic: string (URL)
  └── progress: {
      ├── completedLessons: array
      └── percentage: number
  }

// Lessons Collection
tamil_lessons/{lessonId}
  ├── title: string
  ├── description: string
  ├── content: string
  ├── level: string
  └── quiz: array [
      ├── question: string
      ├── options: array
      └── correctAnswer: string
  ]
```

### Security Rules (Example)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /tamil_lessons/{lessonId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write
    }
  }
}
```

---

## 🎯 Features in Detail

### 🔐 Authentication
- Email/Password authentication
- Google Sign-In integration
- Secure session management
- Auto-login functionality

### 📚 Lessons
- Progressive learning structure
- Rich content with images and audio
- Text-to-speech for pronunciation
- Bookmarking favorite lessons

### 🎯 Quizzes
- Multiple-choice questions
- Instant feedback
- Score tracking
- Progress calculation
- Retry functionality

### 📊 Progress Tracking
- Percentage-based progress
- Completed lessons tracking
- Visual progress indicators
- Real-time synchronization

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Format code using `flutter format .`

---

## 🐛 Known Issues & Roadmap

### Current Issues
- [ ] iOS Firebase configuration needs testing
- [ ] Audio playback may have latency on some devices

### Roadmap
- [ ] Add more languages (French, Spanish, etc.)
- [ ] Implement flashcard system
- [ ] Add gamification with badges and achievements
- [ ] Offline mode support
- [ ] Social features (leaderboards, friends)
- [ ] Dark mode theme
- [ ] Voice conversation practice
- [ ] Admin panel for content management

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Yoganathan**
- GitHub: [@iamyoganathan](https://github.com/iamyoganathan)
- Repository: [language_learning_app](https://github.com/iamyoganathan/language_learning_app)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Fonts for beautiful typography
- Flutter community for helpful packages and resources

---

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on [GitHub Issues](https://github.com/iamyoganathan/language_learning_app/issues)
- Check the [Flutter documentation](https://flutter.dev/docs)
- Visit [Firebase documentation](https://firebase.google.com/docs)

---

<div align="center">
  
  **Made with ❤️ using Flutter**
  
  ⭐ Star this repository if you find it helpful!

</div>
