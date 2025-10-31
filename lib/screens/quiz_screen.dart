import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lesson_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;
  QuizScreen({required this.lessonId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QuizQuestion> quizQuestions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool isAnswered = false;
  String selectedAnswer = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuiz();
  }

  void fetchQuiz() async {
    try {
      if (widget.lessonId.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      DocumentSnapshot lessonDoc = await _firestore
          .collection("tamil_lessons")
          .doc(widget.lessonId)
          .get();

      if (!lessonDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic>? lessonData =
          lessonDoc.data() as Map<String, dynamic>?;

      if (lessonData == null ||
          !lessonData.containsKey('quiz') ||
          lessonData['quiz'] == null) {
        setState(() => isLoading = false);
        return;
      }

      List<QuizQuestion> fetchedQuestions =
          (lessonData['quiz'] as List<dynamic>)
              .map((quizData) => QuizQuestion.fromFirestore(quizData))
              .toList();

      setState(() {
        quizQuestions = fetchedQuestions;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void saveQuizScoreAndProgress() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userRef = _firestore.collection('users').doc(user.uid);

    try {
      // 🔹 Fetch user document
      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) {
        print(
            "❌ Error: User document does not exist! Creating a new document...");
        await userRef.set({
          "progress": {
            "completedLessons": [],
            "percentage": 0.0,
          },
        });
      }

      // 🔹 Update completed lessons
      await userRef.update({
        "progress.completedLessons": FieldValue.arrayUnion([widget.lessonId]),
      });

      // 🔹 Fetch total lessons count
      QuerySnapshot lessonSnapshot =
          await _firestore.collection("tamil_lessons").get();
      int totalLessons = lessonSnapshot.size; // Total lessons in Firestore
      print("📚 Total Lessons: $totalLessons");

      // 🔹 Get updated completed lessons count
      DocumentSnapshot updatedUserDoc = await userRef.get();
      List completedLessons = (updatedUserDoc.data()
              as Map<String, dynamic>)["progress"]["completedLessons"] ??
          [];

      int completedCount = completedLessons.length;
      print("🏆 Completed Lessons: $completedCount");

      // 🔹 Calculate progress percentage
      double progressPercentage = (completedCount / totalLessons) * 100;
      print("✅ Updated Progress: $progressPercentage%");

      // 🔹 Store progress percentage in Firestore
      await userRef.update({
        "progress.percentage": progressPercentage,
      });

      print("✅ Quiz score & progress updated successfully!");
    } catch (e) {
      print("❌ Error saving quiz progress: $e");
    }
  }

  void checkAnswer(String answer) {
    setState(() {
      isAnswered = true;
      selectedAnswer = answer;
      if (answer == quizQuestions[currentQuestionIndex].correctAnswer) {
        correctAnswers++;
      }
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if (currentQuestionIndex < quizQuestions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isAnswered = false;
          selectedAnswer = "";
        });
      } else {
        showQuizSummary();
        saveQuizScoreAndProgress();
      }
    });
  }

  void showQuizSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Quiz Completed!",
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Your Score: $correctAnswers / ${quizQuestions.length}",
                  style:
                      GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: correctAnswers / quizQuestions.length,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  correctAnswers / quizQuestions.length > 0.7
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Back to Lessons",
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentQuestionIndex = 0;
                  correctAnswers = 0;
                  isAnswered = false;
                  selectedAnswer = "";
                });
                Navigator.pop(context);
              },
              child: Text("Retry Quiz",
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.orangeAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Quiz",
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()
                  .animate()
                  .fadeIn(duration: 400.ms))
          : quizQuestions.isEmpty
              ? Center(
                  child: Text("No Quiz Available",
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white70)))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Question Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Question ${currentQuestionIndex + 1} / ${quizQuestions.length}",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text("Score: $correctAnswers",
                              style: GoogleFonts.poppins(
                                  fontSize: 18, color: Colors.greenAccent)),
                        ],
                      ).animate().fadeIn(duration: 400.ms),

                      SizedBox(height: 20),

                      // 🔹 Question Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.white.withOpacity(0.1),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            quizQuestions[currentQuestionIndex].question,
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideX(begin: -0.5, end: 0),

                      SizedBox(height: 20),

                      // 🔹 Answer Options
                      ...quizQuestions[currentQuestionIndex]
                          .options
                          .map<Widget>((option) {
                        bool isCorrect = option ==
                            quizQuestions[currentQuestionIndex].correctAnswer;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedAnswer == option
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : Colors.blueAccent,
                              minimumSize: Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed:
                                isAnswered ? null : () => checkAnswer(option),
                            child: Text(
                              option,
                              style: GoogleFonts.poppins(
                                  fontSize: 18, color: Colors.white),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.5, end: 0),
                        );
                      }).toList(),

                      Spacer(),

                      // 🔹 Next Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentQuestionIndex <
                                quizQuestions.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                                isAnswered = false;
                                selectedAnswer = "";
                              });
                            } else {
                              showQuizSummary();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text("Next",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ).animate().fadeIn(duration: 600.ms),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
