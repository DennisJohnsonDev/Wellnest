import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import 'cme_catalogue.dart';
import 'course.dart';

const _creditsFromOtherActivities = 48.5;

final cmeCatalogueProvider = Provider<List<Course>>((ref) => cmeCatalogue);

final courseProvider = Provider.family<Course, String>(
  (ref, id) => ref.watch(cmeCatalogueProvider).firstWhere((c) => c.id == id),
);

class CmeProgressController extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {
    'acls-2026': 4,
    'ramadan-diabetes': 1,
    'uae-ethics': 4,
  };

  int completeNext(Course course) {
    final done = ((state[course.id] ?? 0) + 1).clamp(0, course.modules.length);
    state = {...state, course.id: done};
    return done;
  }
}

final cmeProgressProvider =
    NotifierProvider<CmeProgressController, Map<String, int>>(
      CmeProgressController.new,
    );

class CertificatesController extends Notifier<Map<String, DateTime>> {
  @override
  Map<String, DateTime> build() => {
    'uae-ethics': Formatters.today.subtract(const Duration(days: 38)),
  };

  void claim(Course course) {
    if (state.containsKey(course.id)) return;
    state = {...state, course.id: DateTime.now()};
  }
}

final certificatesProvider =
    NotifierProvider<CertificatesController, Map<String, DateTime>>(
      CertificatesController.new,
    );

final cmeCreditsProvider = Provider<double>((ref) {
  final claimed = ref.watch(certificatesProvider).keys.toSet();
  final catalogue = ref.watch(cmeCatalogueProvider);
  return catalogue
      .where((c) => claimed.contains(c.id))
      .fold(_creditsFromOtherActivities, (sum, c) => sum + c.credits);
});

final inProgressCoursesProvider = Provider<List<Course>>((ref) {
  final progress = ref.watch(cmeProgressProvider);
  return ref.watch(cmeCatalogueProvider).where((c) {
    final done = progress[c.id] ?? 0;
    return done > 0 && done < c.modules.length;
  }).toList();
});
