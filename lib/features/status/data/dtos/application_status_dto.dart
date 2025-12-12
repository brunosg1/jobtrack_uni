class ApplicationStatusDto {
  final String id;
  final String key;
  final String label;
  final String? colorHex;

  ApplicationStatusDto({required this.id, required this.key, required this.label, this.colorHex});

  factory ApplicationStatusDto.fromJson(Map<String, dynamic> json) => ApplicationStatusDto(
        id: json['id']?.toString() ?? '',
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        colorHex: json['color_hex'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'label': label,
        'color_hex': colorHex,
      };
}
