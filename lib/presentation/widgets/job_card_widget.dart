import 'package:flutter/material.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:intl/intl.dart';

class JobCardWidget extends StatelessWidget {
  final JobCard card;

  const JobCardWidget({super.key, required this.card});

  // Função auxiliar para obter a cor com base no status
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'Entrevistando':
        return colorScheme.secondary; // Cyan
      case 'Oferta Recebida':
        return Colors.green.shade400;
      case 'Recusado':
        return Colors.red.shade400;
      case 'Arquivado':
        return Colors.grey.shade600;
      case 'Aplicado':
      default:
        return colorScheme.tertiary; // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(card.status, colorScheme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.primary.withBlue(30),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    card.companyName,
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    card.status,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              card.jobTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (card.notes != null && card.notes!.isNotEmpty) ...[
              Text(
                'Anotações:',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                card.notes!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Aplicado em: ${DateFormat('dd/MM/yyyy').format(card.appliedDate)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
