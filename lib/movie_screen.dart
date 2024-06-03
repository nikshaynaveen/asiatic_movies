import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/bloc/movie/movie_bloc.dart';
import 'package:myapp/bloc/movie/movie_state.dart';
import 'package:myapp/tmdb_api_service.dart';

class MovieScreen extends StatelessWidget {
  final TMDBApiService apiService;

  const MovieScreen({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/logo.png',
                height: 100,
                width: 300,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovieLoaded) {
            return ListView.builder(
              itemCount: state.movies.length,
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                final posterPath = movie['poster_path'];
                final imageUrl = apiService.getImageUrl(posterPath);

                return ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 100,
                    height: 150, // Adjusted height for the leading image
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    movie['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: MovieDescription(
                    description: movie['overview'],
                  ),
                );
              },
            );
          } else if (state is MovieError) {
            return Center(child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ));
          } else {
            return const Center(child: Text(
              'Unknown state',
              style: TextStyle(color: Colors.white),
            ));
          }
        },
      ),
    );
  }
}

class MovieDescription extends StatefulWidget {
  final String description;

  const MovieDescription({super.key, required this.description});

  @override
  // ignore: library_private_types_in_public_api
  _MovieDescriptionState createState() => _MovieDescriptionState();
}

class _MovieDescriptionState extends State<MovieDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            widget.description,
            maxLines: isExpanded ? 100 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        if (!isExpanded && _isTextOverflow(widget.description))
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
              },
              child: const Text(
                'See More',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }

  bool _isTextOverflow(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white70),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);
    return textPainter.didExceedMaxLines;
  }
}