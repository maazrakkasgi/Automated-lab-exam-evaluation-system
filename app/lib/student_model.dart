class Student {
  final String id;
  final String name;
  final String semester;

  Student({required this.id, required this.name, required this.semester});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      semester: json['semester'],
    );
  }
}
