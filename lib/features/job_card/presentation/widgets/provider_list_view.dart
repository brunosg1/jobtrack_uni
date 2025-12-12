import 'package:flutter/material.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';

typedef ConfirmRemoveFromStorage = Future<void> Function(String id);
typedef OnItemRemoved = void Function(String id);

class ProviderListView extends StatelessWidget {
  final List<JobCard> items;
  final ConfirmRemoveFromStorage onConfirmRemoveFromStorage;
  final OnItemRemoved onItemRemoved;
  final Widget Function(JobCard) itemBuilder;

  const ProviderListView({
    super.key,
    required this.items,
    required this.onConfirmRemoveFromStorage,
    required this.onItemRemoved,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final reversed = items.reversed.toList();
        final card = reversed[index];

        return Dismissible(
          key: ValueKey(card.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            // Confirmação modal não-dismissable
            final confirmed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (confirmContext) {
                return AlertDialog(
                  title: const Text('Remover fornecedor?'),
                  content: const Text('Tem certeza que deseja remover este fornecedor?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(false),
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(true),
                      child: const Text('Sim'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) return false;

            try {
              await onConfirmRemoveFromStorage(card.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fornecedor removido.')));
              return true;
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
              return false;
            }
          },
          onDismissed: (direction) {
            onItemRemoved(card.id);
          },
          background: Container(
            color: Colors.red.shade400,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: itemBuilder(card),
        );
      },
    );
  }
}
