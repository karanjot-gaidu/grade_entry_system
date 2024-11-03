import 'package:flutter/material.dart';
import 'grades_model.dart';
import 'grade.dart';
import 'grade_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade List App',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ).copyWith(
          secondary: Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          secondary: Colors.blueAccent,
          surface: Colors.blueGrey[800],
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[700],
        ),
      ),
      themeMode: ThemeMode.dark, // Set to ThemeMode.system to let the system decide
      home: ListGrades(),
    );
  }
}

class ListGrades extends StatefulWidget {
  @override
  _ListGradesState createState() => _ListGradesState();
}

class _ListGradesState extends State<ListGrades> {
  List<Grade> grades = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final loadedGrades = await GradesModel().getAllGrades();
    setState(() {
      grades = loadedGrades;
    });
  }

  Future<void> _addGrade() async {
    final newGrade = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GradeForm()),
    );
    if (newGrade != null) {
      await GradesModel().insertGrade(newGrade);
      _loadGrades();
    }
  }

  Future<void> _editGrade(int index) async {
    final editedGrade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeForm(grade: grades[index]),
      ),
    );
    if (editedGrade != null) {
      await GradesModel().updateGrade(editedGrade);
      _loadGrades();
    }
  }


  Future<void> _deleteGrade(int index) async {
    await GradesModel().deleteGradeById(grades[index].id!);
    _loadGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Grades'),

      ),
      body: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () async {
              final result = await showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 100, 100, 100),
                items: [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                ],
              );

              if (result == 'edit') {
                _editGrade(index);
              }
            },
            child: Dismissible(
              key: ValueKey(grades[index].id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteGrade(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Grade deleted")),
                );
              },
              child: ListTile(
                title: Text(grades[index].sid),
                subtitle: Text(grades[index].grade),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        child: Icon(Icons.add),
      ),
    );
  }
}
