import 'package:flutter/material.dart';
import 'package:jobtrack_uni/presentation/screens/add_card_screen.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:jobtrack_uni/presentation/widgets/job_card_widget.dart';
import 'package:jobtrack_uni/features/job_card/presentation/dialogs/provider_actions_dialog.dart';
import 'package:jobtrack_uni/features/job_card/presentation/dialogs/job_card_form_dialog.dart';
import 'package:jobtrack_uni/features/job_card/presentation/widgets/provider_list_view.dart';
import 'package:jobtrack_uni/presentation/screens/onboarding_screen.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:provider/provider.dart';
import 'package:jobtrack_uni/domain/usecases/get_job_cards.dart';
import 'package:jobtrack_uni/domain/usecases/save_job_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JobCard> _jobCards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    final getJobCards = Provider.of<GetJobCards>(context, listen: false);
    getJobCards().then((cards) {
      if (mounted) {
        setState(() {
          _jobCards = cards;
        });
      }
    });
  }

  void _saveCards() {
    final saveJobCards = Provider.of<SaveJobCards>(context, listen: false);
    saveJobCards(_jobCards);
  }

  void _navigateAndAddCard() async {
    final newCard = await Navigator.of(context).push<JobCard>(
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );

    if (newCard != null) {
      setState(() {
        _jobCards.add(newCard);
      });
      _saveCards();
    }
  }

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

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Consentimento revogado.'),
                    action: SnackBarAction(
                      label: 'Desfazer',
                      onPressed: () async {
                         await prefsService.saveConsent();
                      },
                    ),
                  ),
                );
                
                await Future.delayed(const Duration(seconds: 4));

                if (!prefsService.hasAcceptedCurrentPolicies() && mounted) {
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
        title: const Text('Minhas Vagas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showRevokeConsentDialog(context, prefsService);
            },
          ),
        ],
      ),
      body: _jobCards.isEmpty ? _buildEmptyState() : _buildCardList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddCard,
        tooltip: 'Adicionar Vaga',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    );
  }

  Widget _buildCardList() {
    return ProviderListView(
      items: _jobCards,
      onConfirmRemoveFromStorage: (id) async {
        final prefs = Provider.of<PrefsService>(context, listen: false);
        final current = prefs.getJobCards();
        final updated = current.where((c) => c.id != id).toList();
        await prefs.saveJobCards(updated);
      },
      onItemRemoved: (id) {
        setState(() {
          _jobCards.removeWhere((c) => c.id == id);
        });
      },
      itemBuilder: (card) => GestureDetector(
        onLongPress: () {
          showProviderActionsDialog(
            context,
            title: 'Ações da vaga',
            subtitle: '${card.companyName} - ${card.jobTitle}',
            onEdit: () async {
              final edited = await showJobCardFormDialog(context, initialCard: card);
              if (edited != null) {
                setState(() {
                  final idx = _jobCards.indexWhere((c) => c.id == card.id);
                  if (idx != -1) _jobCards[idx] = edited;
                });
                _saveCards();
              }
            },
            onRemove: () async {
              setState(() {
                _jobCards.removeWhere((c) => c.id == card.id);
              });
              _saveCards();
            },
          );
        },
        child: JobCardWidget(card: card),
      ),
    );
  }
}
