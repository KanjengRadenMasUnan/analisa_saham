class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String publishedAt;
  final String sourceName;

  Article({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Tidak ada judul',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source'] != null ? json['source']['name'] : 'News',
    );
  }
}