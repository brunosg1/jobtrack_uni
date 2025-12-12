import 'package:jobtrack_uni/features/providers/data/dtos/provider_dto.dart';
import 'package:jobtrack_uni/features/providers/domain/entities/provider_entity.dart';

class ProviderMapper {
  ProviderEntity toEntity(ProviderDto dto) {
    return ProviderEntity(
      id: dto.id,
      name: dto.name.trim(),
      email: dto.email?.trim(),
      phone: dto.phone?.trim(),
      notes: dto.notes?.trim(),
      createdAt: dto.createdAt != null ? DateTime.parse(dto.createdAt!) : null,
    );
  }

  ProviderDto toDto(ProviderEntity entity) {
    return ProviderDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
