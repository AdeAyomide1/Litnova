class BookModel {
  final String id;
  final String title;
  final String? description;
  final String genre;
  final String type;
  final String? coverUrl;
  final String? authorName;
  final String status;
  final double averageRating;
  final int totalReads;
  final bool isFeatured;

  BookModel({
    required this.id,
    required this.title,
    this.description,
    required this.genre,
    required this.type,
    this.coverUrl,
    this.authorName,
    required this.status,
    required this.averageRating,
    required this.totalReads,
    required this.isFeatured,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      genre: json['genre'] ?? '',
      type: json['type'] ?? '',
      coverUrl: json['cover_url'],
      authorName: json['author_name'],
      status: json['status'] ?? 'Ongoing',
      averageRating: double.tryParse(
        json['average_rating']?.toString() ?? '0',
      ) ?? 0.0,
      totalReads: int.tryParse(
        json['total_reads']?.toString() ?? '0',
      ) ?? 0,
      isFeatured: json['is_featured'] ?? false,
    );
  }
}
