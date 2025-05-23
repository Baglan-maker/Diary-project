import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferencesService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> savePreferences(String theme, String language) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'theme': theme,
        'language': language,
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, String>?> loadPreferences() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final theme = data?['theme'] ?? 'light';
        final language = data?['language'] ?? 'kk';
        return {
          'theme': theme,
          'language': language,
        };
      }
    }
    return null;
  }
}
