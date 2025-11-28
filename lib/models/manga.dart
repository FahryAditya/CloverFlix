class Manga {
  final String id;
  final String title;
  final String image;
  final String? description;
  final String? status;
  final List<String> genres;

  Manga({
    required this.id,
    required this.title,
    required this.image,
    this.description,
    this.status,
    this.genres = const [],
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    final title = attributes['title'] ?? {};
    final relationships = json['relationships'] as List? ?? [];
    
    String coverFileName = '';
    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        coverFileName = rel['attributes']?['fileName'] ?? '';
        break;
      }
    }

    final mangaId = json['id'] ?? '';
    final coverUrl = coverFileName.isNotEmpty
        ? 'https://uploads.mangadex.org/covers/$mangaId/$coverFileName'
        : '';

    final tags = attributes['tags'] as List? ?? [];
    final genres = tags
        .where((tag) => tag['attributes']?['group'] == 'genre')
        .map((tag) => tag['attributes']['name']['en'] as String)
        .toList();

    return Manga(
      id: mangaId,
      title: title['en'] ?? title['ja'] ?? title['ja-ro'] ?? 'Unknown',
      image: coverUrl,
      description: attributes['description']?['en'],
      status: attributes['status'],
      genres: genres,
    );
  }
}