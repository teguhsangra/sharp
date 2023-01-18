import 'package:sqflite/sqflite.dart';
import 'package:telkom/repositories/database_connection.dart';

class Repository{
  late  DatabaseConnection _databaseConnection;

  Repository(){
    _databaseConnection = DatabaseConnection();
  }

  static Database? _database;

  Future<Database?> get database async{
    if(_database != null) return _database;
    _database = await _databaseConnection.setDatabase();
    return _database;
  }

  inserData(table, data) async {
    // print(data);
    var connection = await database;
    return await connection?.insert(table, data);
  }

  countData(table)async{
    var connection = await database;
    final result = await connection?.rawQuery('SELECT COUNT(*) FROM $table where is_sync = 0');
    final count = Sqflite.firstIntValue(result!);
    return count;
  }

  getAllData(table)async{
    var connection = await database;
    return await connection?.rawQuery('SELECT * FROM $table');
  }

  getDataPending(table)async{
    var connection = await database;
    return await connection?.rawQuery('SELECT * FROM $table where is_sync = 0');
  }


  getSalesOrderDetail(Id,table)async{
    var connection = await database;
    return await connection?.rawQuery('SELECT * FROM $table where sales_order_id = $Id');
  }

  updateData(Id,status,table)async{
    var connection = await database;
    return await connection?.rawUpdate('UPDATE $table SET is_sync = $status WHERE id = $Id');
  }
  //
  // updateDataChecklist(Id,sync) async{
  //   var connection = await database;
  //   return await connection?.rawUpdate('UPDATE checklist_results SET is_sync = $sync WHERE id = $Id');
  // }
  //
  //
  // deleteChecklistResult(Id) async{
  //   var connection = await database;
  //   return await connection?.rawQuery('DELETE FROM checklist_results where id = $Id');
  // }
  //
  // deleteChecklistContent(resultId) async{
  //   var connection = await database;
  //   return await connection?.rawQuery('DELETE FROM checklist_result_contents where checklist_result_id = $resultId');
  // }
  //
  // deleteChecklistAnswer(contentId) async{
  //   var connection = await database;
  //   return await connection?.rawQuery('DELETE FROM checklist_result_content_answer_options where checklist_result_content_id = $contentId');
  // }


}