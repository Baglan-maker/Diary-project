import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() {
  runApp(MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Personal Diary',
      theme: ThemeData(
        primaryColor: Colors.purple,
        fontFamily: 'Georgia',
    ),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
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
      if (locale == null) return const Locale('kk');
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
      }
    }
    return const Locale('kk');
  },
  home: DiaryHomePage(),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
        ],
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
                                  style: TextStyle(fontSize: 14),
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
            const Text(
              'Personal Diary - Your Daily Journal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'This app allows you to record your daily thoughts, track your mood, '
                  'and organize your personal notes securely.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Developed by: Dumanuli Darkhan, Keneskhan Magzhan, Tolegenov Baglan, Tuspekova Gulzhan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'In the scope of the course “Cross-platform mobile development”\n'
                  'at Astana IT University.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'Mentor (Teacher): Assistant Professor Abzal Kyzyrkanov',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}