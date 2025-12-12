import 'package:jobtrack_uni/features/status/data/dtos/application_status_dto.dart';
import 'package:jobtrack_uni/features/status/domain/entities/application_status.dart';

class ApplicationStatusMapper {
  ApplicationStatus toEntity(ApplicationStatusDto dto) {
    return ApplicationStatus(id: dto.id, key: dto.key.trim(), label: dto.label.trim(), colorHex: dto.colorHex);
  }

  ApplicationStatusDto toDto(ApplicationStatus entity) {
    return ApplicationStatusDto(id: entity.id, key: entity.key, label: entity.label, colorHex: entity.colorHex);
  }
}
