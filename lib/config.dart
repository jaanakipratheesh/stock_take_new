import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'db_config.dart';
import 'model_master.dart';
import 'package:intl/intl.dart';
import 'output.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';

class ConfigSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigSettingsState();
}

class _ConfigSettingsState extends State<ConfigSettings> {

  bool dbCountStaus = false;
  int dbDataCount = 0;
  String statMsg = '';
  List<String> statusMessages = [];
  ScrollController _scrollController = ScrollController();
  int _seconds = 0;
  Timer? _timer;
  bool actionCompleted = false;
  String statusMsg = '';
  String statusMsg2 = '';
  final db = DBProvider.db;
  String fileName = 'example.txt';
  String fileContent = 'Hello, this is the content of the file!';
  List<String> _exPath = [];
  String? path;

  @override
  void initState() {
    super.initState();
    addStatusMessage('Loading Article Count.');
    initialLoad();
    addStatusMessage('Loading Completed.');
    getPath();
    getPublicDirectoryPath();
  }

  Future<void> getPath() async {
    List<String> paths;
    // getExternalStorageDirectories() will return list containing internal storage directory path
    // And external storage (SD card) directory path (if exists)
    paths = await ExternalPath.getExternalStorageDirectories();
    setState(() {
      _exPath = paths; // [/storage/emulated/0, /storage/B3AE-4D28]
    });
  }

  Future<void> getPublicDirectoryPath() async {
    path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    setState(() {
      print(path); // /storage/emulated/0/Download
    });
  }

  Widget _title() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 10,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'D',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            children: const [
              TextSpan(
                text: 'evice ',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 30,
                    fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: 'S',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: 'ettings',
                style: TextStyle(color: Colors.black87, fontSize: 30),
              ),
            ]),
      ),
    );
  }

  Widget _pickerButton() {
    return InkWell(
      onTap: () async {
        addStatusMessage('Browsing For Master File.');
        await readAndLoadCsv();
      },
      child: Container(
        width: MediaQuery.of(context).size.width/2.5,
        height: MediaQuery.of(context).size.height/15,
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: const Color(0xffdf8e33).withAlpha(10),
                  offset: const Offset(2, 4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
            color: Colors.black),
        child: const Text(
          'Load File',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
    );
  }

  Widget _outputButton() {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OutputSettings(),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width/2.5,
        height: MediaQuery.of(context).size.height/15,
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: const Color(0xffdf8e33).withAlpha(10),
                  offset: const Offset(2, 4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
            color: Colors.black),
        child: const Text(
          'Config Output',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
    );
  }

  Widget _generateButton() {
    return InkWell(
      onTap: () async {
        print('--------------');
        print(path);
        print('--------------');
        String filePath = '${path}/$fileName';
        print(filePath);
        File file = File(filePath);
        try {
          file.writeAsStringSync(fileContent);
          print('Write Success---------------------');
        }catch (err){
          print('Write Fail $err---------------------');
        }
        // writeToDownloads(fileName, fileContent);
        // String? selectedData = await db.getSelectedItems();
        // print(selectedData.toString());
        // await generateCsvFile(selectedData);
      },
      onDoubleTap: () async {
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/15,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: const Color(0xffdf8e33).withAlpha(10),
                  offset: const Offset(2, 4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
            color: Colors.black),
        child: const Text(
          'Generate Output',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Future generateCsvFile(selectedData) async{
    var statusStorage = await Permission.storage.status;
    var data = await db.generateOutputData(selectedData);
    if(!statusStorage.isGranted)
    {
      await Permission.storage.request();
    }
    if (await Permission.storage.request().isGranted) {
      await Permission.manageExternalStorage.request();
      print('----------------------${(await Permission.manageExternalStorage.isGranted)}');
      List<List<dynamic>> csvData = [selectedData!.split(',')];
      String formattedDateTime = DateFormat('dd-MM-yyyy-HH:mm:ss').format(DateTime.now());
      String csvFileName = '$formattedDateTime.csv';
      final Directory downloadsDir = Directory("/storage/emulated/0/Download");
      final exPath = downloadsDir.path;
      print("Saved Path: $exPath");
      // await Directory(exPath).create(recursive: true);
      ////////////////////////////////////////////////

      ////////////////////////////////////////////////
    } else {
      print('Error: Storage permission denied');
    }
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.status == PermissionStatus.granted) {
      return true;
    } else {
      final PermissionStatus result = await Permission.storage.request();
      return result == PermissionStatus.granted;
    }
  }

  Widget _statusMsg() {
    return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height/1.85,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dbCountStaus ? const Center(
                child: Icon(
                  Icons.download_done_outlined, // Example icon - favorite icon from Material Icons pack
                  size: 48,
                  color: Colors.white,
                ),
              ) : const Center(
                child: CircularProgressIndicator()
              ),
              const SizedBox(height: 10.0),
              Center(
                child:
                Text('Local Data Count : $dbDataCount',style: const TextStyle(color: Colors.white70),textAlign: TextAlign.justify),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width/1.1,
                height: MediaQuery.of(context).size.height/3,
                // color: Colors.black12,
                decoration: BoxDecoration(
                  borderRadius:
                  const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.black),
                  // color: Colors.teal,
                ),
                child: Center(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: statusMessages.length,
                    itemBuilder: (context, index) {
                      final message = statusMessages[index];
                      return Text(message,style: const TextStyle(color: Colors.white70),textAlign: TextAlign.justify);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              actionCompleted ? Text(statusMsg,style: const TextStyle(color: Colors.black),textAlign: TextAlign.justify) :
              Container(),
              SizedBox(height: 10.0),
            ],
          ),
        ));
  }

  void initialLoad() async{
  final db = DBProvider.db;
  dbDataCount = (await db.getMasterCount())!;
  setState(() {
    dbCountStaus = true;
  });
}

  void addStatusMessage(String message) {
    String currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    setState(() {
      statusMessages.add('$currentTime :  $message');
    });
    Timer(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  Future<void> readAndLoadCsv() async {
    // Pick a CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      // Get the picked file
      PlatformFile file = result.files.first;
      try {
        // Read the contents of the CSV file
        String csvString = await File(file.path!).readAsString();
        addStatusMessage('File Selected.');
        addStatusMessage(file.path!);
        // Parse CSV string
        List<List<dynamic>> csvList = CsvToListConverter().convert(csvString);
        addStatusMessage('File Conversion Finished.');
        List<MasterFile> formattedData = csvList.map((row) {
          return MasterFile(
            locId: row[0].toString(),
            barcode: row[1].toString(),
            description: row[2].toString(),
          );
        }).toList();
        addStatusMessage('Master File Object Created.');
        final db = DBProvider.db;
        addStatusMessage('Deleting Existing Master.');
        await db.deleteMasterFile();
        addStatusMessage('Existing Master Deleted.');
        addStatusMessage('Inserting New Master Into Database.');
        await db.batchInsertMasterFile(formattedData);
        var count = await db.getMasterCount();
        setState(() {
          dbDataCount = count!;
        });
        addStatusMessage('Master Insert Finished with $count Rows.');
      } catch (e) {
        addStatusMessage('Error reading CSV file: $e');
      }
    } else {
      // User canceled the file picker
      addStatusMessage('Browsing Cancelled.');
    }
  }

  Future<void> writeToDownloads(String fileName, String content) async {
    try {
      Directory? downloadsDirectory = await getExternalStorageDirectory();
      String filePath = '${downloadsDirectory?.path}/$fileName';

      File file = File(filePath);

      await file.writeAsString(content);

      print('File written successfully: $filePath');
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0XFFB71731),
                      Color(0XFFB71731),
                      Color(0XFFA5004E),
                    ])),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 25,
                  ),
                  _title(),
                  _statusMsg(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: MediaQuery.of(context).size.height / 12,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _pickerButton(),
                        _outputButton(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _generateButton(),
                ])),
      ),
    );
  }
}
