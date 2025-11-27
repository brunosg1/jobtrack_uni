import 'package:flutter/material.dart';

/// Diálogo reutilizável que apresenta ações para um item (provider)
/// Opções: Editar, Remover, Fechar.
///
/// - [onEdit] será chamado quando o usuário selecionar "Editar".
/// - [onRemove] será chamado quando o usuário confirmar a remoção.
/// O diálogo principal é não-dismissable tocando fora (barrierDismissible: false).
Future<void> showProviderActionsDialog(
  BuildContext context, {
  String title = 'Ações',
  String? subtitle,
  Future<void> Function()? onEdit,
  Future<void> Function()? onRemove,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: subtitle != null ? Text(subtitle) : null,
        actions: [
          TextButton(
            onPressed: () async {
              // Delegar edição
              Navigator.of(context).pop(); // fecha o diálogo de ações
              if (onEdit != null) {
                await onEdit();
              }
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () {
              // Abrir confirmação de remoção; se confirmado, chamar onRemove
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (confirmContext) {
                  return AlertDialog(
                    title: const Text('Confirmar remoção'),
                    content: const Text('Tem certeza que deseja remover este item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(confirmContext).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(confirmContext).pop(); // fecha confirmação
                          Navigator.of(context).pop(); // fecha diálogo de ações
                          if (onRemove != null) {
                            await onRemove();
                          }
                        },
                        child: const Text('Remover'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Remover'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}
