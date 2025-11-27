import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyViewer extends StatefulWidget {
  final String markdownAssetPath;
  final String title;

  const PolicyViewer({
    super.key,
    required this.markdownAssetPath,
    required this.title,
  });

  @override
  State<PolicyViewer> createState() => _PolicyViewerState();
}

class _PolicyViewerState extends State<PolicyViewer> {
  String _markdownData = "";
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedEnd = false;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadMarkdown() async {
    final data = await rootBundle.loadString(widget.markdownAssetPath);
    setState(() {
      _markdownData = data;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 10) {
      if (!_hasReachedEnd) {
        setState(() {
          _hasReachedEnd = true;
        });
      }
    }
    setState(() {
       _scrollProgress = _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize( // Barra de progresso de leitura (RF-3)
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _scrollProgress,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
      body: Markdown(
        controller: _scrollController,
        data: _markdownData,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyLarge,
          h1: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // Botão "Marcar como lido" habilitado no fim (RF-3).
          onPressed: _hasReachedEnd ? () {
            Navigator.of(context).pop(true);
          } : null,
          child: const Text('Marcar como Lido'),
        ),
      ),
    );
  }
}
