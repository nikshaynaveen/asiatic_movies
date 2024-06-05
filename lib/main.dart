// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/movie_screen.dart';
import 'package:myapp/splash_screen.dart';
import 'bloc/movie/movie_bloc.dart';
import 'bloc/movie/movie_event.dart';
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
      title: "Asiatic Movie",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(), // Start with SplashScreen
      routes: {
        '/movie_screen': (context) => BlocProvider(
              create: (context) => MovieBloc(apiService)..add(FetchMovies()),
              child: MovieScreen(apiService: apiService),
            ), // Route to MovieScreen
      },
    );
  }
}
