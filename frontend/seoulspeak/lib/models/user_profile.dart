import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final Map<String, double> lessonProgress;
  final int totalXP;
  final List<String> completedLessons;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    Map<String, double>? lessonProgress,
    this.totalXP = 0,
    List<String>? completedLessons,
  })  : lessonProgress = lessonProgress ?? {},
        completedLessons = completedLessons ?? [];

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      lessonProgress: Map<String, double>.from(data['lessonProgress'] ?? {}),
      totalXP: data['totalXP'] ?? 0,
      completedLessons: List<String>.from(data['completedLessons'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'lessonProgress': lessonProgress,
      'totalXP': totalXP,
      'completedLessons': completedLessons,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    Map<String, double>? lessonProgress,
    int? totalXP,
    List<String>? completedLessons,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      lessonProgress: lessonProgress ?? this.lessonProgress,
      totalXP: totalXP ?? this.totalXP,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }
}