import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void loginWithEmail() async {
    setState(() => isLoading = true);
    User? user = await _authService.loginWithEmail(
        emailController.text, passwordController.text);
    setState(() => isLoading = false);
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Failed")));
    }
  }

  void loginWithGoogle() async {
    setState(() => isLoading = true);
    User? user = await _authService.signInWithGoogle();
    setState(() => isLoading = false);
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Google Sign-In Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome Back!",
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.5, end: 0),

                SizedBox(height: 10),
                Text("Login to continue your language journey",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white70))
                    .animate()
                    .fadeIn(duration: 500.ms),

                SizedBox(height: 40),

                // Email TextField
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  style: TextStyle(color: Colors.white),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.5, end: 0),

                SizedBox(height: 20),

                // Password TextField
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  style: TextStyle(color: Colors.white),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.5, end: 0),

                SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.5, end: 0),

                SizedBox(height: 20),

                // Google Sign-In Button
                OutlinedButton.icon(
                  onPressed: loginWithGoogle,
                  icon: Icon(Icons.login, color: Colors.white),
                  label: Text("Login with Google",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    side: BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0),

                SizedBox(height: 20),

                // Navigate to Signup
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupScreen())),
                  child: Text("Don't have an account? Sign up",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
