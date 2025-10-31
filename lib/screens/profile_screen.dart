import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> quizHistory = [];
  bool isLoading = true;
  double progressPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    getUserStream();
    fetchQuizHistory();
  }

  /// 🔹 Fetch User Data & Calculate Progress
  Stream<DocumentSnapshot> getUserStream() {
    User? user = _auth.currentUser;
    return _firestore.collection('users').doc(user?.uid).snapshots();
  }

  /// 🔹 Fetch Quiz History from Firestore
  void fetchQuizHistory() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quiz_scores')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        quizHistory = snapshot.docs.map((doc) {
          return {
            "lessonId": doc["lessonId"],
            "score": doc["score"],
            "total": doc["total"],
            "timestamp": (doc["timestamp"] as Timestamp).toDate(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching quiz history: $e");
    }
  }

  /// 🔹 Logout User
  void logout() async {
    await _auth.signOut();
    Navigator.pop(context);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Profile",
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getUserStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: CircularProgressIndicator().animate().fadeIn());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          double progressPercentage =
              userData?['progress']['percentage'] ?? 0.0;
          List completedLessons =
              userData?['progress']['completedLessons'] ?? [];

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔹 Profile Info
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: userData?['profilePic'] != null
                          ? NetworkImage(userData!['profilePic'])
                          : AssetImage('lib/assets/images/profile.png')
                              as ImageProvider,
                    ),
                    title: Text(userData?['name'] ?? "User",
                        style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    subtitle: Text(_auth.currentUser?.email ?? "No Email",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey)),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.5, end: 0),

                SizedBox(height: 20),

                // 🔹 Progress Bar
                Text("Learning Progress",
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.5, end: 0),
                Divider(color: Colors.white54),

                SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white24,
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      height: 20,
                      width: MediaQuery.of(context).size.width *
                          (progressPercentage / 100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.5, end: 0),

                SizedBox(height: 10),
                Text("${progressPercentage.toStringAsFixed(1)}% Completed",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70))
                    .animate()
                    .fadeIn(duration: 800.ms),

                SizedBox(height: 30),

                // 🔹 Quiz History
                Text("Quiz History",
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.5, end: 0),
                Divider(color: Colors.white54),

                completedLessons.isEmpty
                    ? Text("No quizzes taken yet.",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white70))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: completedLessons.length,
                          itemBuilder: (context, index) {
                            var lesson = completedLessons[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.white.withOpacity(0.1),
                              child: ListTile(
                                title: Text("Lesson: $lesson",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18, color: Colors.white)),
                                trailing: Icon(Icons.history,
                                    color: Colors.orangeAccent),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 700.ms)
                                .slideY(begin: 0.5, end: 0);
                          },
                        ),
                      ),

                SizedBox(height: 30),

                // 🔹 Logout Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.logout),
                  label: Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.5, end: 0),
              ],
            ),
          );
        },
      ),
    );
  }
}
