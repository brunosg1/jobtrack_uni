import 'package:flutter/material.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';

class AddCardScreen extends StatefulWidget {
  final JobCard? initialCard;
  const AddCardScreen({super.key, this.initialCard});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _notesController;

  String _selectedStatus = 'Aplicado'; // Valor inicial
  final List<String> _statuses = ['Aplicado', 'Entrevistando', 'Oferta Recebida', 'Recusado', 'Arquivado'];

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final newCard = JobCard(
        id: widget.initialCard?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: _companyController.text,
        jobTitle: _jobTitleController.text,
        status: _selectedStatus,
        notes: _notesController.text,
        appliedDate: widget.initialCard?.appliedDate ?? DateTime.now(),
      );
      // Retorna o novo card para a tela anterior (HomeScreen)
      Navigator.of(context).pop(newCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa controllers a partir do initialCard
    _companyController = TextEditingController(text: widget.initialCard?.companyName ?? '');
    _jobTitleController = TextEditingController(text: widget.initialCard?.jobTitle ?? '');
    _notesController = TextEditingController(text: widget.initialCard?.notes ?? '');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Nova Vaga'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Nome da Empresa'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Título da Vaga'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Anotações (Opcional)'),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveCard,
                child: const Text('Salvar Vaga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
