import 'package:lista_tarefas_completo_app/models/tarefa.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// PIMBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

class TarefaDB {
  static final TarefaDB instance = TarefaDB._init();
  static Database? _database;

  TarefaDB._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('tarefas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version ) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE $tableTarefasName (
        ${TarefaFields.id} $idType,
        ${TarefaFields.name} $textType,
        ${TarefaFields.isDone} $boolType
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<Tarefa> create(Tarefa tarefa) async {
    final db = await instance.database;
    final id = await db.insert(tableTarefasName, tarefa.toJson());
    return tarefa.copy(id: id);
  }

  Future<Tarefa?> read(int id) async {
    final db = await instance.database;
    final result = await db.query(
        tableTarefasName,
        columns: TarefaFields.fields,
        where: '${TarefaFields.id} = ?',
        whereArgs: [id],
    );

    // Checando se a query foi feita com sucesso (retornou um valor)
    if (result.isNotEmpty) {
      return Tarefa.fromJson(result.first);
    }
    else {
      return null;
    }
  }

  Future<List<Tarefa>> readAll() async {
    final db = await instance.database;
    final desiredOrderBy = '${TarefaFields.id} ASC';

    final result = await db.query(
      tableTarefasName,
      orderBy: desiredOrderBy
    );

    return result.map(
            (json) => Tarefa.fromJson(json)
    ).toList();
  }

  Future<int> update(Tarefa tarefa) async {
    final db = await instance.database;
    
    return db.update(
        tableTarefasName,
        tarefa.toJson(),
        where: '${TarefaFields.id} = ?',
        whereArgs: [tarefa.id]
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
        tableTarefasName,
        where: '${TarefaFields.id} = ?',
        whereArgs: [id]
    );
  }

}