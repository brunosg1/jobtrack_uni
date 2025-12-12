import 'package:jobtrack_uni/domain/entities/job_card.dart';

abstract class JobRepository {
  Future<void> saveJobCards(List<JobCard> cards);
  Future<List<JobCard>> getJobCards();
}
