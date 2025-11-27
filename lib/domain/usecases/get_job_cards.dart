import 'package:jobtrack_uni/domain/repositories/job_repository.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';

class GetJobCards {
  final JobRepository repository;
  GetJobCards(this.repository);

  Future<List<JobCard>> call() async {
    return await repository.getJobCards();
  }
}
