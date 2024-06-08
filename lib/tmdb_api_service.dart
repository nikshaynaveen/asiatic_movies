import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/api_key.dart';

class TMDBApiService {
  static const String _apiKey = apiKey;
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<dynamic>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  String getImageUrl(String path) {
    return '$_imageBaseUrl$path';
  }
}
