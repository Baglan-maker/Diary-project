import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация
  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Сохраняем информацию о пользователе в Firestore
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'email': email,
          'uid': result.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),

        });
        print("Сохраняем в Firestore: ${result.user!.uid}");

      }

      return result.user;
    } catch (e, stack) {
      print("Ошибка при регистрации: $e");
      print(stack);
      print(e);
      return null;
    }
  }

  // Вход
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Получить текущего пользователя
  User? get currentUser => _auth.currentUser;
}
