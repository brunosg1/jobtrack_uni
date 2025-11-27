import 'package:jobtrack_uni/job_card_model.dart';

abstract class JobRepository {
  Future<void> saveJobCards(List<JobCard> cards);
  Future<List<JobCard>> getJobCards();
}
