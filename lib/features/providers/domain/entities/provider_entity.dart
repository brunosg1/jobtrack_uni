import 'package:flutter/foundation.dart';

@immutable
class ProviderEntity {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  ProviderEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  static ProviderEntity fromJson(Map<String, dynamic> json) => ProviderEntity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      );
}
