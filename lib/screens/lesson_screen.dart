import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lesson_model.dart';
import 'lesson_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LessonScreen extends StatefulWidget {
  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Lesson> lessons = [];
  List<String> completedLessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  /// 🔹 Fetch lessons & user progress from Firestore
  Future<void> loadLessons() async {
    try {
      print("📡 Fetching lessons from Firestore...");
      QuerySnapshot lessonSnapshot =
          await _firestore.collection("tamil_lessons").orderBy("title").get();

      if (lessonSnapshot.docs.isEmpty) {
        print("⚠️ No lessons found in Firestore!");
        setState(() => isLoading = false);
        return;
      }

      List<Lesson> fetchedLessons = lessonSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        print("✅ Lesson Fetched: ${data['title']} - ID: ${doc.id}");
        return Lesson.fromJson(data);
      }).toList();

      await loadUserProgress();

      setState(() {
        lessons = fetchedLessons;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching lessons: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Fetch user's completed lessons from Firestore
  Future<void> loadUserProgress() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(user.uid).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey("progress")) {
        setState(() {
          completedLessons =
              List<String>.from(data["progress"]["completedLessons"] ?? []);
          print("🏆 Completed Lessons: $completedLessons");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Tamil Lessons",
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => isLoading = true);
              loadLessons();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator().animate().fadeIn())
          : lessons.isEmpty
              ? Center(
                  child: Text("No lessons available",
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white70)))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: lessons.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      bool isCompleted =
                          completedLessons.contains(lessons[index].id);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LessonDetailScreen(lesson: lessons[index]),
                          ),
                        ),
                        child: Card(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.85)
                              : Colors.orangeAccent.withOpacity(0.85),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    lessons[index].title,
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (isCompleted)
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 28),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.5, end: 0),
                      );
                    },
                  ),
                ),
    );
  }
}
