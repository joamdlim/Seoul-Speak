import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/auth_provider.dart';
import '../models/lesson.dart';
import '../widgets/progress_bar.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;

  const QuizScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];
  bool _isSubmitting = false;
  double _score = 0.0;
  bool _quizCompleted = false;

  Quiz? get _quiz => context.read<LessonProvider>().currentLesson?.quiz;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<LessonProvider>().setCurrentLesson(widget.lessonId),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _userAnswers = List.from(_userAnswers)..add(answerIndex);
      if (_currentQuestionIndex < (_quiz?.questions.length ?? 0) - 1) {
        _currentQuestionIndex++;
      } else {
        _calculateScore();
      }
    });
  }

  Future<void> _calculateScore() async {
    if (_quiz == null) return;

    int correctAnswers = 0;
    for (int i = 0; i < _quiz!.questions.length; i++) {
      if (_userAnswers[i] == _quiz!.questions[i].correctIndex) {
        correctAnswers++;
      }
    }

    final score = correctAnswers / _quiz!.questions.length;
    setState(() {
      _score = score;
      _quizCompleted = true;
      _isSubmitting = true;
    });

    final userId = context.read<AuthProvider>().user?.uid;
    if (userId != null) {
      try {
        await context
            .read<LessonProvider>()
            .submitQuizResult(userId, widget.lessonId, score);
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          if (lessonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final quiz = _quiz;
          if (quiz == null) {
            return const Center(child: Text('Quiz not found'));
          }

          if (_quizCompleted) {
            return _buildQuizResults();
          }

          final question = quiz.questions[_currentQuestionIndex];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24.0),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32.0),
                ...List.generate(
                  question.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _selectAnswer(index),
                        child: Text(question.options[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64.0,
              color: Colors.green,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Quiz Completed!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Your Score:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              '${(_score * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32.0),
            if (_isSubmitting)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Lesson'),
              ),
          ],
        ),
      ),
    );
  }
}