import 'package:flutter/material.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:jobtrack_uni/domain/repositories/job_repository.dart';
import 'package:jobtrack_uni/data/repositories/shared_prefs_job_repository.dart';
import 'package:jobtrack_uni/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:jobtrack_uni/domain/usecases/get_job_cards.dart';
import 'package:jobtrack_uni/domain/usecases/save_job_cards.dart';

void main() async {
  // Garante que os bindings do Flutter foram inicializados antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cria uma instância única do nosso serviço de preferências.
  final prefsService = PrefsService();
  await prefsService.init();

  // Cria repositório que implementa a abstração JobRepository
  final JobRepository jobRepository = SharedPrefsJobRepository(prefsService);

  // Usecases
  final getJobCards = GetJobCards(jobRepository);
  final saveJobCards = SaveJobCards(jobRepository);

  runApp(
    // Usa o Provider para disponibilizar tanto PrefsService quanto JobRepository na árvore de widgets.
    MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefsService),
        Provider<JobRepository>.value(value: jobRepository),
        Provider<GetJobCards>.value(value: getJobCards),
        Provider<SaveJobCards>.value(value: saveJobCards),
      ],
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
