import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:jobtrack_uni/domain/usecases/get_job_cards.dart';
import 'package:jobtrack_uni/domain/usecases/save_job_cards.dart';
import 'package:jobtrack_uni/domain/repositories/job_repository.dart';

class FakeJobRepository implements JobRepository {
  List<JobCard> store = [];

  @override
  Future<List<JobCard>> getJobCards() async {
    return store;
  }

  @override
  Future<void> saveJobCards(List<JobCard> cards) async {
    store = List.from(cards);
  }
}

void main() {
  late FakeJobRepository fakeRepo;
  late GetJobCards getJobCards;
  late SaveJobCards saveJobCards;

  setUp(() {
    fakeRepo = FakeJobRepository();
    getJobCards = GetJobCards(fakeRepo);
    saveJobCards = SaveJobCards(fakeRepo);
  });

  test('GetJobCards returns empty list initially', () async {
    final result = await getJobCards();
    expect(result, isEmpty);
  });

  test('SaveJobCards stores and GetJobCards returns stored cards', () async {
    final sample = JobCard(
      id: '1',
      companyName: 'Acme',
      jobTitle: 'Intern',
      status: 'Aplicado',
      notes: 'Note',
      appliedDate: DateTime.now(),
    );

    await saveJobCards([sample]);
    final result = await getJobCards();
    expect(result.length, 1);
    expect(result.first.companyName, 'Acme');
  });
}
