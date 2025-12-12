import 'package:flutter/material.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:jobtrack_uni/domain/repositories/job_repository.dart';
import 'package:jobtrack_uni/data/repositories/shared_prefs_job_repository.dart';
import 'package:jobtrack_uni/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:jobtrack_uni/domain/usecases/get_job_cards.dart';
import 'package:jobtrack_uni/domain/usecases/save_job_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobtrack_uni/features/providers/data/repositories/supabase_providers_repository.dart';
import 'package:jobtrack_uni/features/providers/domain/repositories/providers_repository.dart';
import 'package:jobtrack_uni/features/sync/sync_service.dart';
import 'package:jobtrack_uni/features/app/theme_controller.dart';
// Fallback local secrets. Create `lib/secrets/supabase_config.dart` with your
// real project values to use local credentials during development.
import 'package:jobtrack_uni/secrets/supabase_config.dart' as local_secrets;

void main() async {
  // Garante que os bindings do Flutter foram inicializados antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cria uma instância única do nosso serviço de preferências.
  final prefsService = PrefsService();
  await prefsService.init();

  // Theme controller (loads saved theme)
  final themeController = ThemeController(prefsService);
  await themeController.load();

  // First try values from --dart-define (CI/Prod friendly)
  String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANNON_KEY');

  // Fallback to local example secrets if dart-define wasn't used.
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    supabaseUrl = local_secrets.SupabaseConfig.url;
    supabaseAnonKey = local_secrets.SupabaseConfig.anonKey;
  }

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  final supabaseClient = Supabase.instance.client;

  // Cria repositório que implementa a abstração JobRepository
  final JobRepository jobRepository = SharedPrefsJobRepository(prefsService);

  // Usecases
  final getJobCards = GetJobCards(jobRepository);
  final saveJobCards = SaveJobCards(jobRepository);

  // Providers repository backed by Supabase (uses placeholder `Provider` entity)
  final ProvidersRepository providersRepository = SupabaseProvidersRepository(
    supabaseClient,
    supabaseUrl: supabaseUrl.isNotEmpty ? supabaseUrl : null,
    supabaseAnonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : null,
  );

  final syncService = SyncService(
    client: supabaseClient,
    prefs: prefsService,
    supabaseUrl: supabaseUrl.isNotEmpty ? supabaseUrl : null,
    supabaseAnonKey: supabaseAnonKey.isNotEmpty ? supabaseAnonKey : null,
  );

  // No automatic debug sync or probe in main; sync is triggered explicitly via UI.

  runApp(
    // Usa o Provider para disponibilizar tanto PrefsService quanto JobRepository na árvore de widgets.
    MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefsService),
        Provider<JobRepository>.value(value: jobRepository),
        // Fornece o Supabase client e a implementação do repositório de providers
        Provider<SupabaseClient>.value(value: supabaseClient),
        Provider<ProvidersRepository>.value(value: providersRepository),
  Provider<SyncService>.value(value: syncService),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        Provider<GetJobCards>.value(value: getJobCards),
        Provider<SaveJobCards>.value(value: saveJobCards),
      ],
      child: JobTrackUniApp(),
    ),
  );
}

class JobTrackUniApp extends StatelessWidget {
  JobTrackUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a paleta de cores baseada no PRD. Light/dark schemes are built below.
    // Listen to theme controller to update app theme dynamically
    final themeController = Provider.of<ThemeController>(context, listen: true);

    // Build two color schemes (light and dark) from the same brand seed/colors
    final Color seed = const Color(0xFF0B1220);
    final Color primary = const Color(0xFF0B1220);
    final Color secondary = const Color(0xFF06B6D4);
    final Color tertiary = const Color(0xFFF59E0B);

    final ColorScheme lightScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
    );

    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.primary,
      platform: TargetPlatform.android,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: lightScheme.onPrimary,
          backgroundColor: tertiary,
          disabledBackgroundColor: tertiary.withOpacity(0.5),
          disabledForegroundColor: lightScheme.onTertiary.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: secondary, disabledForegroundColor: secondary.withOpacity(0.5)),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.primary,
      platform: TargetPlatform.android,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkScheme.onPrimary,
          backgroundColor: tertiary,
          disabledBackgroundColor: tertiary.withOpacity(0.5),
          disabledForegroundColor: darkScheme.onTertiary.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: secondary, disabledForegroundColor: secondary.withOpacity(0.5)),
      ),
    );

    return MaterialApp(
      title: 'JobTrack Uni',
      debugShowCheckedModeBanner: false,
      themeMode: themeController.mode,
      theme: lightTheme,
      darkTheme: darkTheme,
      // AppBarTheme for both themes can be left to ColorScheme but ensure no elevation
      home: const SplashScreen(),
      debugShowMaterialGrid: false,
    );
  }
}
