import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String _storageKey = 'students_records_key';

  DatabaseHelper._init();

  Future<List<Student>> getAllStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final list = decoded.map((item) => Student.fromJson(item)).toList();
      list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // Descending order
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<int> insertStudent(Student student) async {
    final students = await getAllStudents();
    int newId = 1;
    if (students.isNotEmpty) {
      final maxId = students.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b);
      newId = maxId + 1;
    }
    final newStudent = student.copyWith(id: newId);
    students.insert(0, newStudent);
    await _saveAll(students);
    return newId;
  }

  Future<int> updateStudent(Student student) async {
    final students = await getAllStudents();
    final index = students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      students[index] = student;
      await _saveAll(students);
      return 1;
    }
    return 0;
  }

  Future<int> deleteStudent(int id) async {
    final students = await getAllStudents();
    final initialLength = students.length;
    students.removeWhere((s) => s.id == id);
    if (students.length < initialLength) {
      await _saveAll(students);
      return 1;
    }
    return 0;
  }

  Future<void> _saveAll(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(students.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
