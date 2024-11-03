import 'dart:convert';

import 'package:flutter/material.dart';
import 'grades_model.dart';
import 'grade.dart';
import 'grade_form.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
  List<Grade> filteredGrades = []; // Store filtered grades
  int? _selectedIndex;
  TextEditingController searchController = TextEditingController(); // Controller for search bar

  @override
  void initState() {
    super.initState();
    _loadGrades();
    filteredGrades = grades; // Initialize filtered grades
    searchController.addListener(_filterGrades); // Listen for changes in search input
  }

  Future<void> _loadGrades() async {
    final loadedGrades = await GradesModel().getAllGrades();
    setState(() {
      grades = loadedGrades;
      filteredGrades = loadedGrades; // Update filtered grades with loaded grades
    });
  }

  // This method filters the grades based on search input
  void _filterGrades() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredGrades = grades.where((grade) {
        return grade.sid.toLowerCase().contains(query) ||
            grade.grade.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose the controller when no longer needed
    super.dispose();
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

  // Updated editGrade method to accept a Grade object
  Future<void> _editGrade(Grade grade) async {
    final editedGrade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeForm(grade: grade),
      ),
    );
    if (editedGrade != null) {
      await GradesModel().updateGrade(editedGrade);
      _loadGrades(); // Reload grades after editing
    }
  }

  void _sortGrades(String sortOption) {
    setState(() {
      switch (sortOption) {
        case 'sid_asc':
          grades.sort((a, b) => a.sid.compareTo(b.sid));
          filteredGrades.sort((a, b) => a.sid.compareTo(b.sid));
          break;
        case 'sid_desc':
          grades.sort((a, b) => b.sid.compareTo(a.sid));
          filteredGrades.sort((a, b) => b.sid.compareTo(a.sid));
          break;
        case 'grade_asc':
          grades.sort((a, b) => b.grade.compareTo(a.grade));
          filteredGrades.sort((a, b) => b.grade.compareTo(a.grade));
          break;
        case 'grade_desc':
          grades.sort((a, b) => a.grade.compareTo(b.grade));
          filteredGrades.sort((a, b) => a.grade.compareTo(b.grade));
          break;
      }
    });
  }



  // Updated deleteGrade method to accept a Grade object
  Future<void> _deleteGrade(Grade grade) async {
    await GradesModel().deleteGradeById(grade.id!);
    _loadGrades(); // Reload grades after deletion
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

  Future<void> _importGrades() async {
    // Use File Picker to select the CSV file
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        String filePath = result.files.single.path!;

        // Read the CSV file
        final input = File(filePath).openRead();
        List<List<dynamic>> rows = [];
        try {
          // Parse the CSV file
          await input.transform(utf8.decoder).transform(const CsvToListConverter()).forEach((row) {
            rows.add(row);
          });

          // Append the grades to the existing list
          for (int i = 0; i < rows.length; i++) {
            var row = rows[i];
            // Skip the first row by checking the index
            if (i == 0) continue; // This skips the header row

            if (row.length >= 2) {
              String sid = row[0].toString();
              String grade = row[1].toString();
              Grade newGrade = Grade(sid: sid, grade: grade);
              await GradesModel().insertGrade(newGrade);
            }
          }
          // Reload the grades
          _loadGrades();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Grades imported successfully!')),
          );
        } catch (e) {
          print("Error reading CSV file: $e");
        }
      }
    } catch (e) {
      print('Error: $e'); // Print the error for debugging
    }

  }

  Future<void> exportGradesToPDF() async {
    final pdf = pw.Document();
    List<Grade> grades = await GradesModel().getAllGrades();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Grades List', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Student ID', 'Grade'],
                data: grades
                    .map((grade) => [grade.sid, grade.grade])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final output = Directory('/storage/emulated/0/Download');
    final file = File('${output!.path}/grades.pdf');
    await file.writeAsBytes(await pdf.save());

    // Optionally, show a message that the file is saved
    print('PDF saved to: ${file.path}');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Grades'),
        actions: [
          IconButton(
            icon: Icon(Icons.import_export), // Use an appropriate icon
            onPressed: _importGrades, // Call the import function
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await exportGradesToPDF();
              // Optionally, show a snackbar to confirm the export
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Grades exported to PDF')),
              );
            },
          ),
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

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Student ID or Grade',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // List of filtered grades
          Expanded(
            child: ListView.builder(
              itemCount: filteredGrades.length,
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
                      _editGrade(filteredGrades[index]); // Pass the correct grade object for editing
                    }
                  },
                  child: Dismissible(
                    key: ValueKey(filteredGrades[index].id), // Use filteredGrades
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteGrade(filteredGrades[index]); // Use the grade object for deletion
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Grade deleted")),
                      );
                    },
                    child: ListTile(
                      title: Text(filteredGrades[index].sid),
                      subtitle: Text(filteredGrades[index].grade),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        child: Icon(Icons.add),
      ),
    );
  }
}
