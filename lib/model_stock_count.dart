import 'dart:convert';

StockCount configFromJson(String str) {
  final jsonData = json.decode(str);
  return StockCount.fromMap(jsonData);
}

String configToJson(StockCount data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class StockCount {
  String recNo;
  String barcode;
  String qty;
  String nfplu;
  String dateTime;
  String? batchNo;
  String locId;
  String userName;

  StockCount(
      {
        required this.recNo,
        required this.barcode,
        required this.qty,
        required this.nfplu,
        required this.dateTime,
        required this.batchNo,
        required this.locId,
        required this.userName,
      });

  factory StockCount.fromMap(Map<String, dynamic> json) => StockCount(
      recNo:json["RecNo"].toString(),
      barcode: json["Barcode"],
      qty: json["Qty"],
      nfplu: json["Nfplu"],
      dateTime: json["DateTime"],
      batchNo: json["BatchNo"],
      locId: json["LocId"],
      userName: json["UserName"],
  );

    StockCount.fromMapObject(Map<String, dynamic> map)
      : recNo = map['RecNo'].toString(),
        barcode = map['Barcode'],
        qty = map['Qty'],
        nfplu = map['Nfplu'],
        dateTime = map['DateTime'],
        batchNo = map['BatchNo'],
        locId = map['LocId'],
        userName = map['UserName'];

  Map<String, dynamic> toMap() => {
    "RecNo":recNo,
    "Barcode": barcode,
    "Qty": qty,
    "Nfplu": nfplu,
    "DateTime": dateTime,
    "BatchNo": batchNo,
    "LocId": locId,
    "UserName": userName,
  };

  Map toJson() => {
    "RecNo":recNo,
    "Barcode": barcode,
    "Qty": qty,
    "Nfplu": nfplu,
    "DateTime": dateTime,
    "BatchNo": batchNo,
    "LocId": locId,
    "UserName": userName,
  };
}
