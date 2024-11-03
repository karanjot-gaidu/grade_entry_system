import 'package:flutter/material.dart';
import 'grades_model.dart';
import 'grade.dart';
import 'grade_form.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

Widget _buildGradeDataTable(Map<String, int> gradeFrequencies) {
  return DataTable(
    columns: [
      DataColumn(label: Text('Grade')),
      DataColumn(label: Text('Frequency')),
    ],
    rows: gradeFrequencies.entries
        .map(
          (entry) => DataRow(
        cells: [
          DataCell(Text(entry.key)),
          DataCell(Text(entry.value.toString())),
        ],
      ),
    )
        .toList(),
  );
}

Widget _buildGradeBarChart(Map<String, int> gradeFrequencies) {
  final data = gradeFrequencies.entries
      .map((entry) => GradeFrequency(entry.key, entry.value))
      .toList();

  final series = [
    charts.Series<GradeFrequency, String>(
      id: 'Grades',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (GradeFrequency gradeFreq, _) => gradeFreq.grade,
      measureFn: (GradeFrequency gradeFreq, _) => gradeFreq.frequency,
      data: data,
    )
  ];

  return charts.BarChart(
    series,
    animate: true,
    vertical: true,
  );
}

class GradeFrequency {
  final String grade;
  final int frequency;

  GradeFrequency(this.grade, this.frequency);
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

  void _sortGrades(String sortOption) {
    setState(() {
      switch (sortOption) {
        case 'sid_asc':
          grades.sort((a, b) => a.sid.compareTo(b.sid));
          break;
        case 'sid_desc':
          grades.sort((a, b) => b.sid.compareTo(a.sid));
          break;
        case 'grade_asc':
          grades.sort((a, b) => a.grade.compareTo(b.grade));
          break;
        case 'grade_desc':
          grades.sort((a, b) => b.grade.compareTo(a.grade));
          break;
      }
    });
  }



  Future<void> _deleteGrade(int index) async {
    await GradesModel().deleteGradeById(grades[index].id!);
    _loadGrades();
  }

  void _showGradeChart() {
    final gradeFrequencies = _calculateGradeFrequencies();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Grade Frequencies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildGradeDataTable(gradeFrequencies),
              SizedBox(height: 20),
              Expanded(child: _buildGradeBarChart(gradeFrequencies)),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _calculateGradeFrequencies() {
    final frequencies = <String, int>{};
    for (var grade in grades) {
      frequencies[grade.grade] = (frequencies[grade.grade] ?? 0) + 1;
    }
    return Map.fromEntries(
      frequencies.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Grades'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: _showGradeChart,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: _sortGrades,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sid_asc',
                child: Text('Sort by SID (Ascending)'),
              ),
              PopupMenuItem(
                value: 'sid_desc',
                child: Text('Sort by SID (Descending)'),
              ),
              PopupMenuItem(
                value: 'grade_asc',
                child: Text('Sort by Grade (Ascending)'),
              ),
              PopupMenuItem(
                value: 'grade_desc',
                child: Text('Sort by Grade (Descending)'),
              ),
            ],
          ),
        ],
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
