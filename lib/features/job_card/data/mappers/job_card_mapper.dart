import 'package:jobtrack_uni/features/job_card/data/dtos/job_card_dto.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';

class JobCardMapper {
  JobCard toEntity(JobCardDto dto) {
    return JobCard(
      id: dto.id,
      companyName: dto.companyName.trim(),
      jobTitle: dto.jobTitle.trim(),
      status: dto.status.trim(),
      notes: dto.notes?.trim(),
      appliedDate: dto.appliedDate != null ? DateTime.parse(dto.appliedDate!) : DateTime.now(),
    );
  }

  JobCardDto toDto(JobCard entity) {
    return JobCardDto(
      id: entity.id,
      companyName: entity.companyName,
      jobTitle: entity.jobTitle,
      status: entity.status,
      notes: entity.notes,
      appliedDate: entity.appliedDate.toIso8601String(),
    );
  }
}
