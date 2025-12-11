import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../categories/repository.dart';
import '../../../categories/model.dart';

class CategoryEditScreen extends StatefulWidget {
  final int categoryId;
  const CategoryEditScreen({super.key, required this.categoryId});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  CategoryType _tipo = CategoryType.despesa;
  bool loading = true;
  bool saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final api = ApiClient();
    final repo = CategoriesRepository(api);
    try {
      final cat = await repo.getById(widget.categoryId);
      if (!mounted) return;
      setState(() {
        _nome.text = cat.nome;
        _tipo = cat.tipo;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar categoria';
        loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      saving = true;
      _errorMessage = null;
    });
    final api = ApiClient();
    final repo = CategoriesRepository(api);
    try {
      final payload = CategoryUpdate(
        nome: _nome.text.trim(),
        tipo: _tipo,
      );
      await repo.update(widget.categoryId, payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao atualizar categoria');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Categoria')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Categoria')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade700),
                      ),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome da categoria', prefixIcon: Icon(Icons.label)),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CategoryType>(
                    initialValue: _tipo,
                    decoration: const InputDecoration(labelText: 'Tipo', prefixIcon: Icon(Icons.swap_vert)),
                    items: CategoryType.values.map((t) {
                      final isExpense = t == CategoryType.despesa;
                      return DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Icon(
                              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isExpense ? Colors.red : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(t.apiValue),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _tipo = v ?? CategoryType.despesa),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving ? null : _save,
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
