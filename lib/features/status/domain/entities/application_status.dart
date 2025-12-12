import 'package:flutter/foundation.dart';

@immutable
class ApplicationStatus {
  final String id;
  final String key;
  final String label;
  final String? colorHex; // optional color hex string

  const ApplicationStatus({required this.id, required this.key, required this.label, this.colorHex});
}
