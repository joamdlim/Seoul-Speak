import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication methods
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User profile methods
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.id).set(profile.toMap());
  }

  Stream<UserProfile> getUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => UserProfile.fromFirestore(doc));
  }

  Future<void> updateUserProgress(String userId, String lessonId, double progress) async {
    await _firestore.collection('users').doc(userId).update({
      'lessonProgress.$lessonId': progress,
    });
  }

  // Lesson methods
  Stream<List<Lesson>> getLessons() {
    return _firestore.collection('lessons').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Lesson.fromFirestore(doc))
              .toList(),
        );
  }

  Future<Lesson> getLesson(String lessonId) async {
    final doc = await _firestore.collection('lessons').doc(lessonId).get();
    return Lesson.fromFirestore(doc);
  }

  // Quiz methods
  Future<void> submitQuizResult(
      String userId, String lessonId, double score) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final currentProgress =
          (userDoc.data()?['lessonProgress']?[lessonId] ?? 0.0) as double;
      
      if (score > currentProgress) {
        transaction.update(userRef, {
          'lessonProgress.$lessonId': score,
          'totalXP': FieldValue.increment((score * 100).round()),
        });
      }
    });
  }

  // Flashcard methods
  Future<List<Flashcard>> getLessonFlashcards(String lessonId) async {
    final doc = await _firestore.collection('lessons').doc(lessonId).get();
    final lesson = Lesson.fromFirestore(doc);
    return lesson.flashcards;
  }
}