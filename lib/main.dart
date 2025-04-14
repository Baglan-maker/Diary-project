import 'package:flutter/material.dart';

void main() {
  runApp(MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Personal Diary',
      themeMode: ThemeMode.system,
      theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Georgia',
     ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Georgia',
    ),
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
  List<Map<String, String>> diaryEntries = List.generate(
    5,
    (index) => {
      'date': '2025-04-${(index + 1).toString().padLeft(2, '0')}',
      'title': 'Day ${index + 1}',
      'note': 'Today I felt really inspired to write something personal...',
    },
  );

  void _addEntry() {
    final newIndex = diaryEntries.length + 1;
    setState(() {
      diaryEntries.add(
      {
        'date': '2025-04-${DateTime.now().day.toString().padLeft(2, '0')}',
        'title': 'New Day $newIndex',
        'note': 'This is a brand-new diary entry!',
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
                    'Hello, Dreamer ✨\nHere are your recent diary entries:',
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
                              title: Text('Delete Entry'),
                              content: Text(
                                  'Are you sure you want to delete this entry?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: Text('Delete'),
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
                                entry['date']!,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 6),
                              Text(
                                entry['title']!,
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
