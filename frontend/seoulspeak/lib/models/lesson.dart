import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final List<Flashcard> flashcards;
  final Quiz quiz;
  final double progress;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.flashcards,
    required this.quiz,
    this.progress = 0.0,
  });

  factory Lesson.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lesson(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      flashcards: (data['flashcards'] as List<dynamic>?)
          ?.map((e) => Flashcard.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      quiz: Quiz.fromMap(data['quiz'] as Map<String, dynamic>? ?? {}),
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'flashcards': flashcards.map((f) => f.toMap()).toList(),
      'quiz': quiz.toMap(),
      'progress': progress,
    };
  }
}

class Flashcard {
  final String korean;
  final String english;
  final String? pronunciation;
  final String? example;

  Flashcard({
    required this.korean,
    required this.english,
    this.pronunciation,
    this.example,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      korean: map['korean'] ?? '',
      english: map['english'] ?? '',
      pronunciation: map['pronunciation'],
      example: map['example'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'korean': korean,
      'english': english,
      'pronunciation': pronunciation,
      'example': example,
    };
  }
}

class Quiz {
  final List<QuizQuestion> questions;

  Quiz({required this.questions});

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      questions: (map['questions'] as List<dynamic>?)
          ?.map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}