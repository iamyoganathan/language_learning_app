import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Home",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator().animate().fadeIn());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text("No User Data Available",
                    style: TextStyle(color: Colors.white)));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 User Profile Section
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.blueGrey[800]!.withOpacity(0.7),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: userData?['profilePic'] != null &&
                              userData!['profilePic'] != ""
                          ? NetworkImage(userData!['profilePic'])
                          : const AssetImage('lib/assets/images/profile.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      userData?['name'] ?? "User",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      userData?['email'] ?? "No Email",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.5, end: 0),

                const SizedBox(height: 20),

                // 🔹 Tamil Lessons Button
                _buildButton(
                  label: "Start Learning Tamil",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LessonScreen()),
                  ),
                  color: Colors.orangeAccent,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.5, end: 0),

                const SizedBox(height: 30),

                // 🔹 Logout Button
                // Center(
                //   child: _buildButton(
                //     label: "Logout",
                //     onPressed: _logout,
                //     color: Colors.red,
                //     icon: Icons.logout,
                //   )
                //       .animate()
                //       .fadeIn(duration: 800.ms)
                //       .slideY(begin: 0.5, end: 0),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Logout Function
  // void _logout() async {
  //   await _authService.signOut();
  //   if (mounted) {
  //     Navigator.pushReplacementNamed(context, '/login');
  //   }
  // }

  // ✅ Custom Button Widget
  Widget _buildButton(
      {required String label,
      required VoidCallback onPressed,
      required Color color,
      IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox(),
      label: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
