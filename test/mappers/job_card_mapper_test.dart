import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrack_uni/features/job_card/data/dtos/job_card_dto.dart';
import 'package:jobtrack_uni/features/job_card/data/mappers/job_card_mapper.dart';

void main() {
  test('JobCardMapper DTO <-> Entity', () {
    final dto = JobCardDto(id: 'j1', companyName: ' Co ', jobTitle: 'Dev', status: 'applied', notes: null, appliedDate: '2025-01-02T12:00:00Z');
    final mapper = JobCardMapper();
    final ent = mapper.toEntity(dto);
    final round = mapper.toDto(ent);
    expect(round.id, 'j1');
    expect(round.companyName, 'Co');
    expect(round.status, 'applied');
  });
}
