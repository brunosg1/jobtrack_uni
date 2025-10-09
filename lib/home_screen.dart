import 'package:flutter/material.dart';
import 'package:jobtrack_uni/onboarding_screen.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showRevokeConsentDialog(BuildContext context, PrefsService prefsService) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Revogar Consentimento'),
          content: const Text('Você tem certeza que deseja revogar o consentimento? Você será redirecionado para a tela de consentimento.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await prefsService.revokeConsent();

                // SnackBar com Desfazer (RF-6)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Consentimento revogado.'),
                    action: SnackBarAction(
                      label: 'Desfazer',
                      onPressed: () async {
                         // Se desfizer, restaura o aceite e não faz nada.
                         await prefsService.saveConsent();
                      },
                    ),
                  ),
                );
                
                // Aguarda o SnackBar terminar para ver se o usuário desfez.
                await Future.delayed(const Duration(seconds: 4));

                if (!prefsService.hasAcceptedCurrentPolicies()) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                      (Route<dynamic> route) => false,
                    );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefsService = Provider.of<PrefsService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('JobTrack Uni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Placeholder para tela de configurações.
              // A opção de revogar está aqui como exemplo.
               _showRevokeConsentDialog(context, prefsService);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustração "Hero/empty" (3.4)
              Icon(Icons.folder_copy_outlined, size: 120, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7)),
              const SizedBox(height: 24),
              Text(
                'Nenhuma vaga adicionada',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Toque no botão "+" para criar seu primeiro card de vaga e começar a organizar suas candidaturas.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação para criar o 1º card de vaga.
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Vaga',
      ),
    );
  }
}
