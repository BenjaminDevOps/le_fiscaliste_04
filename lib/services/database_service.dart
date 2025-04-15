import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'leads_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        prenom TEXT,
        email TEXT,
        telephone TEXT,
        consentement_marketing INTEGER,
        date_creation TEXT,
        quiz_responses TEXT,
        conseil TEXT
      )
    ''');
  }

  // Enregistrer un lead
  Future<int> saveLead(Map<String, dynamic> leadData) async {
    final db = await database;

    // Convertir quiz_responses en JSON si c'est un Map
    if (leadData['quiz_responses'] is Map) {
      leadData['quiz_responses'] = jsonEncode(leadData['quiz_responses']);
    }

    // Convertir le booléen en integer pour SQLite
    leadData['consentement_marketing'] =
        leadData['consentement_marketing'] == true ? 1 : 0;

    return await db.insert('leads', leadData);
  }

  // Récupérer tous les leads
  Future<List<Map<String, dynamic>>> getAllLeads() async {
    final db = await database;
    final List<Map<String, dynamic>> leadsData =
        await db.query('leads', orderBy: 'date_creation DESC');

    return leadsData.map((lead) {
      // Convertir quiz_responses de JSON à Map si nécessaire
      if (lead['quiz_responses'] is String) {
        try {
          lead['quiz_responses'] = jsonDecode(lead['quiz_responses']);
        } catch (e) {
          // Si erreur de décodage, garder comme chaîne
        }
      }

      // Convertir l'integer en booléen
      lead['consentement_marketing'] = lead['consentement_marketing'] == 1;

      return lead;
    }).toList();
  }

  // Supprimer un lead (RGPD)
  Future<int> deleteLead(int id) async {
    final db = await database;
    return await db.delete(
      'leads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
