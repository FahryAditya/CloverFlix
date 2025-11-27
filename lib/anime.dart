class Anime {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String bannerUrl;
  final List<String> genres;
  final double rating;
  final int totalEpisodes;
  final String status; // ongoing, completed
  final int? releaseYear;

  Anime({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.bannerUrl,
    required this.genres,
    required this.rating,
    required this.totalEpisodes,
    required this.status,
    this.releaseYear,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? 'No description available',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
      bannerUrl: json['banner_url'] ?? json['bannerUrl'] ?? '',
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : [],
      rating: (json['rating'] ?? 0).toDouble(),
      totalEpisodes: json['total_episodes'] ?? json['totalEpisodes'] ?? 0,
      status: json['status'] ?? 'unknown',
      releaseYear: json['release_year'] ?? json['releaseYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'banner_url': bannerUrl,
      'genres': genres,
      'rating': rating,
      'total_episodes': totalEpisodes,
      'status': status,
      'release_year': releaseYear,
    };
  }

  // For demo/testing purposes
  static List<Anime> getDemoAnime() {
    return [
      Anime(
        id: '1',
        title: 'Attack on Titan',
        description: 'Humanity lives within cities surrounded by enormous walls as a defense against the Titans.',
        thumbnailUrl: 'https://via.placeholder.com/300x400/1E88E5/FFFFFF?text=AOT',
        bannerUrl: 'https://via.placeholder.com/800x300/1E88E5/FFFFFF?text=AOT+Banner',
        genres: ['Action', 'Drama', 'Fantasy'],
        rating: 9.0,
        totalEpisodes: 87,
        status: 'completed',
        releaseYear: 2013,
      ),
      Anime(
        id: '2',
        title: 'Demon Slayer',
        description: 'A family is attacked by demons and only two members survive - Tanjiro and his sister.',
        thumbnailUrl: 'https://via.placeholder.com/300x400/FF5722/FFFFFF?text=Demon+Slayer',
        bannerUrl: 'https://via.placeholder.com/800x300/FF5722/FFFFFF?text=DS+Banner',
        genres: ['Action', 'Adventure', 'Supernatural'],
        rating: 8.7,
        totalEpisodes: 44,
        status: 'ongoing',
        releaseYear: 2019,
      ),
      Anime(
        id: '3',
        title: 'My Hero Academia',
        description: 'A superhero-loving boy without any powers enrolls in a prestigious hero academy.',
        thumbnailUrl: 'https://via.placeholder.com/300x400/4CAF50/FFFFFF?text=MHA',
        bannerUrl: 'https://via.placeholder.com/800x300/4CAF50/FFFFFF?text=MHA+Banner',
        genres: ['Action', 'Comedy', 'School'],
        rating: 8.4,
        totalEpisodes: 113,
        status: 'ongoing',
        releaseYear: 2016,
      ),
      Anime(
        id: '4',
        title: 'One Piece',
        description: 'Monkey D. Luffy sets off on an adventure to become the King of the Pirates.',
        thumbnailUrl: 'https://via.placeholder.com/300x400/FFC107/FFFFFF?text=One+Piece',
        bannerUrl: 'https://via.placeholder.com/800x300/FFC107/FFFFFF?text=OP+Banner',
        genres: ['Action', 'Adventure', 'Fantasy'],
        rating: 8.9,
        totalEpisodes: 1000,
        status: 'ongoing',
        releaseYear: 1999,
      ),
    ];
  }
}