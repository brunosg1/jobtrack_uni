import 'package:flutter/material.dart';
import 'package:jobtrack_uni/prefs_service.dart';

/// Controller responsável pelo estado do tema e sua persistência.
class ThemeController extends ChangeNotifier {
  final PrefsService _prefs;

  ThemeMode _mode = ThemeMode.system;

  ThemeController(this._prefs);

  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  /// Carrega a preferência salva (ou usa [ThemeMode.system] por padrão).
  Future<void> load() async {
    final saved = _prefs.getThemeMode();
    _mode = saved;
    notifyListeners();
  }

  /// Define explicitamente o modo, persiste e notifica ouvintes.
  Future<void> setMode(ThemeMode newMode) async {
    if (newMode == _mode) return;
    _mode = newMode;
    await _prefs.setThemeMode(newMode);
    notifyListeners();
  }

  /// Alterna entre claro e escuro levando em conta o brilho atual do sistema
  /// quando o modo atual é [ThemeMode.system].
  ///
  /// [contextBrightness] deve ser obtido por quem invoca (ex.: Theme.of(context).brightness).
  Future<void> toggle(Brightness contextBrightness) async {
    // Determine se o modo efetivo atual é escuro.
    final effectiveIsDark = _mode == ThemeMode.system
        ? (contextBrightness == Brightness.dark)
        : (_mode == ThemeMode.dark);

    final ThemeMode next = effectiveIsDark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }
}
