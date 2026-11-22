part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeModeChanged extends ThemeEvent {
  final ThemeMode mode;
  const ThemeModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}