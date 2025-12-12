import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrack_uni/features/providers/data/dtos/provider_dto.dart';
import 'package:jobtrack_uni/features/providers/data/mappers/provider_mapper.dart';

void main() {
  test('ProviderMapper DTO <-> Entity', () {
    final dto = ProviderDto(id: '1', name: ' ACME ', email: 'a@b.com', phone: '123', notes: 'ok', createdAt: '2025-01-01T00:00:00Z');
    final mapper = ProviderMapper();
    final ent = mapper.toEntity(dto);
    final round = mapper.toDto(ent);
    expect(round.id, '1');
    expect(round.name, 'ACME');
    expect(round.email, 'a@b.com');
  });
}
