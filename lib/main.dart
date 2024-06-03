import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/movie/movie_bloc.dart';
import 'bloc/movie/movie_event.dart';
import 'movie_screen.dart';
import 'tmdb_api_service.dart';

void main() {
  final TMDBApiService apiService = TMDBApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final TMDBApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: BlocProvider(
        create: (context) => MovieBloc(apiService)..add(FetchMovies()),
        child: MovieScreen(apiService: apiService),
      ),
    );
  }
}




