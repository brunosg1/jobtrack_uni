import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrack_uni/features/settings/data/dtos/user_setting_dto.dart';
import 'package:jobtrack_uni/features/settings/data/mappers/user_setting_mapper.dart';

void main() {
  test('UserSettingMapper DTO <-> Entity', () {
    final dto = UserSettingDto(id: 'u1', key: 'theme', value: 'dark');
    final mapper = UserSettingMapper();
    final ent = mapper.toEntity(dto);
    final round = mapper.toDto(ent);
    expect(round.key, 'theme');
    expect(round.value, 'dark');
  });
}
