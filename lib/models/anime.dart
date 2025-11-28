class Anime {
  final int id;
  final String titleRomaji;
  final String? titleEnglish;
  final String? titleNative;
  final String? bannerImage;
  final String coverImage;
  final List<String> genres;
  final String? description;
  final String? trailerId;
  final String? trailerSite;
  final String? format;
  final int? episodes;
  final int? duration;
  final String? status;
  final String? source;
  final String? season;
  final int? seasonYear;
  final String? studio;
  final int? score;
  final int? popularity;
  final int? favourites;
  final int? rank;
  final List<AiringSchedule> airingSchedules;
  final List<Character> characters;

  Anime({
    required this.id,
    required this.titleRomaji,
    this.titleEnglish,
    this.titleNative,
    this.bannerImage,
    required this.coverImage,
    this.genres = const [],
    this.description,
    this.trailerId,
    this.trailerSite,
    this.format,
    this.episodes,
    this.duration,
    this.status,
    this.source,
    this.season,
    this.seasonYear,
    this.studio,
    this.score,
    this.popularity,
    this.favourites,
    this.rank,
    this.airingSchedules = const [],
    this.characters = const [],
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? {};
    final coverImage = json['coverImage'] ?? {};
    final trailer = json['trailer'];
    final studios = json['studios']?['nodes'] as List?;
    final rankings = json['rankings'] as List?;
    
    int? rank;
    if (rankings != null && rankings.isNotEmpty) {
      final ratedRanking = rankings.firstWhere(
        (r) => r['type'] == 'RATED',
        orElse: () => rankings.first,
      );
      rank = ratedRanking['rank'];
    }

    final airingScheduleData = json['airingSchedule']?['nodes'] as List? ?? [];
    final airingSchedules = airingScheduleData
        .map((e) => AiringSchedule.fromJson(e))
        .toList();

    final charactersData = json['characters']?['edges'] as List? ?? [];
    final characters = charactersData
        .map((e) => Character.fromJson(e))
        .toList();

    return Anime(
      id: json['id'],
      titleRomaji: title['romaji'] ?? 'Unknown',
      titleEnglish: title['english'],
      titleNative: title['native'],
      bannerImage: json['bannerImage'],
      coverImage: coverImage['extraLarge'] ?? coverImage['large'] ?? '',
      genres: (json['genres'] as List?)?.cast<String>() ?? [],
      description: json['description'],
      trailerId: trailer?['id'],
      trailerSite: trailer?['site'],
      format: json['format'],
      episodes: json['episodes'],
      duration: json['duration'],
      status: json['status'],
      source: json['source'],
      season: json['season'],
      seasonYear: json['seasonYear'],
      studio: studios?.isNotEmpty == true ? studios!.first['name'] : null,
      score: json['averageScore'],
      popularity: json['popularity'],
      favourites: json['favourites'],
      rank: rank,
      airingSchedules: airingSchedules,
      characters: characters,
    );
  }
}

class AiringSchedule {
  final int episode;
  final int airingAt;
  final int? timeUntilAiring;

  AiringSchedule({
    required this.episode,
    required this.airingAt,
    this.timeUntilAiring,
  });

  factory AiringSchedule.fromJson(Map<String, dynamic> json) {
    return AiringSchedule(
      episode: json['episode'] ?? 0,
      airingAt: json['airingAt'] ?? 0,
      timeUntilAiring: json['timeUntilAiring'],
    );
  }

  DateTime get airingDateTime => DateTime.fromMillisecondsSinceEpoch(airingAt * 1000);
}

class Character {
  final int id;
  final String name;
  final String image;
  final String role;

  Character({
    required this.id,
    required this.name,
    required this.image,
    required this.role,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final node = json['node'] ?? {};
    final name = node['name'] ?? {};
    final image = node['image'] ?? {};

    return Character(
      id: node['id'] ?? 0,
      name: name['full'] ?? 'Unknown',
      image: image['large'] ?? '',
      role: json['role'] ?? 'UNKNOWN',
    );
  }
}