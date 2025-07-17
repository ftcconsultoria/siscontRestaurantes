import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'siscont.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE sample (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE cade_empresa (
            cemp_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_nome_fantasia TEXT NOT NULL,
            cemp_razao_social TEXT,
            cemp_cnpj TEXT,
            cemp_ie TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cade_mesa (
            cmes_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            cmes_numero INTEGER NOT NULL,
            cmes_status TEXT NOT NULL,
            cmes_descricao TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE estq_grupo (
            egru_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            egru_descricao TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE estq_produto (
            epro_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            egru_pk INTEGER NOT NULL REFERENCES estq_grupo(egru_pk) ON DELETE CASCADE,
            epro_descricao TEXT NOT NULL,
            epro_vlr_varejo REAL NOT NULL,
            epro_ativo INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE cade_usuario (
            cusu_pk INTEGER,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            ccot_vend_pk INTEGER,
            cusu_usuario TEXT NOT NULL,
            cusu_senha TEXT,
            PRIMARY KEY (cusu_pk, cemp_pk)
          )
        ''');

        await db.execute('''
          CREATE TABLE pedi_documentos (
            pdoc_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            cmes_pk INTEGER REFERENCES cade_mesa(cmes_pk) ON DELETE SET NULL,
            pdoc_dt_emissao TEXT NOT NULL,
            pdoc_dt_conclusao TEXT,
            pdoc_status TEXT NOT NULL,
            cusu_pk INTEGER,
            FOREIGN KEY (cusu_pk, cemp_pk) REFERENCES cade_usuario(cusu_pk, cemp_pk) ON DELETE SET NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE pedi_itens (
            piten_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            pdoc_pk INTEGER NOT NULL REFERENCES pedi_documentos(pdoc_pk) ON DELETE CASCADE,
            epro_pk INTEGER NOT NULL REFERENCES estq_produto(epro_pk) ON DELETE CASCADE,
            piten_qtd INTEGER NOT NULL,
            piten_obs TEXT,
            piten_status TEXT,
            piten_dt_enviado TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cade_pagamento (
            cpag_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            cpag_descricao TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE flux_documentos_pagamentos (
            fdpa_pk INTEGER PRIMARY KEY AUTOINCREMENT,
            cemp_pk INTEGER NOT NULL REFERENCES cade_empresa(cemp_pk) ON DELETE CASCADE,
            cpag_pk INTEGER NOT NULL REFERENCES cade_pagamento(cpag_pk) ON DELETE SET NULL,
            pdoc_pk INTEGER NOT NULL REFERENCES pedi_documentos(pdoc_pk) ON DELETE CASCADE,
            fdpa_valor REAL NOT NULL,
            pago_em TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertSample(String name) async {
    final dbClient = await database;
    return await dbClient.insert('sample', {
      'name': name,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSamples() async {
    final dbClient = await database;
    return await dbClient.query('sample', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markSampleSynced(int id) async {
    final dbClient = await database;
    await dbClient
        .update('sample', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
