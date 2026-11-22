part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode mode;
  const ThemeState(this.mode);

  @override
  List<Object?> get props => [mode];
}