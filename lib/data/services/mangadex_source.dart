import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_source.dart';
import '../models/source_model.dart';
import 'package:flutter/foundation.dart';

class MangaDexSource implements BaseSource {
  static const String baseUrl = 'https://api.mangadex.org';
  static const String uploadsUrl = 'https://uploads.mangadex.org';

  // More aggressive headers to mimic a real browser/Tachiyomi
  static const Map<String, String> headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Referer': 'https://mangadex.org/',
    'Accept': 'application/json',
  };

  @override
  String get id => 'mangadex';

  @override
  String get name => 'MangaDex';

  @override
  String get iconEmoji => '🦊';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => false;

  @override
  List<String> get contentTypes => ['Manga', 'Manhwa', 'Manhua'];

  String _getTitle(Map<String, dynamic> attributes) {
    if (attributes['title'] != null && attributes['title']['en'] != null) {
      return attributes['title']['en'];
    }
    if (attributes['altTitles'] != null) {
      for (var altTitle in attributes['altTitles']) {
        if (altTitle['en'] != null) return altTitle['en'];
      }
    }
    if (attributes['title'] != null && attributes['title'].isNotEmpty) {
      return attributes['title'].values.first;
    }
    return 'Unknown Title';
  }

  String _getDescription(Map<String, dynamic> attributes) {
    if (attributes['description'] != null && attributes['description']['en'] != null) {
      return attributes['description']['en'];
    }
    return 'No description available.';
  }

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    try {
      final offset = (page - 1) * 20;
      final uri = Uri.parse(
        '$baseUrl/manga?'
        'limit=20&'
        'offset=$offset&'
        'includes[]=cover_art&'
        'includes[]=author&'
        'hasAvailableChapters=true&'
        'order[followedCount]=desc&'
        // Unified Tachiyomi style: removing contentRating filters to allow "everything" 
        // as requested by "illegal access" / "all content" vibe
        'contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic'
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangas = data['data'] as List;

        final books = <SourceBook>[];
        for (var manga in mangas) {
          final attributes = manga['attributes'];
          final relationships = manga['relationships'] as List;
          
          String? coverFileName;
          final coverRel = relationships.firstWhere(
            (rel) => rel['type'] == 'cover_art',
            orElse: () => null,
          );
          if(coverRel != null && coverRel['attributes'] != null){
              coverFileName = coverRel['attributes']['fileName'];
          }

          final coverUrl = coverFileName != null 
              ? '$uploadsUrl/covers/${manga['id']}/$coverFileName.512.jpg'
              : 'https://picsum.photos/seed/${manga['id']}/400/600';

          String author = 'Unknown';
          final authorRel = relationships.firstWhere(
            (rel) => rel['type'] == 'author',
            orElse: () => null,
          );
          if (authorRel != null && authorRel['attributes'] != null) {
              author = authorRel['attributes']['name'] ?? 'Unknown';
          }

          books.add(SourceBook(
            id: manga['id'],
            title: _getTitle(attributes),
            coverUrl: coverUrl,
            description: _getDescription(attributes),
            author: author,
            genre: 'Manga',
            status: attributes['status'] ?? 'Ongoing',
            sourceId: id,
            type: attributes['originalLanguage'] == 'ko' ? 'Manhwa' : 'Manga',
          ));
        }
        return books;
      }
    } catch (e) {
      debugPrint('MangaDex getPopular error: $e');
    }
    return [];
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    try {
      final offset = (page - 1) * 20;
      final uri = Uri.parse(
        '$baseUrl/manga?'
        'limit=20&'
        'offset=$offset&'
        'includes[]=cover_art&'
        'includes[]=author&'
        'hasAvailableChapters=true&'
        'order[latestUploadedChapter]=desc&'
        'contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic'
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangas = data['data'] as List;

        final books = <SourceBook>[];
        for (var manga in mangas) {
          final attributes = manga['attributes'];
          final relationships = manga['relationships'] as List;
          
          String? coverFileName;
          final coverRel = relationships.firstWhere(
            (rel) => rel['type'] == 'cover_art',
            orElse: () => null,
          );
          if(coverRel != null && coverRel['attributes'] != null){
              coverFileName = coverRel['attributes']['fileName'];
          }

          final coverUrl = coverFileName != null 
              ? '$uploadsUrl/covers/${manga['id']}/$coverFileName.512.jpg'
              : 'https://picsum.photos/seed/${manga['id']}/400/600'; 

          String author = 'Unknown';
          final authorRel = relationships.firstWhere(
            (rel) => rel['type'] == 'author',
            orElse: () => null,
          );
          if (authorRel != null && authorRel['attributes'] != null) {
              author = authorRel['attributes']['name'] ?? 'Unknown';
          }

          books.add(SourceBook(
            id: manga['id'],
            title: _getTitle(attributes),
            coverUrl: coverUrl,
            description: _getDescription(attributes),
            author: author,
            genre: 'Manga',
            status: attributes['status'] ?? 'Ongoing',
            sourceId: id,
            type: attributes['originalLanguage'] == 'ko' ? 'Manhwa' : 'Manga',
          ));
        }
        return books;
      }
    } catch (e) {
      debugPrint('MangaDex getLatest error: $e');
    }
    return [];
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    try {
      final offset = (page - 1) * 20;
      final uri = Uri.parse(
        '$baseUrl/manga?'
        'title=${Uri.encodeComponent(query)}&'
        'limit=20&'
        'offset=$offset&'
        'includes[]=cover_art&'
        'includes[]=author&'
        'contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic'
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangas = data['data'] as List;

        final books = <SourceBook>[];
        for (var manga in mangas) {
          final attributes = manga['attributes'];
          final relationships = manga['relationships'] as List;
          
          String? coverFileName;
          final coverRel = relationships.firstWhere(
            (rel) => rel['type'] == 'cover_art',
            orElse: () => null,
          );
          if(coverRel != null && coverRel['attributes'] != null){
              coverFileName = coverRel['attributes']['fileName'];
          }

          final coverUrl = coverFileName != null 
              ? '$uploadsUrl/covers/${manga['id']}/$coverFileName.512.jpg'
              : 'https://picsum.photos/seed/${manga['id']}/400/600';

          String author = 'Unknown';
          final authorRel = relationships.firstWhere(
            (rel) => rel['type'] == 'author',
            orElse: () => null,
          );
          if (authorRel != null && authorRel['attributes'] != null) {
              author = authorRel['attributes']['name'] ?? 'Unknown';
          }

          books.add(SourceBook(
            id: manga['id'],
            title: _getTitle(attributes),
            coverUrl: coverUrl,
            description: _getDescription(attributes),
            author: author,
            genre: 'Manga',
            status: attributes['status'] ?? 'Ongoing',
            sourceId: id,
            type: attributes['originalLanguage'] == 'ko' ? 'Manhwa' : 'Manga',
          ));
        }
        return books;
      }
    } catch (e) {
      debugPrint('MangaDex search error: $e');
    }
    return [];
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    try {
      // Fetching all available chapters including those with external links
      // to provide "illegal access" / unrestricted view where possible
      final uri = Uri.parse(
        '$baseUrl/manga/$bookId/feed?'
        'limit=500&'
        'translatedLanguage[]=en&'
        'order[chapter]=desc&'
        'order[volume]=desc&'
        'contentRating[]=safe&contentRating[]=suggestive&contentRating[]=erotica&contentRating[]=pornographic'
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chaptersData = data['data'] as List;

        return chaptersData.map((c) {
          final attributes = c['attributes'];
          return SourceChapter(
            id: c['id'],
            title: attributes['title'] ?? 'Chapter ${attributes['chapter'] ?? 'Unknown'}',
            chapterNumber: attributes['chapter'],
            publishedAt: attributes['publishAt'],
            sourceId: id,
            externalUrl: attributes['externalUrl'], // Capturing external URLs
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('MangaDex getChapters error: $e');
    }
    return [];
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    try {
      // Forcing Port 443 often helps with image loading issues
      final uri = Uri.parse('$baseUrl/at-home/server/$chapterId?forcePort443=true');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final baseUrlStr = data['baseUrl'];
        final hash = data['chapter']['hash'];
        final dataArray = data['chapter']['data'] as List; // Full quality

        // Constructing URLs carefully to bypass common bot detection
        return dataArray.map((file) => '$baseUrlStr/data/$hash/$file').toList();
      }
    } catch (e) {
      debugPrint('MangaDex getPages error: $e');
    }
    return [];
  }
}
