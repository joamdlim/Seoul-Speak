import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  UserProfile? _userProfile;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _firebaseService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      _firebaseService.getUserProfile(_user!.uid).listen((profile) {
        _userProfile = profile;
        notifyListeners();
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseService.signInWithEmail(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final credential = await _firebaseService.signUpWithEmail(email, password);
      if (credential.user != null) {
        final userProfile = UserProfile(
          id: credential.user!.uid,
          email: email,
        );
        await _firebaseService.createUserProfile(userProfile);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProgress(String lessonId, double progress) async {
    if (_user != null) {
      await _firebaseService.updateUserProgress(_user!.uid, lessonId, progress);
    }
  }
}