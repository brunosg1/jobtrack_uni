import 'dart:convert';

class JobCard {
  final String id;
  final String companyName;
  final String jobTitle;
  final String status;
  final String? notes;
  final DateTime appliedDate;

  JobCard({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.status,
    this.notes,
    required this.appliedDate,
  });

  // Método para converter um objeto JobCard em um Map (para JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'status': status,
      'notes': notes,
      'appliedDate': appliedDate.toIso8601String(),
    };
  }

  // Método de fábrica para criar um JobCard a partir de um Map (de JSON)
  factory JobCard.fromJson(Map<String, dynamic> json) {
    return JobCard(
      id: json['id'],
      companyName: json['companyName'],
      jobTitle: json['jobTitle'],
      status: json['status'],
      notes: json['notes'],
      appliedDate: DateTime.parse(json['appliedDate']),
    );
  }
}
