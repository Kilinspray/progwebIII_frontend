import 'package:flutter/material.dart';

import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';
import '../../../core/api_client.dart';

class AccountsListScreen extends StatefulWidget {
  const AccountsListScreen({super.key});

  @override
  State<AccountsListScreen> createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends State<AccountsListScreen> {
  final repo = AccountsRepository(ApiClient());
  List<Account> accounts = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      accounts = await repo.listAll();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  IconData _getIcon(AccountType tipo) {
    switch (tipo) {
      case AccountType.carteira:
        return Icons.account_balance_wallet;
      case AccountType.banco:
        return Icons.account_balance;
      case AccountType.cofre:
        return Icons.savings;
      case AccountType.investimento:
        return Icons.trending_up;
      case AccountType.outros:
        return Icons.more_horiz;
    }
  }

  Color _getSaldoColor(double saldo) {
    if (saldo > 0) return Colors.green;
    if (saldo < 0) return Colors.red;
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contas')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('Nenhuma conta cadastrada', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    itemBuilder: (context, i) {
                      final acc = accounts[i];
                      return Card(
                        color: Theme.of(context).cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade900,
                            child: Icon(_getIcon(acc.tipo), color: Colors.blue.shade300),
                          ),
                          title: Text(acc.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(acc.tipo.apiValue, style: const TextStyle(color: Colors.white54)),
                          trailing: Text(
                            'R\$ ${acc.saldoAtual.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getSaldoColor(acc.saldoAtual),
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.pushNamed(context, '/accounts/detail', arguments: acc.id);
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
          final result = await Navigator.pushNamed(context, '/accounts/create');
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
