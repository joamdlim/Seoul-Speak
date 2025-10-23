import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                lesson.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: lesson.progress,
                backgroundColor: Colors.grey[200],
                progressColor: Theme.of(context).primaryColor,
                barRadius: const Radius.circular(4.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${(lesson.progress * 100).toInt()}% Complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}