import 'package:jobtrack_uni/domain/repositories/job_repository.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:jobtrack_uni/prefs_service.dart';

class SharedPrefsJobRepository implements JobRepository {
  final PrefsService _prefsService;

  SharedPrefsJobRepository(this._prefsService);

  @override
  Future<List<JobCard>> getJobCards() async {
    // PrefsService currently returns a synchronous List<JobCard>, keep compat
    return _prefsService.getJobCards();
  }

  @override
  Future<void> saveJobCards(List<JobCard> cards) async {
    await _prefsService.saveJobCards(cards);
  }
}
