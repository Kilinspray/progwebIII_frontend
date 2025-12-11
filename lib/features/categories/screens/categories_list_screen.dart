import 'package:flutter/material.dart';

import '../../../categories/repository.dart';
import '../../../categories/model.dart';
import '../../../core/api_client.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  final repo = CategoriesRepository(ApiClient());
  List<Category> categories = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      categories = await repo.listAll();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> _delete(Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Excluir Categoria'),
        content: Text('Deseja excluir "${cat.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await repo.delete(cat.id);
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir categoria')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final despesas = categories.where((c) => c.tipo == CategoryType.despesa).toList();
    final receitas = categories.where((c) => c.tipo == CategoryType.receita).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Despesas', icon: Icon(Icons.arrow_downward, color: Colors.red)),
              Tab(text: 'Receitas', icon: Icon(Icons.arrow_upward, color: Colors.green)),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(despesas, Colors.red),
                  _buildList(receitas, Colors.green),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/categories/create');
            if (result == true) _load();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildList(List<Category> list, Color color) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('Nenhuma categoria', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final cat = list[i];
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(Icons.label, color: color),
              ),
              title: Text(cat.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/categories/edit', arguments: cat.id);
                      if (result == true) _load();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete(cat),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
