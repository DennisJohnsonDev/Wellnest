import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnest/features/cme/data/cme_providers.dart';
import 'package:wellnest/features/library/data/library_providers.dart';
import 'package:wellnest/features/licence/data/licence.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('licence starts inside the renewal window', () {
    final licence = container.read(licenceProvider);

    expect(licence.status, LicenceStatus.renewalDue);
    expect(licence.daysRemaining, 42);
  });

  test('renewing extends the licence by a year', () {
    final before = container.read(licenceProvider).expiresOn;

    container.read(licenceProvider.notifier).renew();
    final after = container.read(licenceProvider);

    expect(after.isRenewed, isTrue);
    expect(after.validFrom, before);
    expect(
      after.expiresOn,
      DateTime(before.year + 1, before.month, before.day),
    );
    expect(after.reference, isNotNull);
  });

  test('completing modules stops at the last module', () {
    final course = container.read(courseProvider('heat-illness'));
    final progress = container.read(cmeProgressProvider.notifier);

    for (var i = 0; i < course.modules.length + 2; i++) {
      progress.completeNext(course);
    }

    expect(
      container.read(cmeProgressProvider)[course.id],
      course.modules.length,
    );
  });

  test('claiming a certificate adds its credits once', () {
    final course = container.read(courseProvider('heat-illness'));
    final before = container.read(cmeCreditsProvider);

    container.read(certificatesProvider.notifier)
      ..claim(course)
      ..claim(course);

    expect(container.read(cmeCreditsProvider), before + course.credits);
  });

  test('bookmarks toggle on and off', () {
    final bookmarks = container.read(bookmarksProvider.notifier);

    expect(bookmarks.toggle('cac-expatriates'), isTrue);
    expect(container.read(bookmarksProvider), contains('cac-expatriates'));
    expect(bookmarks.toggle('cac-expatriates'), isFalse);
    expect(
      container.read(bookmarksProvider),
      isNot(contains('cac-expatriates')),
    );
  });
}
