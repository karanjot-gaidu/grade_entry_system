class Grade {
  final int? id;
  final String sid;
  final String grade;

  Grade({this.id, required this.sid, required this.grade});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sid': sid,
      'grade': grade,
    };
  }

  static Grade fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      sid: map['sid'],
      grade: map['grade'],
    );
  }
}
