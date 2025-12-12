import 'package:jobtrack_uni/domain/repositories/job_repository.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';

class SaveJobCards {
  final JobRepository repository;
  SaveJobCards(this.repository);

  Future<void> call(List<JobCard> cards) async {
    await repository.saveJobCards(cards);
  }
}
