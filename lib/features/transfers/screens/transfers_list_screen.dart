import 'package:flutter/material.dart';

import '../../../transfers/repository.dart';
import '../../../transfers/model.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';
import '../../../core/api_client.dart';

class TransfersListScreen extends StatefulWidget {
  const TransfersListScreen({super.key});

  @override
  State<TransfersListScreen> createState() => _TransfersListScreenState();
}

class _TransfersListScreenState extends State<TransfersListScreen> {
  List<Transfer> transfers = [];
  Map<int, Account> accountsMap = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final api = ApiClient();
    try {
      // Load accounts first for mapping
      final accounts = await AccountsRepository(api).listAll();
      accountsMap = {for (var a in accounts) a.id: a};
      
      // Load transfers
      transfers = await TransfersRepository(api).listAll();
      transfers.sort((a, b) => b.data.compareTo(a.data));
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getAccountName(int id) {
    return accountsMap[id]?.nome ?? 'Conta #$id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transferências')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : transfers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('Nenhuma transferência', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transfers.length,
                    itemBuilder: (context, i) {
                      final tr = transfers[i];
                      return Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withValues(alpha: 0.2),
                            child: const Icon(Icons.swap_horiz, color: Colors.blue),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getAccountName(tr.contaOrigemId),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: Colors.blue, size: 16),
                              Expanded(
                                child: Text(
                                  _getAccountName(tr.contaDestinoId),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            _formatDate(tr.data),
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: Text(
                            'R\$ ${tr.valor.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/transfers/detail',
                              arguments: tr.id,
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
          final result = await Navigator.pushNamed(context, '/transfers/create');
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
