import 'dart:convert';

class BoletoModel {
  final String? name;
  final String? dueDate;
  final double? valeu;
  final String? barcode;
  BoletoModel({
    this.name,
    this.dueDate,
    this.valeu,
    this.barcode,
  });

  BoletoModel copyWith({
    String? name,
    String? dueDate,
    double? valeu,
    String? barcode,
  }) {
    return BoletoModel(
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      valeu: valeu ?? this.valeu,
      barcode: barcode ?? this.barcode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dueDate': dueDate,
      'valeu': valeu,
      'barcode': barcode,
    };
  }

  factory BoletoModel.fromMap(Map<String, dynamic> map) {
    return BoletoModel(
      name: map['name'],
      dueDate: map['dueDate'],
      valeu: map['valeu'],
      barcode: map['barcode'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BoletoModel.fromJson(String source) =>
      BoletoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BoletoModel(name: $name, dueDate: $dueDate, valeu: $valeu, barcode: $barcode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BoletoModel &&
        other.name == name &&
        other.dueDate == dueDate &&
        other.valeu == valeu &&
        other.barcode == barcode;
  }

  @override
  int get hashCode {
    return name.hashCode ^ dueDate.hashCode ^ valeu.hashCode ^ barcode.hashCode;
  }
}
