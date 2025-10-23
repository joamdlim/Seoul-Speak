import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/lesson_provider.dart';
import '../models/lesson.dart';
import '../widgets/progress_bar.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<LessonProvider>().setCurrentLesson(widget.lessonId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Details'),
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          if (lessonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = lessonProvider.currentLesson;
          if (lesson == null) {
            return const Center(child: Text('Lesson not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16.0),
                Text(
                  lesson.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24.0),
                ProgressBar(
                  progress: lesson.progress,
                  label: 'Progress',
                ),
                const SizedBox(height: 32.0),
                _buildActionButton(
                  context,
                  icon: Icons.flip,
                  label: 'Review Flashcards',
                  onPressed: () => context.go('/lesson/${lesson.id}/flashcards'),
                ),
                const SizedBox(height: 16.0),
                _buildActionButton(
                  context,
                  icon: Icons.quiz,
                  label: 'Take Quiz',
                  onPressed: () => context.go('/lesson/${lesson.id}/quiz'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}