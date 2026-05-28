class SourceModel {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final String language;
  final bool isInstalled;
  final bool isOfficial;
  final List<String> contentTypes;

  const SourceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.language,
    required this.isInstalled,
    required this.isOfficial,
    required this.contentTypes,
  });

  SourceModel copyWith({bool? isInstalled}) {
    return SourceModel(
      id: id,
      name: name,
      description: description,
      iconEmoji: iconEmoji,
      language: language,
      isInstalled: isInstalled ?? this.isInstalled,
      isOfficial: isOfficial,
      contentTypes: contentTypes,
    );
  }
}

class SourceBook {
  final String id;
  final String title;
  final String? coverUrl;
  final String? description;
  final String? author;
  final String? status;
  final String? genre;
  final String sourceId;
  final String type;

  const SourceBook({
    required this.id,
    required this.title,
    this.coverUrl,
    this.description,
    this.author,
    this.status,
    this.genre,
    required this.sourceId,
    required this.type,
  });
}

class SourceChapter {
  final String id;
  final String title;
  final String? chapterNumber;
  final String? publishedAt;
  final String sourceId;
  final String? externalUrl;

  const SourceChapter({
    required this.id,
    required this.title,
    this.chapterNumber,
    this.publishedAt,
    required this.sourceId,
    this.externalUrl,
  });
}
