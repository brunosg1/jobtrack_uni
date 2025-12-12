import 'package:jobtrack_uni/features/settings/data/dtos/user_setting_dto.dart';
import 'package:jobtrack_uni/features/settings/domain/entities/user_setting.dart';

class UserSettingMapper {
  UserSetting toEntity(UserSettingDto dto) => UserSetting(id: dto.id, key: dto.key, value: dto.value);

  UserSettingDto toDto(UserSetting entity) => UserSettingDto(id: entity.id, key: entity.key, value: entity.value);
}
