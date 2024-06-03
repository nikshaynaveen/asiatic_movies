import 'package:equatable/equatable.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<dynamic> movies;

  const MovieLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object> get props => [message];
}
