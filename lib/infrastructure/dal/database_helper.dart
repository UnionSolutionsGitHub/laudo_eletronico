import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database _db;
  final _databaseName, _databaseVersion;
  final bool usesDocumentsDirectoryPath;

  DatabaseManager(
    this._databaseName,
    this._databaseVersion, {
    this.usesDocumentsDirectoryPath = false,
  });

  Future init(List<DataAccessObject> daos) async {
    await _open();

    final queryCreateTableCOnfigurations = "CREATE TABLE IF NOT EXISTS DATABASE_CONFIGURATIONS (TABLE_NAME TEXT, HASH_CODE INT)";
    await _execute(queryCreateTableCOnfigurations);

    if (_db.isOpen) {
      daos.forEach((dao) async {
        await dao._create(this);
      });
    }

    //await _close();
  }

  Future _open() async {
    if (_db?.isOpen == true) {
      return;
    }

    final path = usesDocumentsDirectoryPath ? (await getExternalStorageDirectory()).path : (await getDatabasesPath());
    final databasePath = join(path, "$_databaseName.db");

    _db = await openDatabase(
      databasePath,
      version: _databaseVersion,
    );
  }

  // Future _close() async {
  //   await _db?.close();
  //   _db = null;
  // }

  Future _execute(String query) async {
    //await _open();
    await _db.execute(query);
  }

  Future<List<Map<String, dynamic>>> _executeQuery(String query) async {
    //await _open();
    return await _db.rawQuery(query);
  }

  // Future<int> _insert(DataAccessObject dao, dynamic object) async {
  //   //await _open();
  //   return await _db.insert(dao.tableName, dao.toMap(object));
  // }

  Future<int> _insert(String query) async {
    return await _db.rawInsert(query);
  }

  Future<dynamic> _get(DataAccessObject dao, {String args, String orderBy = ""}) async {
    //await _open();

    return await _db.transaction((transaction) async {
      return await transaction.query(
        dao.tableName,
        where: args,
        orderBy: orderBy?.isNotEmpty == true ? orderBy : null,
      );
    });
  }

  Future<int> _update(String query) async {
    //await _open();
    return await _db.rawUpdate(query);
  }

  Future _delete(DataAccessObject dao, String where) async {
    //await _open();
    await _db.delete(dao.tableName, where: where);
  }
}

abstract class DataAccessObject<T> {
  static DatabaseManager _database;

  Future _create(DatabaseManager database) async {
    if (_database == null) {
      _database = database;
    }

    final columnsString = this
        .columns
        .map((column) =>
            "${column.name} ${_columnType(column.type)} ${column.isPrimaryKey ? "PRIMARY KEY" : ""} ${column.isAutoincrement ? "AUTOINCREMENT" : column.canBeNull ? "" : "NOT NULL"}")
        .join(", ");

    final query = "CREATE TABLE IF NOT EXISTS $tableName ($columnsString)";
    final result = await _database._db.query("DATABASE_CONFIGURATIONS", where: "TABLE_NAME='${this.tableName}'");

    if (result.length <= 0) {
      await _database._execute(query);
      await _database._execute("INSERT INTO DATABASE_CONFIGURATIONS VALUES ('${this.tableName}', ${query.hashCode})");
      return;
    }

    if (result.first["HASH_CODE"] != query.hashCode) {
      final tableColumns = await _database._executeQuery("PRAGMA table_info($tableName)");
      final columns = tableColumns.where((column) => this.columns.any((c) => c.name == column["name"])).map((column) => column["name"]).join(",");
      final tempTable = "CREATE TEMPORARY TABLE ${this.tableName}_temp as SELECT * FROM $tableName";
      await _database._execute(tempTable);
      final queryInsertSelect = "INSERT INTO ${this.tableName} ($columns) SELECT $columns FROM ${this.tableName}_temp";
      await _database._execute("DROP TABLE ${this.tableName}");
      await _database._execute(query);
      await _database._execute(queryInsertSelect);
      final queryUpdateHash = "UPDATE DATABASE_CONFIGURATIONS SET HASH_CODE=${query.hashCode} WHERE TABLE_NAME='${this.tableName}'";
      await _database._execute(queryUpdateHash);
    }
  }

  String get tableName;

  List<Column> get columns;

  ///Map object to query
  Map<String, dynamic> toMap(T object);

  ///Map query result to object
  T fromMap(Map<String, dynamic> map);

  // Future open() async {
  //   if (!_database._db.isOpen) {
  //     await _database._open();
  //   }
  // }

  // Future close() async {
  //   await _database._close();
  // }

  Future<int> insert(T object) async {
    final columns = this.columns.map((column) => !column.isAutoincrement ? column.name : "_@").join(", ").replaceAll("_@, ", "");

    final entries = this.toMap(object).entries;

    final values = this
        .columns
        .map((column) {
          final entry = entries.firstWhere((entry) => entry.key == column.name);

          if (column?.isPrimaryKey == true && column?.isAutoincrement == true) {
            return "_@";
          }

          return _value(column.type, entry.value);
        })
        .join(", ")
        .replaceAll("_@, ", "");

    final query = "INSERT OR REPLACE INTO ${this.tableName} ($columns) VALUES ($values)";

    return await _database._insert(query);
  }

  Future insertMany(List<T> objects) async {
    final columns = this.columns.map((column) => !column.isAutoincrement ? column.name : "_@").join(", ").replaceAll("_@, ", "");

    final values = objects
        .map((object) {
          final entries = this.toMap(object).entries;
          final values = this.columns.map((column) {
            final entry = entries.firstWhere((entry) => entry.key == column.name);

            if (column?.isPrimaryKey == true && column?.isAutoincrement == true) {
              return "_@";
            }

            return _value(column.type, entry.value);
          }).join(", ");

          return "($values)";
        })
        .join(",")
        .replaceAll("_@, ", "");

    final query = "INSERT OR REPLACE INTO ${this.tableName} ($columns) VALUES $values";

    await _database._insert(query);
  }

  ///Return an object if result is a single item.
  ///Return a list of objects if result is more than one.
  ///[args] a map with field and value to searching. If no [args] are passed, you'll get all items in that table.
  Future<dynamic> get({Map<Column, dynamic> args, Column orderBy}) async {
    final stringArgs = args?.entries?.map((entry) => "${entry.key.name}${_columnValueForQuery(entry.key.type, entry.value)}")?.join(" AND ");

    final maps = await _database?._get(this, args: stringArgs, orderBy: orderBy?.name);
    final objects = maps?.map<T>((map) => this.fromMap(map))?.toList();

    return objects;
    //return objects?.length == 1 ? objects.first as T : objects as List<T>;
  }

  Future<int> update(T object) async {
    final stringArgs = this
        .toMap(object)
        ?.entries
        ?.map(
          (entry) => "${entry.key}${_columnValueForQuery(this.columns.singleWhere((x) => x.name == entry.key).type, entry.value)}",
        )
        ?.join(", ");
    final whereMap = this.toMap(object).entries.singleWhere((entry) => entry.key == this.columns.firstWhere((column) => column.isPrimaryKey).name);
    final query = "UPDATE ${this.tableName} SET $stringArgs WHERE ${whereMap.key}=${whereMap.value}";
    return await _database._update(query);
  }

  delete(Map<Column, dynamic> args) {
    final where = args?.entries?.map((entry) => "${entry.key.name}${_columnValueForQuery(entry.key.type, entry.value)}")?.join(" AND ");

    _database._delete(this, where);
  }

  Future clear() async {
    await _database._delete(this, null);
  }

  ///Check if a register exists in database.
  ///[args] a map with field and value to searching.
  Future<bool> exists({Map<Column, dynamic> args}) async {
    final stringArgs = args?.entries?.map((entry) => "${entry.key.name}${_columnValueForQuery(entry.key.type, entry.value)}")?.join(" AND ");

    final query = "SELECT 1 FROM ${this.tableName} WHERE $stringArgs";
    final result = await _database?._executeQuery(query);
    return result?.isEmpty == false;
  }

  ///Check if exists any register in table
  Future<bool> any() async {
    final query = "SELECT 1 FROM ${this.tableName}";
    final result = await _database?._executeQuery(query);
    return result?.isNotEmpty == true;
  }

  dynamic valueOf(Map<String, dynamic> map, Column column) {
    switch (column.type) {
      case ColumnTypes.Boolean:
        return map[column.name] == 1;
      case ColumnTypes.Date:
        return map[column.name] != null ? DateTime?.fromMillisecondsSinceEpoch(map[column.name]) : null;
      default:
        return map[column.name];
    }
  }

  String _columnType(ColumnTypes columnType) {
    switch (columnType) {
      case ColumnTypes.Int:
      case ColumnTypes.Boolean:
      case ColumnTypes.Date:
        return "INTEGER";
      case ColumnTypes.Float:
        return "REAL";
      case ColumnTypes.ByteArray:
        return "BLOB";
      default:
        return "TEXT";
    }
  }

  dynamic _columnValueForQuery(ColumnTypes columnType, dynamic value) {
    if (value is List) {
      return " IN (${value.map((item) => _value(columnType, item)).join(",")})";
    }

    return " = ${_value(columnType, value)}";
  }

  dynamic _value(ColumnTypes columnType, dynamic value) {
    // if (value == null) {
    //   return value;
    // }

    switch (columnType) {
      case ColumnTypes.Text:
        return value == null ? null : "'$value'";
      case ColumnTypes.Boolean:
        return "${value == true ? 1 : 0}";
      // case ColumnTypes.Date:
      //   return value.millisecondsSinceEpoch.toString();
      default:
        return value;
    }
  }
}

class Column {
  final String name;
  final ColumnTypes type;
  final bool isPrimaryKey, isAutoincrement, canBeNull;

  const Column({
    @required this.name,
    @required this.type,
    this.isPrimaryKey = false,
    this.isAutoincrement = false,
    this.canBeNull = true,
  });
}

enum ColumnTypes {
  Int,
  Text,
  Float,
  Boolean,
  ByteArray,
  Date,
}
