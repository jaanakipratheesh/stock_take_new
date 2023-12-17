import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ScanData extends StatefulWidget {
  @override
  _ScanDataState createState() => _ScanDataState();
}

class _ScanDataState extends State<ScanData> {
  TextEditingController barcodeTxt = TextEditingController();
  FocusNode barcodeFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: RawKeyboardListener(
        onKey: (key) {
          if (key.runtimeType.toString() == 'RawKeyDownEvent') {
            barcodeTxt.text += key.data.keyLabel;

            if (barcodeTxt.text.contains('\n')) {
              // your custom `enter key` fun
              handleBarcodeScan();
            }
          }
        },
        focusNode: barcodeFocusNode,
        child: TextField(
          textInputAction: TextInputAction.go,
          controller: barcodeTxt,
          autofocus: false,
          onSubmitted: (val) {
            // enter key handler
            handleBarcodeScan();
          },
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  void handleBarcodeScan() {
    // Implement your logic for handling barcode scanning
    print("Handling barcode scan: ${barcodeTxt.text}");
    // You can perform navigation, data processing, or any other action here

    // Clear the text field after processing the barcode
    barcodeTxt.clear();
  }
}