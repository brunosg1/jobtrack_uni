class ProviderDto {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? notes;
  final String? createdAt; // ISO string as returned by backend

  ProviderDto({required this.id, required this.name, this.email, this.phone, this.notes, this.createdAt});

  factory ProviderDto.fromJson(Map<String, dynamic> json) => ProviderDto(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'notes': notes,
        'created_at': createdAt,
      };
}
