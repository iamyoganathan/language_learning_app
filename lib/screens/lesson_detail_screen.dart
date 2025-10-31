import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:string_similarity/string_similarity.dart';
import '../models/lesson_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quiz_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  LessonDetailScreen({required this.lesson});

  @override
  _LessonDetailScreenState createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool isSpeaking = false;
  bool isListening = false;
  String recognizedText = "";
  double accuracy = 0.0;
  String feedbackMessage = "Try pronouncing the word!";
  String currentWord = "";

  @override
  void initState() {
    super.initState();
    _speechToText.initialize();
  }

  /// 🔹 Speak the lesson text using TTS
  void _speakText(String text) async {
    await _flutterTts.setLanguage("ta-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    setState(() => isSpeaking = true);
    await _flutterTts.speak(text);
    setState(() => isSpeaking = false);
  }

  /// 🔹 Start listening for pronunciation feedback
  void _startListening(String correctWord) async {
    setState(() {
      currentWord = correctWord;
      recognizedText = "";
      accuracy = 0.0;
      feedbackMessage = "Listening...";
    });

    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => isListening = true);

      _speechToText.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
            _evaluatePronunciation();
          });
        },
        localeId: "ta-IN",
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 3),
      );
    }
  }

  /// 🔹 Stop listening and process the result
  void _stopListening() async {
    await _speechToText.stop();
    setState(() => isListening = false);
  }

  /// 🔹 Evaluate pronunciation using string similarity
  void _evaluatePronunciation() {
    accuracy = recognizedText.similarityTo(currentWord) * 100;
    setState(() {
      if (accuracy > 85) {
        feedbackMessage = "✅ Perfect! (${accuracy.toStringAsFixed(1)}%)";
      } else if (accuracy > 65) {
        feedbackMessage =
            "⚠️ Good, but improve it! (${accuracy.toStringAsFixed(1)}%)";
      } else {
        feedbackMessage = "❌ Try Again! (${accuracy.toStringAsFixed(1)}%)";
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.lesson.title,
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Lesson Description Card
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(widget.lesson.description,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70)),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _speakText(widget.lesson.description),
                      icon:
                          Icon(isSpeaking ? Icons.volume_off : Icons.volume_up),
                      label: Text(isSpeaking ? "Speaking..." : "Listen"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),

            SizedBox(height: 20),

            // 🔹 Vocabulary List
            Text("Vocabulary",
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
                .animate()
                .fadeIn(duration: 700.ms)
                .slideX(begin: -0.5, end: 0),

            Divider(color: Colors.white54),

            Column(
              children: widget.lesson.vocabulary.map((vocab) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.white.withOpacity(0.1),
                  child: ListTile(
                    title: Text(vocab["word"] ?? "Unknown",
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.white)),
                    subtitle: Text(
                        "Meaning: ${vocab["translation"] ?? "Unknown"}",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.white70)),
                    leading: Icon(Icons.translate, color: Colors.blueAccent),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.white),
                          onPressed: () => _speakText(vocab["word"] ?? ""),
                        ),
                        IconButton(
                          icon: Icon(Icons.mic,
                              color: isListening ? Colors.red : Colors.white),
                          onPressed: isListening
                              ? _stopListening
                              : () => _startListening(vocab["word"] ?? ""),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // 🔹 Pronunciation Feedback UI
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Your Pronunciation: $recognizedText",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: accuracy / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accuracy > 85
                            ? Colors.green
                            : (accuracy > 50 ? Colors.orange : Colors.red),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      feedbackMessage,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 700.ms),

            SizedBox(height: 20),

            // 🔹 Quiz Navigation Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (widget.lesson.id.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              QuizScreen(lessonId: widget.lesson.id)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Start Quiz",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
