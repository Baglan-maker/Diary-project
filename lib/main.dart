import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Провайдер для управления Темой
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);

    await _saveThemeToFirestore();
  }

  Future<void> setTheme(String theme) async {
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);

    await _saveThemeToFirestore();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveThemeToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'theme': currentThemeString,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Ошибка при сохранении темы в Firestore: $e');
      }
    }
  }

  Future<void> resetToDefault() async {
    _themeMode = ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', false);
  }


  String get currentThemeString => _themeMode == ThemeMode.dark ? 'dark' : 'light';
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Язык по умолчанию

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode != locale.languageCode) {
      _locale = locale;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale.languageCode);

      await _saveLocaleToFirestore();
    }
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> _saveLocaleToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'language': _locale.languageCode,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Ошибка при сохранении язлыка в Firestore: $e');
      }
    }
  }

  Future<void> resetToDefault() async {
    _locale = const Locale('en');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', 'en');
  }

  String get currentLocaleCode => _locale.languageCode;


}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final localeProvider = Provider.of<LocaleProvider>(context);

          return MaterialApp(
            title: 'My Personal Diary',
            theme: ThemeData(
              primaryColor: Colors.purple,
              fontFamily: 'Georgia',
            ),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
              Locale('kk'),
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return const Locale('en');
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('en');
            },
            locale: localeProvider.locale,
            initialRoute: '/',
            routes: {
              '/': (context) => const DiaryHomePage(),
              '/about': (context) => const AboutPage(),
              '/settings': (context) => const SettingsPage(),
              '/login': (context) => LoginPage(),
              '/register': (context) => RegisterPage(),
            },
          );
        },
      ),
    );
  }
}



class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  List<Map<String, String>> diaryEntries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        diaryEntries = List.generate(
          5,
              (index) => {
            'date': '2025-04-${(index + 1).toString().padLeft(2, '0')}',
            'title': AppLocalizations.of(context)!.dayTitle(index + 1),
            'note': AppLocalizations.of(context)!.dayNote,
          },
        );
      });
    });
  }

  void _addEntry() {
    final newIndex = diaryEntries.length + 1;
    setState(() {
      diaryEntries.add(
        {
          'date': '2025-04-${DateTime.now().day.toString().padLeft(2, '0')}',
          'title': 'New Day $newIndex',
          'note': AppLocalizations.of(context)!.newEntryNote,
        },
      );
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      diaryEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Personal Diary'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.greetingDrawer,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  FirebaseAuth.instance.currentUser != null
                      ? Text(
                    FirebaseAuth.instance.currentUser!.email ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  )
                      : Text(
                    AppLocalizations.of(context)!.guest,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Home доступен всем
            ListTile(
              leading: Icon(Icons.home),
              title: Text(AppLocalizations.of(context)!.home),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),

            // Settings - только для авторизованных пользователей
        if (FirebaseAuth.instance.currentUser != null)
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
            Navigator.pushNamed(context, '/settings');
      }),

            // About доступен всем
            ListTile(
              leading: Icon(Icons.info),
              title: Text(AppLocalizations.of(context)!.about),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),

            Divider(),

            // Login / Logout
            FirebaseAuth.instance.currentUser == null
                ? ListTile(
              leading: Icon(Icons.login),
              title: Text(AppLocalizations.of(context)!.login),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            )
                : ListTile(
              leading: Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () async {
                await AuthService().signOut();
                await context.read<ThemeProvider>().resetToDefault();
                await context.read<LocaleProvider>().resetToDefault();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      body: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.greeting,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: orientation == Orientation.portrait
                          ? (screenWidth < 600 ? 1 : 2)
                          : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: diaryEntries.length,
                    itemBuilder: (context, index) {
                      final entry = diaryEntries[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiaryDetailPage(entry: entry),
                            ),
                          );
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.deleteEntry),
                              content: Text(AppLocalizations.of(context)!.confirmDelete),
                              actions: [
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.delete),
                                  onPressed: () {
                                    _deleteEntry(index);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.purple.shade200),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['date'] ?? 'Unknown Date',
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 6),
                              Text(
                                entry['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  entry['note']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: _addEntry,
      ),
    );
  }
}

class DiaryDetailPage extends StatelessWidget {
  final Map<String, String> entry;

  DiaryDetailPage({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry['title'] ?? 'Diary Entry'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry['date'] ?? '',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 12),
            Text(
              entry['note'] ?? '',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About the App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.aboutAppTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.aboutAppDescription,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.aboutAppDevelopers,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),
            const Text(
              'In the scope of the course “Cross-platform mobile development”\n'
                  'at Astana IT University.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              AppLocalizations.of(context)!.aboutAppCourseInfo,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Text(AppLocalizations.of(context)!.pleaseLoginToAccess),
        ),
      );
    }

    // Если пользователь авторизован — отображаем настройки
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
              },
              secondary: Icon(Icons.dark_mode),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.changeLanguage),
              onTap: () {
                _showLanguageDialog(context, localeProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  localeProvider.setLocale(Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Русский'),
                onTap: () {
                  localeProvider.setLocale(Locale('ru'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


}