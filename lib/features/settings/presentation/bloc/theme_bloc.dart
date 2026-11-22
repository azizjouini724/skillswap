import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Le choix est sauvegardé : il survit à la fermeture de l'app.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'theme_mode';
  final SharedPreferences prefs;

  ThemeBloc(this.prefs) : super(ThemeState(_read(prefs))) {
    on<ThemeModeChanged>((event, emit) async {
      emit(ThemeState(event.mode));
      await prefs.setString(_key, event.mode.name);
    });
  }

  static ThemeMode _read(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.light,
    );
  }
}