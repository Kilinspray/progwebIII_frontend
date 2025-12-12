import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../transactions/repository.dart';
import '../../../transactions/model.dart';
import '../../../categories/repository.dart';
import '../../../categories/model.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class TransactionEditScreen extends StatefulWidget {
  final int transactionId;
  const TransactionEditScreen({super.key, required this.transactionId});

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  CategoryType _tipo = CategoryType.despesa;
  double _valor = 0;
  DateTime _data = DateTime.now();
  int? _contaId;
  int? _categoriaId;
  
  List<Account> _accounts = [];
  List<Category> _categories = [];
  bool loadingData = true;
  bool saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ApiClient();
    try {
      // Load transaction
      final tx = await TransactionsRepository(api).getById(widget.transactionId);
      _descricao.text = tx.descricao ?? '';
      _valor = tx.valor;
      _tipo = tx.tipo;
      _data = tx.data;
      _contaId = tx.contaId;
      _categoriaId = tx.categoriaId;
      
      // Load accounts and categories
      _accounts = await AccountsRepository(api).listAll();
      _categories = await CategoriesRepository(api).listAll();
    } catch (_) {
      _errorMessage = 'Erro ao carregar dados';
    }
    if (mounted) setState(() => loadingData = false);
  }

  List<Category> get _filteredCategories =>
      _categories.where((c) => c.tipo == _tipo).toList();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              surface: Color(0xFF1a1f3a),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _data = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contaId == null) {
      setState(() => _errorMessage = 'Selecione uma conta');
      return;
    }
    
    setState(() {
      saving = true;
      _errorMessage = null;
    });
    
    final api = ApiClient();
    final repo = TransactionsRepository(api);
    try {
      final payload = TransactionUpdate(
        descricao: _descricao.text.trim().isEmpty ? null : _descricao.text.trim(),
        data: _data,
        contaId: _contaId!,
        categoriaId: _categoriaId,
      );
      await repo.update(widget.transactionId, payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao atualizar transação');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Transação')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isExpense = _tipo == CategoryType.despesa;
    final valueColor = isExpense ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Transação')),
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
                  
                  // Tipo e Valor (somente leitura)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: valueColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: valueColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                          color: valueColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_tipo.apiValue} - R\$ ${_valor.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: valueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipo e valor não podem ser alterados',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Descrição
                  TextFormField(
                    controller: _descricao,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conta
                  DropdownButtonFormField<int>(
                    value: _contaId,
                    decoration: const InputDecoration(
                      labelText: 'Conta',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: _accounts.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.nome),
                    )).toList(),
                    onChanged: (v) => setState(() => _contaId = v),
                    validator: (v) => v == null ? 'Selecione uma conta' : null,
                  ),
                  const SizedBox(height: 16),

                  // Categoria
                  DropdownButtonFormField<int?>(
                    value: _categoriaId,
                    decoration: const InputDecoration(
                      labelText: 'Categoria (opcional)',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sem categoria')),
                      ..._filteredCategories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nome),
                      )),
                    ],
                    onChanged: (v) => setState(() => _categoriaId = v),
                  ),
                  const SizedBox(height: 16),

                  // Data
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_data)),
                    ),
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
