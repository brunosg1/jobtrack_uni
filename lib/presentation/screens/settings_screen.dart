import 'package:flutter/material.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:provider/provider.dart';
import 'package:jobtrack_uni/presentation/screens/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PrefsService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Limpar cache'),
            subtitle: const Text('Remove dados em cache (ex.: cards de vaga).'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Limpar cache'),
                  content: const Text('Deseja realmente limpar o cache? Essa ação removerá os cards salvos localmente.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirmar')),
                  ],
                ),
              );

              if (confirmed == true) {
                await prefs.clearCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache limpo.')));
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Revogar consentimento'),
            subtitle: const Text('Revoga o consentimento e retorna ao fluxo de onboarding.'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Revogar Consentimento'),
                  content: const Text('Você tem certeza que deseja revogar o consentimento? Você será redirecionado para a tela de consentimento.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirmar')),
                  ],
                ),
              );

              if (confirmed == true) {
                await prefs.revokeConsent();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Consentimento revogado.'),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () async {
                          await prefs.saveConsent();
                        },
                      ),
                    ),
                  );
                }
                // Delay to show snackbar then navigate
                await Future.delayed(const Duration(seconds: 2));
                if (!prefs.hasAcceptedCurrentPolicies() && context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
