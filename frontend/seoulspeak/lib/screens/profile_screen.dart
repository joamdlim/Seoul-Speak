import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../widgets/progress_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userProfile = authProvider.userProfile;
          if (userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, userProfile),
                const SizedBox(height: 32.0),
                _buildStats(context, userProfile),
                const SizedBox(height: 32.0),
                _buildProgressSection(context, userProfile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 16.0),
        Text(
          profile.displayName ?? 'User',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8.0),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              'XP Points',
              profile.totalXP.toString(),
            ),
            _buildStatItem(
              context,
              'Completed',
              profile.completedLessons.length.toString(),
              subtitle: 'Lessons',
            ),
            _buildStatItem(
              context,
              'Average',
              '${_calculateAverageProgress(profile.lessonProgress)}%',
              subtitle: 'Progress',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    String? subtitle,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, UserProfile profile) {
    final sortedLessons = profile.lessonProgress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lesson Progress',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16.0),
        ...sortedLessons.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ProgressBar(
              progress: entry.value,
              label: 'Lesson ${entry.key}',
            ),
          ),
        ),
      ],
    );
  }

  int _calculateAverageProgress(Map<String, double> progress) {
    if (progress.isEmpty) return 0;
    final total = progress.values.reduce((a, b) => a + b);
    return ((total / progress.length) * 100).round();
  }
}