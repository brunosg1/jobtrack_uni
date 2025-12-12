import 'package:flutter/foundation.dart';

@immutable
class UserSetting {
  final String id;
  final String key;
  final String value;

  const UserSetting({required this.id, required this.key, required this.value});
}
