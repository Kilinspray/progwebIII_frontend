import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../transactions/repository.dart';
import '../../../transactions/model.dart';
import '../../../categories/repository.dart';
import '../../../categories/model.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool loading = true;
  Transaction? _transaction;
  Account? _account;
  Category? _category;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ApiClient();
    try {
      _transaction = await TransactionsRepository(api).getById(widget.transactionId);
      
      // Load account
      try {
        _account = await AccountsRepository(api).getById(_transaction!.contaId);
      } catch (_) {}
      
      // Load category if exists
      if (_transaction!.categoriaId != null) {
        try {
          _category = await CategoriesRepository(api).getById(_transaction!.categoriaId!);
        } catch (_) {}
      }
      
      if (!mounted) return;
      setState(() => loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar transação';
        loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Excluir Transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
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

    final api = ApiClient();
    try {
      await TransactionsRepository(api).delete(widget.transactionId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir transação')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Transação')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Transação')),
        body: Center(child: Text(_errorMessage ?? 'Transação não encontrada', style: const TextStyle(color: Colors.red))),
      );
    }

    final tx = _transaction!;
    final isExpense = tx.tipo == CategoryType.despesa;
    final valueColor = isExpense ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Transação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/transactions/edit', arguments: tx.id);
              if (result == true) _load();
            },
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Valor destacado
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: valueColor.withValues(alpha: 0.2),
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: valueColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${isExpense ? '-' : '+'} R\$ ${tx.valor.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tx.tipo.apiValue,
                      style: TextStyle(color: valueColor.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Informações
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tx.descricao != null && tx.descricao!.isNotEmpty) ...[
                      _buildInfoRow('Descrição', tx.descricao!, Icons.description),
                      const Divider(color: Colors.white24),
                    ],
                    _buildInfoRow('Data', _formatDate(tx.data), Icons.calendar_today),
                    const Divider(color: Colors.white24),
                    _buildInfoRow('Conta', _account?.nome ?? 'ID: ${tx.contaId}', Icons.account_balance_wallet),
                    if (_category != null) ...[
                      const Divider(color: Colors.white24),
                      _buildInfoRow('Categoria', _category!.nome, Icons.category),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
