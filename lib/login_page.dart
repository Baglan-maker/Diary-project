import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
        throw FirebaseAuthException(code: 'empty-fields');
      }

      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = result.user;
      if (user != null) {
        final settings = await AuthService().getUserSettings(user.uid);
        if (settings != null) {
          final theme = settings['theme'] as String?;
          final language = settings['language'] as String?;

          if (theme != null) {
            context.read<ThemeProvider>().setTheme(theme);
          }
          if (language != null) {
            context.read<LocaleProvider>().setLocale(Locale(language));
          }
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = loc.userNotFound;
            break;
          case 'wrong-password':
            errorMessage = loc.wrongPassword;
            break;
          case 'invalid-email':
            errorMessage = loc.invalidEmail;
            break;
          case 'empty-fields':
            errorMessage = loc.enterEmailPassword;
            break;
          default:
            errorMessage = loc.loginFailed;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignIn(BuildContext context, String email, String password) async {
    final authService = AuthService();
    final user = await authService.signIn(email, password);

    if (user != null) {
      // Получаем настройки из Firestore
      final settings = await authService.getUserSettings(user.uid);

      if (settings != null) {
        // Применяем тему, если есть
        final theme = settings['theme'] as String? ?? 'light';
        final themeProvider = context.read<ThemeProvider>();
        await themeProvider.setTheme(theme);

        // Применяем язык, если есть
        final languageCode = settings['language'] as String? ?? 'ru';
        final localeProvider = context.read<LocaleProvider>();
        await localeProvider.setLocale(Locale(languageCode));
      }

      // Переход на домашний экран
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Ошибка входа, показываем сообщение и т.д.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа, попробуйте ещё раз')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.login),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: loc.email,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: loc.password,
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text(loc.login),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(loc.noAccountRegister),
            ),
          ],
        ),
      ),
    );
  }
}
