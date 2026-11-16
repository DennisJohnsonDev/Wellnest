enum ArticleKind { publication, news }

class ArticleFigure {
  const ArticleFigure({
    required this.title,
    required this.labels,
    required this.values,
    required this.unit,
  });

  final String title;
  final List<String> labels;
  final List<double> values;
  final String unit;
}

class Article {
  const Article({
    required this.id,
    required this.kind,
    required this.source,
    required this.title,
    required this.authors,
    required this.hoursAgo,
    required this.readMinutes,
    required this.topic,
    required this.summary,
    required this.body,
    this.keyFindings = const [],
    this.figure,
    this.doi,
    this.featured = false,
  });

  final String id;
  final ArticleKind kind;
  final String source;
  final String title;
  final String authors;
  final int hoursAgo;
  final int readMinutes;
  final String topic;
  final String summary;
  final List<String> body;
  final List<String> keyFindings;
  final ArticleFigure? figure;
  final String? doi;
  final bool featured;

  bool get isPublication => kind == ArticleKind.publication;

  DateTime get publishedAt =>
      DateTime.now().subtract(Duration(hours: hoursAgo));

  int get seed => id.codeUnits.fold(11, (h, c) => (h * 37 + c) & 0x7fffffff);
}
