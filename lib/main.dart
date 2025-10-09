import 'package:flutter/material.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:jobtrack_uni/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // Garante que os bindings do Flutter foram inicializados antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cria uma instância única do nosso serviço de preferências.
  final prefsService = PrefsService();
  await prefsService.init();

  runApp(
    // Usa o Provider para disponibilizar o PrefsService na árvore de widgets.
    Provider<PrefsService>.value(
      value: prefsService,
      child: const JobTrackUniApp(),
    ),
  );
}

class JobTrackUniApp extends StatelessWidget {
  const JobTrackUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a paleta de cores baseada no PRD.
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B1220), // Navy (Primária)
      primary: const Color(0xFF0B1220),   // Navy
      secondary: const Color(0xFF06B6D4), // Cyan
      tertiary: const Color(0xFFF59E0B),  // Amber (Acento)
      brightness: Brightness.dark,       // Tema escuro para alto contraste
    );

    return MaterialApp(
      title: 'JobTrack Uni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.primary,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16.0),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
        // Suporte para escalabilidade de texto.
        platform: TargetPlatform.android,

        // --- TEMAS DE BOTÃO PARA MELHORAR VISIBILIDADE ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: colorScheme.onPrimary, // Cor do texto do botão (geralmente branco para escuro)
            backgroundColor: colorScheme.tertiary, // Cor de fundo do botão (Amber para destaque)
            disabledBackgroundColor: colorScheme.tertiary.withOpacity(0.5), // Amber mais claro quando desabilitado
            disabledForegroundColor: colorScheme.onTertiary.withOpacity(0.5), // Texto mais claro quando desabilitado
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.secondary, // Cor do texto do TextButton (Cyan para destaque)
            disabledForegroundColor: colorScheme.secondary.withOpacity(0.5), // Cyan mais claro quando desabilitado
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
