import 'package:flutter/material.dart';

import '../../../transactions/repository.dart';
import '../../../transactions/model.dart';
import '../../../categories/model.dart';
import '../../../core/api_client.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final repo = TransactionsRepository(ApiClient());
  List<Transaction> transactions = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      transactions = await repo.listAll();
      transactions.sort((a, b) => b.data.compareTo(a.data));
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('Nenhuma transação', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, i) {
                      final tx = transactions[i];
                      final isExpense = tx.tipo == CategoryType.despesa;
                      return Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpense
                                ? Colors.red.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                            child: Icon(
                              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            tx.descricao ?? 'Sem descrição',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _formatDate(tx.data),
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: Text(
                            '${isExpense ? '-' : '+'} R\$ ${tx.valor.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/transactions/detail',
                              arguments: tx.id,
                            );
                            if (result == true) _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/transactions/create');
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
