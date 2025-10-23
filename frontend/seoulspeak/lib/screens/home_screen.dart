import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/lesson_provider.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import '../widgets/progress_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeoulSpeak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          if (lessonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lessonProvider.lessons.isEmpty) {
            return const Center(child: Text('No lessons available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: lessonProvider.lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessonProvider.lessons[index];
              return LessonCard(
                lesson: lesson,
                onTap: () => context.go('/lesson/${lesson.id}'),
              );
            },
          );
        },
      ),
    );
  }
}