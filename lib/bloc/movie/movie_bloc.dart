import 'package:flutter_bloc/flutter_bloc.dart';
import '../../tmdb_api_service.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final TMDBApiService apiService;

  MovieBloc(this.apiService) : super(MovieInitial()) {
    on<FetchMovies>(_onFetchMovies);
  }

  void _onFetchMovies(FetchMovies event, Emitter<MovieState> emit) async {
    emit(MovieLoading());
    try {
      final movies = await apiService.fetchPopularMovies();
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(const MovieError('Failed to fetch movies'));
    }
  }
}
