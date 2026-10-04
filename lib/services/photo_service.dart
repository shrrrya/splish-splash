import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo.dart';
import '../secrets.dart';

class PhotoService {
  static const int perPage = 30;

  /// Empty query = general feed, non-empty = search
  Future<List<Photo>> fetch({String query = '', int page = 1}) async {
    final uri = Uri.parse('https://pixabay.com/api/').replace(
      queryParameters: {
        'key': pixabayApiKey,
        'q': query,
        'image_type': 'photo',
        'safesearch': 'true',
        'page': '$page',
        'per_page': '$perPage',
      },
    );

    final res = await http.get(uri);
    if (res.statusCode == 400 && page > 1) return []; // past the last page
    if (res.statusCode != 200) {
      throw Exception('Failed to load photos (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return (data['hits'] as List).map((j) => Photo.fromJson(j)).toList();
  }
}
