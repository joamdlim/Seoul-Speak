import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../models/lesson.dart';

class LessonProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Lesson> _lessons = [];
  Lesson? _currentLesson;
  bool _isLoading = false;

  List<Lesson> get lessons => _lessons;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;

  LessonProvider() {
    _loadLessons();
  }

  void _loadLessons() {
    _isLoading = true;
    notifyListeners();

    _firebaseService.getLessons().listen((lessons) {
      _lessons = lessons;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> setCurrentLesson(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentLesson = await _firebaseService.getLesson(lessonId);
    } catch (e) {
      _currentLesson = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitQuizResult(String userId, String lessonId, double score) async {
    await _firebaseService.submitQuizResult(userId, lessonId, score);
  }

  Future<List<Flashcard>> getLessonFlashcards(String lessonId) async {
    return await _firebaseService.getLessonFlashcards(lessonId);
  }
}