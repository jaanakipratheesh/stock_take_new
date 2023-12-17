class MasterFile {
  final String locId;
  final String barcode;
  final String description;

  MasterFile({
    required this.locId,
    required this.barcode,
    required this.description,
  });

  factory MasterFile.fromMap(Map<String, dynamic> map) {
    return MasterFile(
      locId: map['LocId'].toString(),
      barcode: map['Barcode'] as String,
      description: map['Description'] as String,
    );
  }

  MasterFile.fromMapObject(Map<String, dynamic> map)
      : locId = map['LocId'].toString(),
        barcode = map['Barcode'],
        description = map['Description']as String;

  Map<String, dynamic> toMap() {
    return {
      'LocId': locId,
      'Barcode': barcode,
      'Description': description,
    };
  }
}