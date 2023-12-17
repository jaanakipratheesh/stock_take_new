class Settings {
  late  String defQty;
  late  String setQty;
  late String barcodeExtendedMode;

  Settings({
    required this.defQty,
    required this.setQty,
    required this.barcodeExtendedMode,
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      defQty: map['DefQty'].toString(),
      setQty: map['SetQty'] as String,
      barcodeExtendedMode: map['BarcodeExtendedMode'] as String,
    );
  }

  Settings.fromMapObject(Map<String, dynamic> map)
      : defQty = map['DefQty'].toString(),
        setQty = map['SetQty'],
        barcodeExtendedMode = map['BarcodeExtendedType']as String;

  Map<String, dynamic> toMap() {
    return {
      'DefQty': defQty,
      'SetQty': setQty,
      'BarcodeExtendedMode': barcodeExtendedMode,
    };
  }
}