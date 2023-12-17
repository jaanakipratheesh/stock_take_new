import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'model_master.dart';
import 'model_settings.dart';
import 'model_stock_count.dart';
/////////////////////////////////////Config Operations///////////////////////////////////////
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }
  Future<int> _getOldDbVersion() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final oldPath = join(documentsDirectory.path, 'StockTake.db');
    final oldDatabase = await openDatabase(oldPath);
    final oldVersion = await oldDatabase.getVersion();
    await oldDatabase.close();
    return oldVersion;
  }
  Future<Database> initDB({int? newVersion}) async {
    if(newVersion!=null){
      // TODO Handle the case where newVersion is provided
    }
    else{
      newVersion = await _getOldDbVersion();
    }
    //print('DB VERSION SETTINGS ARE - NEW VERSION = ${newVersion} --- OLD VERSION = ${await _getOldDbVersion()}');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "StockTake.db");
    return await openDatabase(path, version: newVersion,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE UserFile ("
              "UserId INTEGER PRIMARY KEY AUTOINCREMENT,"
              "UserName TEXT NOT NULL,"
              "Password TEXT NOT NULL,"
              "CreatedDate TEXT NOT NULL,"
              "Master TEXT NOT NULL"
              ")");
          print("Created table UserFile");
          await db.execute("CREATE TABLE MasterFile ("
              "RecNo INTEGER PRIMARY KEY AUTOINCREMENT,"
              "LocId TEXT NOT NULL,"
              "Barcode TEXT NOT NULL,"
              "Description TEXT NOT NULL"
              ")");
          print("Created table MasterFile");
          await db.execute("CREATE TABLE StockCount ("
              "RecNo INTEGER PRIMARY KEY AUTOINCREMENT,"
              "Barcode TEXT NOT NULL,"
              "Qty TEXT NOT NULL,"
              "Nfplu TEXT NOT NULL,"
              "DateTime TEXT NOT NULL,"
              "BatchNo TEXT NULL,"
              "UserName TEXT NOT NULL,"
              "LocId TEXT NOT NULL"
              ")");
          print("Created table StockCount");
          await db.execute("CREATE TABLE Settings ("
              "RecNo INTEGER PRIMARY KEY AUTOINCREMENT,"
              "DefQty TEXT NOT NULL,"
              "SetQty TEXT NOT NULL,"
              "BarcodeExtendedMode TEXT NOT NULL"
              ")");
          print("Created table Settings");
          await db.execute("CREATE TABLE OutputOrder ("
              "RecNo INTEGER PRIMARY KEY AUTOINCREMENT,"
              "OutputOrder TEXT NOT NULL"
              ")");
          print("Created table OutputOrder");
        },onUpgrade: (db, oldDbVersion, newVersion) async {
          //Todo and need to be tested the function
          print('-------------db upgrade-----------------');
          await db.setVersion(newVersion);
        },onDowngrade: (db, oldDbVersion, newVersion) async {
          //Todo and need to be tested the function
          print('-------------db downgrade-----------------');
          await db.setVersion(oldDbVersion);
        }
    );
  }
/////////////////////////////////////Config Operations///////////////////////////////////////
  Future<void> insertDefaultUser() async {
    final db = await database;
    // Check if the default user already exists
    if (db != null) {
      List<Map> result = await db.query('UserFile', where: 'UserName = ?', whereArgs: ['admin']);
      if (result.isEmpty) {
        // Insert default user if not exists
        await db.insert(
          'UserFile',
          {
            'UserName': 'admin',
            'Password': 'admindxb',
            'CreatedDate': DateTime.now().toIso8601String(),
            'Master': '1',
          },
        );
        for (int i = 1; i <= 50; i++) {
          await db.insert(
            'UserFile',
            {
              'UserName': 'pdt$i',
              'Password': 'pdt$i',
              'CreatedDate': DateTime.now().toIso8601String(),
              'Master': '0',
            },
          );
        }
      }
    }
  }//insert a default user and make sure not locked out. Hardcoded value as of now.
  Future<void> insertDefaultSettings() async {
    final db = await database;
    // Check if the default user already exists
    if (db != null) {
      List<Map> result = await db.query('Settings');
      if (result.isEmpty) {
        // Insert default settings if not exists
        await db.insert(
          'Settings',
          {
            'DefQty': '1.0',
            'SetQty': 'false',
            'BarcodeExtendedMode': 'false',
          },
        );
      }
    }
  }
  Future<bool> validateUser(String username, String password) async {
    final db = await database;
    if (db == null) {
      return false;
    }
    try {
      if (username.isEmpty || password.isEmpty) {
        return false;
      }
      List<Map> result = await db.query(
        'UserFile',
        where: 'lower(UserName) = ? AND lower(Password) = ?',
        whereArgs: [username.toLowerCase(), password.toLowerCase()],
      );
      if(result.isEmpty)
        {
          print(result.isEmpty);
          return false;
        }
      else{
        return true;
      }
    } catch (e) {
      // Handle any exceptions that might occur during the query
      print('Error in validateUser: $e');
      return false;
    }
  }
  Future<bool> batchInsertMasterFile(List<MasterFile> data) async {
    final db = await database;
    final batch = db?.batch();
    try {
      for (final entry in data) {
        try {
          batch?.insert('MasterFile', entry.toMap());
        } catch (e) {
          print('Error inserting entry: $entry');
          print('Error details: $e');
        }
      }
      await batch?.commit(noResult: true, continueOnError: true);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
  Future<bool> deleteMasterFile() async {
    final db = await database;
    try {
      await (db?.delete("MasterFile"));
      return true;
    }catch(e){
      return false;
    }
  }
  Future<int?> getMasterCount() async {
    int? count = 0;
    final db = await database;
    try {
      var result = (await (db?.rawQuery('SELECT COUNT(*) FROM MasterFile')));
      count = Sqflite.firstIntValue(result!);
      return count;
    }catch(e){
      print(e.toString());
      return 0;
    }
  }
//   Future<List<StockCount>>getBarcodeData()async{
//     var barcodeMapList =
//     await getBarcodeMapList(); // Get 'Map List' from database
//     int count =
//         barcodeMapList.length; // Count the number of map entries in db table
//     List<StockCount> barcodeList = List<StockCount>();
//     // For loop to create a 'Note List' from a 'Map List'
//     for (int i = 0; i < count; i++) {
//       barcodeList.add(StockCount.fromMapObject(barcodeMapList[i]));
//     }
//     return barcodeList;
//   }
//   Future<List<Map<String, dynamic>>> getBarcodeMapList() async {
//     Database? db = await database;
// //		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
//     var result = await db?.rawQuery(
//         'SELECT RecNo,Barcode,Qty,Nfplu,UserName,DateTime,LocId FROM StockCount order by RecNo desc LIMIT 50');
// //     var result = await db.query(
// //         "StockCount", orderBy: "id ASC"
// //     );
//     return result;
//   }
  Future<List<StockCount?>> getEntries() async {
    final db = await database;
    final List<Map<String, Object?>>? entriesMap = await db?.query('StockCount', orderBy: 'RecNo DESC');
    final List<StockCount?> entriesList = entriesMap!.map((entryMap) => StockCount.fromMap(entryMap)).toList();
    return entriesList;
  }
  Future<String> getAllPriceUpdateData() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM StockCount");
    List<StockCount> list = res.isNotEmpty
        ? res.map((c) => StockCount.fromMapObject(c)).toList()
        : [];
    String jsonTags = jsonEncode(list.map((entry) => entry.toJson()).toList());
    return jsonTags;
  }
  Future<StockCount?> searchByRecNo(int? recNo) async {
    try {
      final db = await database;
      var res =
      // await db?.rawQuery("SELECT * FROM Barcode WHERE LocId = '$locId' AND Barcode = '$barcode'",);
      await db?.query('StockCount',where: 'RecNo = ? ',whereArgs: [recNo]);
      return res!.isNotEmpty ? StockCount.fromMap(res.first) : null;
    } catch (e) {
      print("Exception: $e");
    }
  }
  Future<String> saveStockCount(StockCount saveStockCount) async {
    try {
      final db = await database;
      // insert to the table using the new id
      var raw = await db?.rawInsert(
        "INSERT Into StockCount (Barcode,Qty,DateTime,Nfplu,BatchNo,UserName,LocId)"
            " VALUES (?,?,?,?,?,?,?)",
        [
          saveStockCount.barcode,
          saveStockCount.qty,
          saveStockCount.dateTime,
          saveStockCount.nfplu,
          saveStockCount.batchNo,
          saveStockCount.userName,
          saveStockCount.locId
        ],
      );
      return "Data saved";
    } catch (e) {
      // Handle the exception here
      print("Error saving data: $e");
      return "Error saving data";
    }
  }
  Future<MasterFile?> searchBarcodeLocal(String barcode) async {
    // print(barcode);
    MasterFile temp;
    barcode=barcode.trim();
    try {
      final db = await database;
      print(barcode);
      var res =
      // await db.rawQuery("SELECT * FROM Barcode where Barcode = '001' ");
      await db
          ?.rawQuery("SELECT * FROM MasterFile where Barcode = '$barcode' ");
      print(res.toString());
      return res!.isNotEmpty ? MasterFile.fromMapObject(res.first) : null;
    } catch (e) {
      print("Exception: $e");
    }
  }
  Future<List<StockCount>?> getBarcodeData() async {
    var barcodeMapList = await getBarcodeMapList();
    if (barcodeMapList != null) {
      int count = barcodeMapList.length;
      List<StockCount> barcodeList = [];
      for (int i = 0; i < count; i++) {
        barcodeList.add(StockCount.fromMapObject(barcodeMapList[i]));
      }
      return barcodeList;
    } else {
      return null;
    }
  }
  Future<List<Map<String, dynamic>>?> getBarcodeMapList() async {
    Database? db = await database;
    var result = await db?.rawQuery(
        'SELECT RecNo,Barcode,Qty,Nfplu,DateTime,BatchNo,UserName,LocId FROM StockCount order by RecNo desc LIMIT 50');
    return result;
  }
  Future<bool> deleteSettings() async {
    final db = await database;
    try {
      await (db?.delete("Settings"));
      return true;
    }catch(e){
      return false;
    }
  }
  Future<Settings?> getSettings() async {
    try {
      final db = await database;
      var res = await db?.query('Settings', limit: 1);
      return res!.isNotEmpty ? Settings.fromMap(res.first) : null;
    } catch (e) {
      print("Exception: $e");
    }
  }
  Future<bool> updateSettings(Settings settingData) async {
    Settings newSettings = settingData;
    try {
      final db = await database;
      await db?.update(
        'Settings',
        newSettings.toMap(),
        where: 'rowid = 1', // Assuming SQLite automatically assigns rowid
      );
      return true;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
  Future<void> insertSelectedItems(List<String> selectedItems) async {
    final db = await database;
    // Convert the selected items list to a comma-separated string
    String selectedItemsString = selectedItems.join(',');
    // Check if there is existing data before deleting
    final List<Map<String, Object?>>? existingData =
    await db?.query('OutputOrder');
    if (existingData!.isNotEmpty) {
      // Delete existing row if it exists
      await db?.delete('OutputOrder');
    }
    // Insert the new row with selected items
    await db?.insert(
      'OutputOrder',
      {
        'OutputOrder': selectedItemsString,
        // Add other columns if needed
      },
    );
  }
  Future<String?> getSelectedItems() async {
    final db = await database;
    var result = await db?.rawQuery(
        'SELECT OutputOrder FROM OutputOrder');
    Object? outputOrderString = result?[0]["OutputOrder"];
    return outputOrderString.toString();
  }
  Future<String> generateOutputData(selectedData) async{
    final db = await database;
    var result = await db?.rawQuery(
        'SELECT $selectedData FROM StockCount');
    String jsonTags = jsonEncode(result);
    return jsonTags;
  }

} //A singleton database provider