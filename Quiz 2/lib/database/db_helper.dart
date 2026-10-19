import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/patient.dart';
import '../models/patient_document.dart';
import '../utils/file_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _factoryInitialized = false;

  DatabaseHelper._init();

  static void initDatabaseFactory() {
    if (_factoryInitialized) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }
    _factoryInitialized = true;
  }

  Future<Database> get database async {
    initDatabaseFactory();
    if (_database != null) return _database!;
    _database = await _initDB('doctor_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        if (!kIsWeb) {
          try {
            await db.execute('PRAGMA foreign_keys = ON');
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        blood_group TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        prescription TEXT,
        notes TEXT,
        photo_path TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        uploaded_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final samplePatients = [
      Patient(
        name: 'Eleanor Vance',
        age: 38,
        gender: 'Female',
        phone: '+1 (555) 234-8901',
        email: 'eleanor.vance@example.com',
        bloodGroup: 'A+',
        diagnosis: 'Hypertension Stage 2 & Chronic Migraine',
        prescription: 'Lisinopril 10mg daily morning, Sumatriptan 50mg as needed for acute headache.',
        notes: 'Follow-up BP reading required after 2 weeks. Monitor sodium intake and sleep patterns.',
        status: 'Active',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Patient(
        name: 'James Reynolds',
        age: 54,
        gender: 'Male',
        phone: '+1 (555) 782-4190',
        email: 'jreynolds@example.com',
        bloodGroup: 'O+',
        diagnosis: 'Type 2 Diabetes Mellitus',
        prescription: 'Metformin 500mg twice daily with meals, Glimepiride 2mg morning.',
        notes: 'HbA1c test scheduled for next month. Diet control plan shared.',
        status: 'Under Observation',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Patient(
        name: 'Marcus Brody',
        age: 62,
        gender: 'Male',
        phone: '+1 (555) 901-3482',
        email: 'brody.m@example.com',
        bloodGroup: 'B-',
        diagnosis: 'Acute Bronchitis & Severe Asthma',
        prescription: 'Amoxicillin-Clavulanate 875mg twice daily, Albuterol inhaler 2 puffs q4h prn.',
        notes: 'Oxygen saturation monitored at 93%. Nebulization administered today.',
        status: 'Critical',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Patient(
        name: 'Sophia Patel',
        age: 27,
        gender: 'Female',
        phone: '+1 (555) 431-7729',
        email: 'spatel@example.com',
        bloodGroup: 'AB+',
        diagnosis: 'Post-Op Knee Arthroscopy Recovery',
        prescription: 'Ibuprofen 400mg tid prn, Calcium + Vitamin D supplements.',
        notes: 'Physiotherapy progressing smoothly. Full weight bearing permitted.',
        status: 'Recovered',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ];

    for (final p in samplePatients) {
      await db.insert('patients', p.toMap());
    }
  }

  // --- Patient CRUD ---

  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;

    // Remove any attached physical files
    final docs = await getDocumentsForPatient(id);
    for (final doc in docs) {
      await FileHelper.deleteFile(doc.filePath);
    }

    final patient = await getPatientById(id);
    if (patient?.photoPath != null) {
      await FileHelper.deleteFile(patient!.photoPath);
    }

    // Delete associated documents
    await db.delete(
      'documents',
      where: 'patient_id = ?',
      whereArgs: [id],
    );

    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Patient?> getPatientById(int id) async {
    final db = await database;
    final maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Patient>> getPatients({
    String? query,
    String? statusFilter,
    String? genderFilter,
    String sortBy = 'newest',
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim().toLowerCase()}%';
      whereClauses.add('(LOWER(name) LIKE ? OR LOWER(diagnosis) LIKE ? OR phone LIKE ?)');
      whereArgs.addAll([q, q, q]);
    }

    if (statusFilter != null && statusFilter != 'All') {
      whereClauses.add('status = ?');
      whereArgs.add(statusFilter);
    }

    if (genderFilter != null && genderFilter != 'All') {
      whereClauses.add('gender = ?');
      whereArgs.add(genderFilter);
    }

    String orderBy;
    switch (sortBy) {
      case 'name_asc':
        orderBy = 'name ASC';
        break;
      case 'age_asc':
        orderBy = 'age ASC';
        break;
      case 'age_desc':
        orderBy = 'age DESC';
        break;
      case 'oldest':
        orderBy = 'created_at ASC';
        break;
      case 'newest':
      default:
        orderBy = 'created_at DESC';
    }

    final maps = await db.query(
      'patients',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  // --- Document CRUD ---

  Future<int> insertDocument(PatientDocument doc) async {
    final db = await database;
    return await db.insert('documents', doc.toMap());
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    final maps = await db.query('documents', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final doc = PatientDocument.fromMap(maps.first);
      await FileHelper.deleteFile(doc.filePath);
    }
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PatientDocument>> getDocumentsForPatient(int patientId) async {
    final db = await database;
    final maps = await db.query(
      'documents',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'uploaded_at DESC',
    );
    return maps.map((map) => PatientDocument.fromMap(map)).toList();
  }

  Future<Map<String, int>> getStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM patients')) ?? 0;
    final active = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM patients WHERE status = 'Active'")) ?? 0;
    final observation = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM patients WHERE status = 'Under Observation'")) ?? 0;
    final critical = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM patients WHERE status = 'Critical'")) ?? 0;
    final recovered = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM patients WHERE status = 'Recovered'")) ?? 0;
    final totalDocs = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM documents')) ?? 0;

    return {
      'total': total,
      'active': active,
      'observation': observation,
      'critical': critical,
      'recovered': recovered,
      'docs': totalDocs,
    };
  }
}
