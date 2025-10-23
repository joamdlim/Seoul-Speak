import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/lesson_detail_screen.dart';
import '../screens/flashcard_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/profile_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.path == '/login' || state.path == '/signup';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) => LessonDetailScreen(
          lessonId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/lesson/:id/flashcards',
        builder: (context, state) => FlashcardScreen(
          lessonId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/lesson/:id/quiz',
        builder: (context, state) => QuizScreen(
          lessonId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}