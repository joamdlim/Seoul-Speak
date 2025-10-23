import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final String label;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8.0),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: progress,
          backgroundColor: Colors.grey[200],
          progressColor: Theme.of(context).primaryColor,
          barRadius: const Radius.circular(4.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}