class UserSettingDto {
  final String id;
  final String key;
  final String value;

  UserSettingDto({required this.id, required this.key, required this.value});

  factory UserSettingDto.fromJson(Map<String, dynamic> json) => UserSettingDto(
        id: json['id']?.toString() ?? '',
        key: json['key']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'key': key, 'value': value};
}
