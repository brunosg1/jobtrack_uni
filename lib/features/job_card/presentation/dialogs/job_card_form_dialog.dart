import 'package:flutter/material.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:jobtrack_uni/presentation/screens/add_card_screen.dart';

/// Mostra o formulário de criação/edição de JobCard como um diálogo/modal.
/// Retorna o JobCard criado/alterado ou null se cancelado.
Future<JobCard?> showJobCardFormDialog(BuildContext context, {JobCard? initialCard}) {
  return showDialog<JobCard>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: 600,
          height: 600,
          child: AddCardScreen(initialCard: initialCard),
        ),
      );
    },
  );
}
