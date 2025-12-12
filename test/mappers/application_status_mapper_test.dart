import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrack_uni/features/status/data/dtos/application_status_dto.dart';
import 'package:jobtrack_uni/features/status/data/mappers/application_status_mapper.dart';

void main() {
  test('ApplicationStatusMapper DTO <-> Entity', () {
    final dto = ApplicationStatusDto(id: 's1', key: 'interview', label: 'Interview', colorHex: '#ff0000');
    final mapper = ApplicationStatusMapper();
    final ent = mapper.toEntity(dto);
    final round = mapper.toDto(ent);
    expect(round.id, 's1');
    expect(round.key, 'interview');
    expect(round.label, 'Interview');
  });
}
