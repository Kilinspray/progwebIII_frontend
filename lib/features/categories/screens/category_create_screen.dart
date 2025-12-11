import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../categories/repository.dart';
import '../../../categories/model.dart';

class CategoryCreateScreen extends StatefulWidget {
  const CategoryCreateScreen({super.key});

  @override
  State<CategoryCreateScreen> createState() => _CategoryCreateScreenState();
}

class _CategoryCreateScreenState extends State<CategoryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  CategoryType _tipo = CategoryType.despesa;
  bool loading = false;
  String? _errorMessage;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      _errorMessage = null;
    });
    final api = ApiClient();
    final repo = CategoriesRepository(api);
    try {
      final payload = CategoryCreate(
        nome: _nome.text.trim(),
        tipo: _tipo,
      );
      await repo.create(payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao criar categoria');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Categoria')),
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
                      onPressed: loading ? null : _save,
                      child: loading
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
