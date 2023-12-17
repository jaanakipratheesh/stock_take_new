import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'db_config.dart';

class OutputSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OutputSettingsState();
}

class _OutputSettingsState extends State<OutputSettings> {
  final db = DBProvider.db;
  final List<String> _fields = [
    'Location',
    'Barcode',
    'Quantity',
    'Bay Number',
    'User Name',
    'Time',
    'Empty 1',
    'Empty 2',
    'Empty 3',
    'Empty 4',
    'Empty 5',
  ];
  List<String> _selectedItems = [];
  List<String> _reorderedSelectedItems = [];
  String status = 'Output : ';

  Widget _handleList() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 1.65,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: ReorderableListView.builder(
            itemCount: _fields.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _fields[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 5.0),
                color:
                    _selectedItems.contains(item) ? Colors.green : Colors.black,
                key: ValueKey(item),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    '$index. $item', // Display the index and item
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  leading: const Icon(Icons.code, color: Colors.white),
                  onTap: () {
                    setState(() {
                      if (_selectedItems.contains(item)) {
                        _selectedItems.remove(item);
                      } else {
                        _selectedItems.add(item);
                      }
                    });
                  },
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final items = _fields.removeAt(oldIndex);
                _fields.insert(newIndex, items);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 10,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'O',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            children: const [
              TextSpan(
                text: 'utput ',
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

  Widget _saveButton() {
    return InkWell(
      onTap: () async {
        List<String> columnNames = _selectedItems.map((item) => columnMapping[item] ?? '').toList();
        columnNames.removeWhere((columnName) => columnName == ',');
        String selectedItemsString = columnNames.join(',');
        print("Selected items: $selectedItemsString");
        await db.insertSelectedItems(columnNames);
        setState(() {
          status = 'Output : $selectedItemsString';
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 15,
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
          'Save',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
    );
  }

  Widget _generateButton() {
    return InkWell(
      onTap: () async {
        print("Updated order: $_fields");
        print("Selected items: $_selectedItems");
        await db.insertSelectedItems(_selectedItems);
        print('-------------------------------');
        String? selectedData = await db.getSelectedItems();
        print(selectedData);
        print('-------------------------------');
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 15,
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
          'Generate',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
    );
  }

  Widget _statusBar() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 8,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
//        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          status,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 15.0,
            height: 1,
            color: Colors.white,
          ),
        ));
  }

  Map<String, String> columnMapping = {
    'Location': 'LocId',
    'Barcode': 'Barcode',
    'Quantity': 'Qty',
    'Bay Number': 'BatchNo',
    'User Name': 'UserName',
    'Time': 'DateTime',
    'Empty 1': ',',
    'Empty 2': ',',
    'Empty 3': ',',
    'Empty 4': ',',
    'Empty 5': ',',
  };

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _title(),
                  _handleList(),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  _statusBar(),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  _saveButton(),
                ])),
      ),
    );
  }
}
