import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/lesson_service.dart';
import 'models/lesson_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();

    LessonService lessonService = LessonService();
    List<Lesson> lessons = await lessonService.getLessons();
    for (var lesson in lessons) {
      print("📖 Lesson: ${lesson.title} - ${lesson.description}");
    }

    runApp(MyApp());
  } catch (e) {
    print("❌ Firebase Initialization Error: $e");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Failed to initialize Firebase. Please try again later."),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Example: Custom font
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => AuthWrapper(child: HomeScreen()),
        '/profile': (context) => AuthWrapper(child: ProfileScreen()),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget child;

  AuthWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user == null) {
      // Redirect to login if user is not authenticated
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
