import 'dart:async';
import 'dart:async';
import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:stock_take/model_master.dart';
import 'db_config.dart';
import 'model_settings.dart';
import 'model_stock_count.dart';

class StockTake extends StatefulWidget {
  final String userNameLogin;
  final String? batchNo;
  const StockTake(this.userNameLogin, this.batchNo, {super.key});
  @override
  State<StatefulWidget> createState() => StockTakeState();
}

class StockTakeState extends State<StockTake> {
  double form_height = 40;
  List<StockCount> stockCounts = [];
  late StockCount localList;
  String nfpluVal = 'N';
  double count = 0.00;
  FocusNode qtyNode2 = FocusNode();
  FocusNode qtyNode = FocusNode();
  FocusNode barcodeNode = FocusNode();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemCountController = TextEditingController();
  TextEditingController itemCountEditController = TextEditingController();
  // final FocusNode _textFieldFocusNode = FocusNode();
  Color snColor = Colors.blue;
  Color snDataColor = Colors.white;
  bool enableFieldSt = false;
  final StreamController<List<StockCount?>> _streamController =
  StreamController<List<StockCount?>>();
  StockCount? data;
  var isPressed = false;
  bool savetotext = false;
  bool setQty = false;
  final db = DBProvider.db;
  var upd = 1;
  String? _barcode;
  late bool visible;
  bool qtyControl = true;
  String barcodeData = '';
  // late Settings settingData;
  Settings settingData = Settings(
    defQty: '1.0',
    setQty: 'false',
    barcodeExtendedMode: 'false',
  );
  String enteredText = '';
  bool focusFirst = false;
  bool barcodeExtendedMode = false;
  late String userNameLogin;
  String? batchNo;
  late String locId;

  @override
  void initState() {
    super.initState();
    getSettingsValues();
    barcodeNode.addListener(handleFocusChange1);
    qtyNode.addListener(handleFocusChange2);
  }

  @override
  void dispose() {
    barcodeController.dispose();
    itemNameController.dispose();
    itemCountController.dispose();
    // RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  bool parseBool(String text) {
    if (text.toLowerCase() == "true") {
      return true;
    } else if (text.toLowerCase() == "false") {
      return false;
    } else if (text.toUpperCase() == "TRUE") {
      return true; // Default value in case of an unknown value
    } else if (text.toUpperCase() == "FALSE") {
      return false; // Default value in case of an unknown value
    } else {
      print('Some Error Happened');
      return false;
    }
  }

  Future getSettingsValues() async {
    settingData = (await db.getSettings())!;
    setState(() {
      setQty = parseBool(settingData.setQty);
      barcodeExtendedMode = parseBool(settingData.barcodeExtendedMode);
    });
    applySettingValues(setQty);
  }

  Future applySettingValues(setQty) async {
    if(setQty){
      // print('getting set qty data');
      setState(() {
        itemCountController.text = settingData.defQty;
        print(settingData.defQty);
        qtyControl = true;
      });
    }
    if(!setQty){
      setState(() {
        itemCountController.text = '';
        clearController();
        qtyControl = false;
      });
    }
    FocusScope.of(context).requestFocus(barcodeNode);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future updateSettings(settingData) async {
    if (await db.updateSettings(settingData))
      scaffoldMsg(context, 'Data Updated');
    else
      scaffoldMsg(context, 'Error Updating Data');
  }

  Future<String?> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      // print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) {
      FocusScope.of(context).unfocus();
      clearController();
      return null;
    }
    return barcodeScanRes;
  }

  Widget _scrollResult(List<StockCount>? stockCounts) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.15,
        margin: const EdgeInsets.fromLTRB(5, 2, 5, 0),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//        color: Colors.white,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0XFFB71731),
                  Color(0XFFB71731),
                  Color(0XFFA5004E),
                ]
              // colors: [Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
//                 colors: [
//                   Color.fromRGBO(118, 184, 82, 2),
//                   Color.fromRGBO(141, 194, 111, 2),
//                 ]
            )),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Theme(
                      data:
                      Theme.of(context).copyWith(dividerColor: Colors.blue),
                      child: DataTable(
                        showCheckboxColumn: true,
                        horizontalMargin: 5.0,
                        dividerThickness: 1.0,
                        sortAscending: true,
                        sortColumnIndex: 2,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              "REC NO",
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            numeric: false,
                          ),
                          DataColumn(
                            label: Text(
                              "BARCODE",
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            numeric: false,
                          ),
                          DataColumn(
                            label: Text(
                              "QTY",
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "NFPLU",
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "DATE TIME",
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        rows: stockCounts!
                            .map(
                              (StockCount) => DataRow(cells: [
                            DataCell(
                              Text(StockCount.recNo.toString(),
                                  textScaleFactor: 1.1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12,
                                    color: Colors.yellowAccent,
                                  )),
                            ),
                            DataCell(
                              Text(StockCount.barcode,
                                  textScaleFactor: 1.1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12,
                                    color: Colors.yellowAccent,
                                  )),
                            ),
                            DataCell(
                              Text(StockCount.qty,
                                  textScaleFactor: 1.1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12,
                                    color: Colors.yellowAccent,
                                  )),
                              showEditIcon: true,
                              onTap: () {
                                // editStoredData(context, StockCount);
                              },
                            ),
                            DataCell(
                              Text(StockCount.nfplu,
                                  textScaleFactor: 1.1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12,
                                    color: Colors.yellowAccent,
                                  )),
                            ),
                            DataCell(
                              Text(StockCount.dateTime,
                                  textScaleFactor: 1.1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12,
                                    color: Colors.yellowAccent,
                                  )),
                            ),
                          ]),
                        )
                            .toList(),
                      ),
                    )))));
  }

  Widget _list() {
    if (upd == 1) {
      return FutureBuilder(
        future: DBProvider.db.getBarcodeData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _scrollResult(snapshot.data);
          }
          if (null == snapshot.data || snapshot.data!.isEmpty) {
            return const Center(
            child : (Text("No Data Found",style: TextStyle(fontSize: 18.0, height: 1, color: Colors.white))));
          }
          return const CircularProgressIndicator();
          upd = 0;
        },
      );
    } else {
      return Text("Try save one item");
    }
  }

  Future<void> updateQtySettings(setQty) async {
    if (setQty) {
      if (itemCountController.text.isNotEmpty) {
        setState(() {
          qtyControl = true;
        });
        settingData.defQty = itemCountController.text;
        await updateSettings(settingData);
        await getSettingsValues();
      } else {
        setState(() {
          qtyControl = true;
        });
        itemCountController.text = settingData.defQty;
        await updateSettings(settingData);
        await getSettingsValues();
        FocusScope.of(context).unfocus();
        qtyNode.unfocus();
      }
      ; // Toggle the checkbox value
    } else {
      setState(() {
        qtyControl = false;
      });
      settingData.setQty = setQty.toString();
      await updateSettings(settingData);
      await getSettingsValues();
      itemCountController.text = '';
    }
    ;
  }

  Widget _optionControl() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.03,
      height: MediaQuery.of(context).size.height / 15,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                    value: setQty,
                    onChanged: (bool? value) async {
                      setState(
                            () {
                          setQty = !setQty;
                        },
                      );
                      if (setQty) {
                        await setDefQty(context);
                      }
                      if(!setQty){
                        settingData.setQty = 'false';
                        await updateSettings(settingData);
                        clearController();
                      }
                    },
                  ),
                  Text(
                    "SET QTY",
                    style: TextStyle(
                      color: setQty ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                    value: barcodeExtendedMode,
                    onChanged: (bool? value) async{
                      setState(() {
                        barcodeExtendedMode = !barcodeExtendedMode; // Toggle the checkbox value
                      });
                      settingData.barcodeExtendedMode =
                      barcodeExtendedMode ? 'true' : 'false';
                      await updateSettings(settingData);
                    },
                  ),
                  Text(
                    "EXENDED BARCODE",//AUTO SAVE OPTION DISABLED
                    style: TextStyle(
                      color: barcodeExtendedMode ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void snackBardata(BuildContext context, String actionMsg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        actionMsg,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ));
  }

  Future<Future<String?>> showMyiosDialog(
      BuildContext context, String title, String msg) async {
    String nfplu = 'N';
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Text(msg),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    nfplu = 'N';
                    Navigator.of(context).pop(nfplu);
                  }),
              CupertinoDialogAction(
                  child: Text('YES'),
                  onPressed: () {
                    nfplu = 'Y';
                    Navigator.of(context).pop(nfplu);
                  }),
            ]);
      },
    );
  }

  void showMyiosGenDialog(
      BuildContext context, String title, String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(msg),
        );
      },
    );
  }

  Future<void> setDefQty(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
            title: const Text("Set Default Qty:"),
            content: Material(
              child: SingleChildScrollView(
                  child: Center(
                    child: ListBody(
                      children: <Widget>[
                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                          ],
                          focusNode: qtyNode2,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 15.0,
                              height: 1.5,
                              color: Colors.red,
                              fontWeight: FontWeight.w900),
                          cursorColor: Colors.red,
                          controller: itemCountEditController,
                          autocorrect: false,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            suffixIcon: IconButton(
                              onPressed: () => itemCountEditController.clear(),
                              icon: const Icon(Icons.clear),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFDBEDFF),
                            //                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(
                                color: Colors.black,
                                style: BorderStyle.solid,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(
                                color: Colors.amber,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        Text('Previous Qty : ${settingData.defQty}'),
                      ],
                    ),
                  )),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: const Text('CANCEL'),
                  onPressed: () async {
                    setState(() {
                      settingData.setQty = 'false';
                      setQty = false;
                      qtyControl = false;
                    });
                    await updateSettings(settingData);
                    await getSettingsValues();
                    clearController();
                    Navigator.of(context).pop();
                  }),
              CupertinoDialogAction(
                  child: const Text('SAVE'),
                  onPressed: () async {
                    setState(() {
                      settingData.defQty = itemCountEditController.text;
                      qtyControl = true;
                      itemCountController.text = settingData.defQty;
                      settingData.setQty = 'true';
                    });
                    await updateSettings(settingData);
                    await getSettingsValues();
                    Navigator.of(context).pop();
//                     count = (double.parse(itemCountEditController.text));
//                     isNumeric(count) => num.tryParse(count) != null;
//                     localList.barcode = bar;
//                     localList.recno = rno;
//                     localList.qty = count.toString();
//                     localList.userName = setupData.appUser;
//                     localList.locId = setupData.locId;
//                     bool val = verifyBarcode(localList);
//                     if (val == true) {
//                       clearController();
//                       itemCountEditController.text = '';
//                       count = 0;
//                       var resp =
//                       await DBProvider.db.updateStockCount(localList);
//                       snackBardata(
//                           context, resp.toString(), 2, snColor, snDataColor);
//                     } else {
// //                  showMyAlertDialog(context, "Alert!", "Cannot Continue");
//                     }
//                     ;
//                     upd = 1;
//                     Navigator.of(context).pop();
                  }),
            ]);
      },
    );
  }

  void getBarcode(String scanBarcode) async {
    MasterFile? data = await (db.searchBarcodeLocal(scanBarcode));
    StockCount localList;
    if (data != null) {
      itemNameController.text = data!.description;
      setState(() {
        nfpluVal = 'N';
        itemNameController.text = data.description;
        locId = data.locId;
      });
      if(setQty) {
        localList = StockCount(
          barcode: data.barcode,
          nfplu: nfpluVal,
          dateTime: (DateTime.now()).toString().substring(0, 19),
          qty: (itemCountController.text).toString(),
          recNo: '',
          batchNo: batchNo,
          userName: userNameLogin,
          locId: locId,
        );
        var msg = await db.saveStockCount(localList);
        snackBardata(context, '$msg');
        clearController();
      }
      else{
        setState(() {
          qtyControl = false;
        });
        FocusScope.of(context).requestFocus(qtyNode);
        localList = StockCount(
          barcode: data.barcode,
          nfplu: nfpluVal,
          dateTime: (DateTime.now()).toString().substring(0, 19),
          qty: (itemCountController.text).toString(),
          recNo: '',
          batchNo: batchNo,
          userName: userNameLogin,
          locId: data.locId,
        );
      }
      count = 0;
    } else {
      //TODO
      locId = 'NA';
      nfpluVal = 'Y';
      var nfplud = await showMyiosDialog(
          context, "Alert!", "Data Not Found\nDo you want to save the item?");
      if (await nfplud == 'Y') {
        if(setQty) {
          setState(() {
            qtyControl = true;
          });
          localList = StockCount(
            barcode: barcodeController.text,
            nfplu: nfpluVal,
            dateTime: (DateTime.now()).toString().substring(0, 19),
            qty: settingData.defQty,
            recNo: '',
            batchNo: batchNo,
            userName: userNameLogin,
            locId: locId,
          );
          var msg = await db.saveStockCount(localList);
          snackBardata(context, '$msg');
          clearController();
          FocusScope.of(context).requestFocus(barcodeNode);
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
        if(!setQty){
          setState(() {
            qtyControl = false;
          });
          FocusScope.of(context).requestFocus(qtyNode);
          itemNameController.text = 'No Data';
          count = 0;
        }} else if (await nfplud == 'N') {
        clearController();
        FocusScope.of(context).requestFocus(barcodeNode);
      }
    }
  }

  bool verifyBarcode(StockCount val) {
    if ((val.barcode == null) || ((val.barcode == ''))) {
      showMyiosGenDialog(context, "Alert!", "Barcode cannot be null");
      return false;
    } else if ((val.qty == null) || ((val.qty == ''))) {
      showMyiosGenDialog(context, "Alert!", "Qty cannot be null");
      return false;
    } else if ((double.parse(val.qty)) == 0.0) {
      showMyiosGenDialog(context, "Alert!", "Qty cannot be zero");
      return false;
    } else if ((double.parse(val.qty)) >= 99999) {
      showMyiosGenDialog(context, "Alert!", "Check Counted Qty Again");
      return false;
    } else {
      return true;
    }
  }

  void clearController() {
    setState(() {
      FocusScope.of(context).unfocus();
      barcodeController.clear();
      itemNameController.clear();
      if (!setQty) itemCountController.clear();
      FocusScope.of(context).requestFocus(barcodeNode);
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  void scaffoldMsg(context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ));
  }

  void handleFocusChange1() {
    if (barcodeNode.hasFocus) {
      Future.delayed(const Duration(microseconds: 10), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
      // print('Barcode field focused');
    } else {
      // print('Barcode Focus changed');
    }
  }

  void handleFocusChange2() {
    if (qtyNode.hasFocus) {
      print('Qty field focused');
    } else {
      Future.delayed(const Duration(microseconds: 10), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
      print('Qty Focus changed');
    }
  }

  Widget _barcodeScan() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 20,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              height: form_height,
              padding: const EdgeInsets.all(0),
              child: TextFormField(
                focusNode: barcodeNode,
                // readOnly: true,
                autovalidateMode: AutovalidateMode.always,
                inputFormatters: barcodeExtendedMode ?
                [
                LengthLimitingTextInputFormatter(20),
                  FilteringTextInputFormatter.allow(RegExp(r'^.*$')),
                  ] :
                [
                  LengthLimitingTextInputFormatter(13), // Adjust the length according to your barcode format
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
                ] ,
                keyboardType: barcodeExtendedMode ? TextInputType.text : TextInputType.number,
                autofocus: false,
                textAlign: TextAlign.justify,
                controller: barcodeController,
                autocorrect: false,
                decoration: const InputDecoration(
                  prefixText: "  Barcode     : ",
                  hintText: 'Scan or Enter Barcode',
                  filled: true,
                  fillColor: Color(0xFFDBEDFF),
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  getBarcode(barcodeController.text);
                  // Optionally, handle submitted value
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemName() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 20,
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
//      color: Colors.amberAccent,
//      padding: EdgeInsets.all(0),
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
              child: (Container(
//              width: MediaQuery.of(context).size.width / 1.3,
//              width: MediaQuery.of(context).size.width - 10,
                  height: form_height,
                  padding: const EdgeInsets.all(0),
                  child: TextFormField(
                    enabled: true,
                    textAlign: TextAlign.start,
                    controller: itemNameController,
                    autocorrect: false,
                    readOnly: true,
                    decoration: const InputDecoration(
//                  prefixIcon: Icon(Icons.add_a_photo),
                      prefixText: "  Item Name : ",
                      hintText: 'Product Name',
                      filled: true,
                      fillColor: Color(0xFFDBEDFF),
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  )))),
        ]));
  }

  Widget _itemCount() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 10,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(0),
              child: TextFormField(
                readOnly: qtyControl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]+(\.([0-9]{1,3})?)?$')),
                ],
                focusNode: qtyNode,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 20.0,
                  height: 2,
                  color: Colors.red,
                  fontWeight: FontWeight.w900,
                ),
                cursorColor: Colors.red,
                controller: itemCountController,
                autocorrect: false,
                textAlign: TextAlign.start,
                textAlignVertical:
                TextAlignVertical.center, // Align cursor vertically
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  suffixIcon: IconButton(
                    onPressed: () => itemCountController.clear(),
                    icon: const Icon(Icons.clear),
                  ),
                  hintText: ' Qty',
                  filled: true,
                  fillColor: const Color(0xFFDBEDFF),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      color: Colors.black,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      color: Colors.amber,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                onTap: () {
                  setState(() {
                    count = 0;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    count = (double.parse(itemCountController.text));
                  });
                },
                onFieldSubmitted: (value) async {
                  setState(() {
                    localList = StockCount(
                      barcode : barcodeController.text,
                      qty : value.toString(),
                      nfplu : nfpluVal,
                      dateTime : (DateTime.now()).toString().substring(0, 19),
                      recNo: '',
                      batchNo: batchNo,
                      userName: userNameLogin,
                      locId: locId,
                    );
                  });
                  if(verifyBarcode(localList)){
                    scaffoldMsg(context, await db.saveStockCount(localList));
                    clearController();
                    FocusScope.of(context).requestFocus(barcodeNode);
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 10,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      height: MediaQuery.of(context).size.height / 10,
                      textColor: Colors.red,
                      color: Colors.red,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          count = (double.parse(itemCountController.text) + 1);
                          if (count > 99999) {
                            count = 1;
                          }
                          if (count <= 0) {
                            count = 1;
                          }
                          itemCountController.text = count.toString();
                        });
                      },
                      child: const Text("+",
                          style:
                          TextStyle(color: Colors.white, fontSize: 35.0)),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      height: MediaQuery.of(context).size.height / 10,
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text("-",
                          style:
                          TextStyle(color: Colors.white, fontSize: 35.0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        count = (double.parse(itemCountController.text) - 1);
                        if (count <= 0) {
                          count = 1;
                        }
                        if (count > 99999) {
                          count = 1;
                        }
                        itemCountController.text = count.toString();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    userNameLogin = widget.userNameLogin;
    batchNo = widget.batchNo;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Stock Take'),
          centerTitle: true,
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.redAccent, Colors.blueAccent]))),
          backgroundColor: Colors.blue,
          elevation: 10,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.history),
              // color: Colors.red,
              tooltip: 'Send History Data',
              onPressed: () async {
                snackBardata(context, "Sending History Data to Server");
                setState(() => isPressed = !isPressed);
              },
            ),
          ],
        ),
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              var key = event.logicalKey;
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                print('Enter pressed. Entered Text: $enteredText');
                // Reset enteredText after processing Enter key
                setState(() {
                  enteredText = '';
                });
              } else if (key.keyLabel != null && key.keyLabel != 'Backspace') {
                setState(() {
                  enteredText += key.keyLabel!;
                });
              }
            }
          },
          child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
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
                  child: SafeArea(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          // SizedBox(
                          //   height: 10,
                          // ),
//                  _popUp(),
                          _barcodeScan(),
                          _itemName(),
                          _itemCount(),
                          _optionControl(),
                          Expanded(child: _list()),
                        ]),
                  ),
                  // ),
                ),
              )),
        ),
        floatingActionButton:
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
              heroTag: "pcbtn6",
              elevation: 9.0,
              tooltip: "Text Download",
              child: Icon(Icons.save_alt),
              backgroundColor: savetotext ? Colors.orange : Colors.teal,
              onPressed: () async {
                await getSettingsValues();
                // var statusStorage = await Permission.storage.status;
                // if(!statusStorage.isGranted)
                // {
                //   await Permission.storage.request();
                // }
                // setState(() {
                //   savetotext = !savetotext;
                // });
                // final obj = SaveStockBarcodeText();
                // var result = await obj.saveStkBcd();
                // snackBardata(context, result,);
                // setState(() {
                //   savetotext = !savetotext;
                // });
              }),
          SizedBox(
            width: MediaQuery.of(context).size.width / 50,
          ),
          FloatingActionButton(
              heroTag: "stbtn3",
              elevation: 9.0,
              tooltip: "Clear Screen",
              child: Icon(Icons.clear),
              backgroundColor: Colors.deepPurple,
              onPressed: () async {
                clearController();
              }),
          SizedBox(
            width: MediaQuery.of(context).size.width / 50,
          ),
          FloatingActionButton(
              heroTag: "stbtn1",
              elevation: 9.0,
              tooltip: "Scan Barcode",
              backgroundColor: Colors.indigoAccent,
              onPressed: () async {
                barcodeController.clear();
                String? scanBarcode = (await (scanBarcodeNormal()));
                if (scanBarcode == "-1") {
                  barcodeController.text = "";
                  FocusScope.of(context).unfocus();
                  clearController();
                  FocusScope.of(context).requestFocus(barcodeNode);
                } else {
                  getBarcode(scanBarcode!);
                  barcodeController.text = scanBarcode;
                  barcodeController.selection = TextSelection.fromPosition(
                      TextPosition(offset: barcodeController.text.length));
                }
              },
              child: const Icon(Icons.add_a_photo)),
        ]));
  }
}
