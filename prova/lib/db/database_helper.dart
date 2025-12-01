import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/task.dart';

class DatabaseHelper {
  static Database? _db;
  static String _appRa = '';

  /// Inicializa (ou abre) o banco e imprime o caminho do arquivo .db
  /// Passe o seu RA como parâmetro para que o arquivo seja criado como `tarefas_<RA>.db`.
  static Future<Database> initDB(String ra) async {
    // Se estivermos em desktop, inicializa o backend ffi para que
    // a API global `openDatabase` funcione corretamente.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final documentsDir = await getApplicationDocumentsDirectory();
    _appRa = ra;
    final dbName = 'tarefas_${ra.isNotEmpty ? ra : 'RA'}.db';
    final path = join(documentsDir.path, dbName);

    // Imprime o caminho do DB para facilitar abertura no DB Browser
    print('DB path: $path');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tarefas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descricao TEXT,
            prioridade INTEGER NOT NULL,
            criadoEm TEXT NOT NULL,
            campoExtra TEXT,
            ra TEXT,
            tema TEXT,
            corPrimaria TEXT,
            corSecundaria TEXT
          )
        ''');
      },
      onOpen: (db) async {
        // Ensure any missing columns are added when opening an existing DB
        final cols = await db.rawQuery("PRAGMA table_info(tarefas);");
        final existing = cols.map((c) => c['name'] as String).toSet();
        final toAdd = <String, String>{
          'ra': 'TEXT',
          'tema': 'TEXT',
          'corPrimaria': 'TEXT',
          'corSecundaria': 'TEXT',
        };
        for (final entry in toAdd.entries) {
          if (!existing.contains(entry.key)) {
            await db.execute(
              'ALTER TABLE tarefas ADD COLUMN ${entry.key} ${entry.value};',
            );
          }
        }
      },
    );

    return _db!;
  }

  /// Insere uma tarefa e retorna o id gerado.
  static Future<int> insertTask(Task task) async {
    if (_db == null) throw Exception('Database not initialized');
    return await _db!.insert('tarefas', task.toMap());
  }

  /// Retorna todas as tarefas ordenadas por criadoEm desc.
  static Future<List<Task>> getTasks() async {
    if (_db == null) throw Exception('Database not initialized');
    final maps = await _db!.query('tarefas', orderBy: 'criadoEm DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  /// Atualiza a tarefa (necessita id).
  static Future<int> updateTask(Task task) async {
    if (_db == null) throw Exception('Database not initialized');
    if (task.id == null) throw Exception('Task id is null');
    return await _db!.update(
      'tarefas',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Remove uma tarefa pelo id.
  static Future<int> deleteTask(int id) async {
    if (_db == null) throw Exception('Database not initialized');
    return await _db!.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }

  /// Retorna o RA configurado para o app (passado em initDB)
  static String getAppRa() => _appRa;

  /// Fecha a conexão com o banco (opcional)
  static Future<void> closeDB() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
