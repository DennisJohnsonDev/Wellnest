import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'article.dart';
import 'library_content.dart';

final publicationsProvider = Provider<List<Article>>((ref) => publications);

final newsProvider = Provider<List<Article>>((ref) => news);

final articleProvider = Provider.family<Article, String>(
  (ref, id) => [...publications, ...news].firstWhere((a) => a.id == id),
);

class BookmarksController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {'remote-hf', 'carbapenem-gcc'};

  bool toggle(String id) {
    final saved = !state.contains(id);
    state = saved ? {...state, id} : ({...state}..remove(id));
    return saved;
  }
}

final bookmarksProvider = NotifierProvider<BookmarksController, Set<String>>(
  BookmarksController.new,
);
