import 'package:flutter/material.dart';
import 'grade.dart';

class GradeForm extends StatefulWidget {
  final Grade? grade;

  GradeForm({this.grade});

  @override
  _GradeFormState createState() => _GradeFormState();
}

class _GradeFormState extends State<GradeForm> {
  final _sidController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _sidController.text = widget.grade!.sid;
      _gradeController.text = widget.grade!.grade;
    }
  }

  @override
  void dispose() {
    _sidController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _saveGrade() {
    final newGrade = Grade(
      id: widget.grade?.id,
      sid: _sidController.text,
      grade: _gradeController.text,
    );
    Navigator.pop(context, newGrade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.grade == null ? 'Add Grade' : 'Edit Grade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _sidController,
              decoration: InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Grade'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveGrade,
        child: Icon(Icons.save),
      ),
    );
  }
}
