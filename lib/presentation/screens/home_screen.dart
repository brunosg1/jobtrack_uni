import 'package:flutter/material.dart';
import 'package:jobtrack_uni/presentation/screens/add_card_screen.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:jobtrack_uni/presentation/widgets/job_card_widget.dart';
import 'package:jobtrack_uni/features/job_card/presentation/dialogs/provider_actions_dialog.dart';
import 'package:jobtrack_uni/features/job_card/presentation/dialogs/job_card_form_dialog.dart';
import 'package:jobtrack_uni/features/job_card/presentation/widgets/provider_list_view.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:jobtrack_uni/features/app/theme_controller.dart';
import 'package:jobtrack_uni/features/sync/sync_service.dart';
import 'package:jobtrack_uni/presentation/screens/settings_screen.dart';
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
  bool _isRefreshing = false;
  bool _showSuccess = false;
  DateTime? _lastSyncAt;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final getJobCards = Provider.of<GetJobCards>(context, listen: false);
    final cards = await getJobCards();
    if (mounted) {
      setState(() {
        _jobCards = cards;
        // load last sync timestamp
        final prefs = Provider.of<PrefsService>(context, listen: false);
        _lastSyncAt = prefs.getLastSyncAt();
      });
    }
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

  // Revocation of consent is now handled in the Settings screen.

  @override
  Widget build(BuildContext context) {
  // PrefsService can be obtained in settings screen when needed.

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(title: const Text('JobTrack Uni')),
              const Divider(),
              // Theme switch
              Consumer<ThemeController>(
                builder: (context, controller, _) {
                  final brightness = Theme.of(context).brightness;
                  String subtitle;
                  if (controller.mode == ThemeMode.system) {
                    subtitle = 'Seguindo sistema';
                  } else if (controller.isDarkMode) {
                    subtitle = 'Ativado (Escuro)';
                  } else {
                    subtitle = 'Desativado (Claro)';
                  }

                  return SwitchListTile(
                    title: const Text('Tema escuro'),
                    subtitle: Text(subtitle),
                    value: controller.isDarkMode || (controller.mode == ThemeMode.system && brightness == Brightness.dark),
                    onChanged: (_) async {
                      await controller.toggle(brightness);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minhas Vagas'),
            if (_lastSyncAt != null)
              Text(
                'Última: ${TimeOfDay.fromDateTime(_lastSyncAt!).format(context)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: _isRefreshing
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 40,
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.0, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    )
                  : _showSuccess
                      ? Icon(Icons.check_circle, key: const ValueKey('success'), color: Colors.greenAccent)
                      : IconButton(
                          key: const ValueKey('refresh_button'),
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            await _handleRefresh();
                          },
                        ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _jobCards.isEmpty ? _buildEmptyStateScroll() : _buildCardList(),
      ),
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

  Widget _buildEmptyStateScroll() {
    // Provide a scrollable area so RefreshIndicator can work on empty state.
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: _buildEmptyState(),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    final sync = Provider.of<SyncService>(context, listen: false);
    try {
      await sync.syncAll();
      await _loadCards();
      // Save last sync time and show success animation
      final now = DateTime.now();
      final prefs = Provider.of<PrefsService>(context, listen: false);
      await prefs.setLastSyncAt(now);
      setState(() => _lastSyncAt = now);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atualizado')));
      if (mounted) {
        setState(() => _showSuccess = true);
        // keep the check icon visible briefly
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) setState(() => _showSuccess = false);
      }
    } catch (e) {
      await _loadCards();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Atualização falhou: $e')));
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
}
