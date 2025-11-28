class Manhwa {
  final String id;
  final String title;
  final String image;
  final String? description;
  final int? chapters;
  final List<String> genres;

  Manhwa({
    required this.id,
    required this.title,
    required this.image,
    this.description,
    this.chapters,
    this.genres = const [],
  });

  factory Manhwa.fromJson(Map<String, dynamic> json) {
    String coverUrl = '';
    
    if (json['md_covers'] != null && (json['md_covers'] as List).isNotEmpty) {
      final cover = json['md_covers'][0];
      coverUrl = cover['b2key'] != null 
          ? 'https://meo.comick.pictures/${cover['b2key']}'
          : (cover['gpurl'] ?? '');
    }

    final genresList = json['genres'] as List? ?? [];
    final genres = genresList.map((g) => g.toString()).toList();

    return Manhwa(
      id: json['slug'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown',
      image: coverUrl,
      description: json['desc'],
      chapters: json['chapter_count'],
      genres: genres,
    );
  }
}