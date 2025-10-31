class Lesson {
  final String id;
  final String title;
  final String description;
  final List<Map<String, String>> vocabulary;
  final String? audioUrl;
  final List<QuizQuestion> quiz; // ✅ Use QuizQuestion model instead of raw map

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.vocabulary,
    this.audioUrl,
    required this.quiz,
  });

  /// ✅ Convert JSON to Lesson Object
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',

      /// 🔹 Fix vocabulary parsing
      vocabulary: (json['vocabulary'] as List<dynamic>? ?? [])
          .map((item) => {
                "word": item["word"]?.toString() ?? '',
                "translation": item["translation"]?.toString() ?? '',
              })
          .toList(),

      audioUrl: json['audioUrl'],

      /// ✅ Parse quiz using QuizQuestion model
      quiz: (json['quiz'] as List<dynamic>? ?? [])
          .map((quizData) => QuizQuestion.fromFirestore(quizData))
          .toList(),
    );
  }

  /// ✅ Convert Lesson to JSON (Useful for Firestore storage)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "vocabulary": vocabulary,
      "audioUrl": audioUrl,
      "quiz": quiz.map((q) => q.toJson()).toList(), // ✅ Convert quiz to JSON
    };
  }
}

class QuizQuestion {
  String question;
  List<String> options;
  String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  /// ✅ Convert JSON to QuizQuestion Object
  factory QuizQuestion.fromFirestore(Map<String, dynamic> data) {
    return QuizQuestion(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
    );
  }

  /// ✅ Convert QuizQuestion to JSON (Useful for Firestore storage)
  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "options": options,
      "correctAnswer": correctAnswer,
    };
  }
}
