class Correction {
  final String? id;
  final String contactId;
  final String fieldName;
  final String originalOcr;
  final String originalParsed;
  final String correctedValue;
  final String fieldType;
  final DateTime createdAt;

  const Correction({
    this.id,
    required this.contactId,
    required this.fieldName,
    required this.originalOcr,
    required this.originalParsed,
    required this.correctedValue,
    required this.fieldType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'contactId': contactId,
    'fieldName': fieldName,
    'originalOcr': originalOcr,
    'originalParsed': originalParsed,
    'correctedValue': correctedValue,
    'fieldType': fieldType,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
    id: json['id'],
    contactId: json['contactId'],
    fieldName: json['fieldName'],
    originalOcr: json['originalOcr'],
    originalParsed: json['originalParsed'],
    correctedValue: json['correctedValue'],
    fieldType: json['fieldType'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
