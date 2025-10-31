import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Fetch all Tamil lessons from Firestore
  Future<List<Lesson>> getLessons() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection("tamil_lessons").orderBy("title").get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Lesson.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching lessons: $e");
      return [];
    }
  }
}
