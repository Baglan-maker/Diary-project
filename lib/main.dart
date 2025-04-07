
import 'package:flutter/material.dart';

void main() {
runApp(MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'My Personal Diary',
theme: ThemeData(
primaryColor: Colors.purple,
fontFamily: 'Georgia',
),
home: DiaryHomePage(),
);
}
}

class DiaryHomePage extends StatelessWidget {
final List<Map<String, String>> diaryEntries = List.generate(
12,
(index) => {
'date': '2025-04-${(index + 1).toString().padLeft(2, '0')}',
'title': 'Day ${index + 1}',
'note': 'Today I felt really inspired to write something personal...',
},
);

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
return Container(
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
style: TextStyle(
fontSize: 14,
color: Colors.grey,
),
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
onPressed: () {
// Здесь могла бы быть функция добавления записи
},
),
);
}
}