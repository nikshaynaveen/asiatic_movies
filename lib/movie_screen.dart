// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/bloc/movie/movie_bloc.dart';
import 'package:myapp/bloc/movie/movie_state.dart';
import 'package:myapp/tmdb_api_service.dart';
import 'package:share/share.dart';

class MovieScreen extends StatefulWidget {
  final TMDBApiService apiService;

  const MovieScreen({super.key, required this.apiService});

  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  String query = '';
  String filterGenre = 'All';
  List<String> genres = [
    'All',
    'Action',
    'Comedy',
    'Drama',
    'Horror',
    'Sci-Fi'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        centerTitle: true,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 250,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          query = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                        hintText: 'Search movies...',
                        fillColor: const Color.fromARGB(255, 49, 44, 44),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  DropdownButton<String>(
                    value: filterGenre,
                    icon: const Icon(Icons.filter_list),
                    onChanged: (String? newValue) {
                      setState(() {
                        filterGenre = newValue!;
                      });
                    },
                    items: genres.map<DropdownMenuItem<String>>((String genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                  ),
                ],
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
            final filteredMovies = state.movies.where((movie) {
              final titleLower = movie['title'].toLowerCase();
              final queryLower = query.toLowerCase();
              final genreMatch = filterGenre == 'All' ||
                  (movie['genre_ids'] as List)
                      .contains(genres.indexOf(filterGenre));
              return titleLower.contains(queryLower) && genreMatch;
            }).toList();

            return ListView.builder(
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                final posterPath = movie['poster_path'];
                // ignore: unused_local_variable
                final imageUrl = widget.apiService.getImageUrl(posterPath);

                return ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: Text(
                    movie['title'],
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdditionalImages(movie, widget.apiService),
                      MovieDescription(description: movie['overview']),
                      const SizedBox(height: 8),
                      Text(
                        'Release Date: ${movie['release_date']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Rating: ${movie['vote_average']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.rate_review,
                                color: Colors.blue),
                            onPressed: () => _showReviewDialog(context, movie),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_to_queue,
                                color: Colors.green),
                            onPressed: () => _addToWatchlist(movie),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.orange),
                            onPressed: () => _shareMovie(movie),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.comment, color: Colors.purple),
                            onPressed: () => _showCommentDialog(context, movie),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.play_arrow, color: Colors.red),
                            onPressed: () => _watchTrailer(context, movie),
                          ), // Add trailer button
                        ],
                      ),
                      _buildSimilarMovies(movie, state.movies),
                    ],
                  ),
                );
              },
            );
          } else if (state is MovieError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Unknown state',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAdditionalImages(
      Map<String, dynamic> movie, TMDBApiService apiService) {
    final posterPath = movie['poster_path'];
    final backdropPath = movie['backdrop_path'];
    final posterUrl = apiService.getImageUrl(posterPath);
    final backdropUrl = apiService.getImageUrl(backdropPath);

    // Define a page controller to control the page view
    PageController pageController = PageController(initialPage: 0);

    // Function to auto-scroll the page view
    void autoScroll() {
      Timer.periodic(const Duration(seconds: 3), (timer) {
        if (pageController.hasClients) {
          if (pageController.page! < 1) {
            pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          } else {
            pageController.jumpToPage(0);
          }
        }
      });
    }

    // Start auto-scrolling when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoScroll();
    });

    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: PageView(
            controller: pageController, // Assign the page controller
            children: [
              Image.network(posterUrl, fit: BoxFit.cover),
              Image.network(backdropUrl, fit: BoxFit.cover),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSimilarMovies(
      Map<String, dynamic> movie, List<dynamic> allMovies) {
    final genreIds = movie['genre_ids'] as List;
    final similarMovies = allMovies.where((m) {
      final mGenreIds = m['genre_ids'] as List;
      return m != movie && genreIds.any((genre) => mGenreIds.contains(genre));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text('You may also like...',
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarMovies.length,
            itemBuilder: (context, index) {
              final similarMovie = similarMovies[index];
              final posterPath = similarMovie['poster_path'];
              final imageUrl = widget.apiService.getImageUrl(posterPath);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Image.network(
                      imageUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      similarMovie['title'],
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rate and Review ${movie['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(labelText: 'Review'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              const Text('Rating'),
              RatingBar(
                onRatingUpdate: (rating) {
                  // Handle rating update
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Submit review
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addToWatchlist(Map<String, dynamic> movie) {
    // Add movie to watchlist logic
    // ignore: avoid_print
    print('Added to watchlist: ${movie['title']}');
  }

  void _shareMovie(Map<String, dynamic> movie) {
    Share.share('Check out this movie: ${movie['title']}');
  }

  void _showCommentDialog(BuildContext context, Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Comment on ${movie['title']}'),
          content: const TextField(
            decoration: InputDecoration(labelText: 'Comment'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Submit comment
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

void _watchTrailer(BuildContext context, Map<String, dynamic> movie) {
  // Show a dialog or navigate to a new screen to play the trailer
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Watch Trailer'),
        content: const Text('Add code to play the trailer here.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class MovieDescription extends StatefulWidget {
  final String description;

  const MovieDescription({super.key, required this.description});

  @override
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

class RatingBar extends StatelessWidget {
  final Function(double) onRatingUpdate;

  const RatingBar({super.key, required this.onRatingUpdate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: const Icon(Icons.star_border),
          color: Colors.yellow,
          onPressed: () {
            onRatingUpdate(index + 1.0);
          },
        );
      }),
    );
  }
}
