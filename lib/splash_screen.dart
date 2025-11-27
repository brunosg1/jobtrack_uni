import 'package:flutter/material.dart';
import 'package:jobtrack_uni/home_screen.dart';
import 'package:jobtrack_uni/onboarding_screen.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Executa após o primeiro frame para garantir que o BuildContext
    // já esteja inserido na árvore e que o Provider esteja disponível.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideNextScreen();
    });
  }

  Future<void> _decideNextScreen() async {
    // Pequeno atraso para a splash ser visível.
    await Future.delayed(const Duration(seconds: 2));

    final prefsService = Provider.of<PrefsService>(context, listen: false);

    // Lógica de roteamento de arranque (RF-5).
    final hasAccepted = prefsService.hasAcceptedCurrentPolicies();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => hasAccepted ? const HomeScreen() : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone do app (RF-8). Placeholder até gerarmos o ícone real.
            Icon(
              Icons.work_history,
              size: 80,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            Text(
              'JobTrack Uni',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
