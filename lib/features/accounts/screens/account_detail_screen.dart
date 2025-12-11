import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class AccountDetailScreen extends StatefulWidget {
  final int accountId;
  const AccountDetailScreen({super.key, required this.accountId});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  bool loading = true;
  Account? _account;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ApiClient();
    final repo = AccountsRepository(api);
    try {
      final acc = await repo.getById(widget.accountId);
      if (!mounted) return;
      setState(() {
        _account = acc;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar conta';
        loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Excluir Conta'),
        content: const Text('Tem certeza que deseja excluir esta conta?'),
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
    final repo = AccountsRepository(api);
    try {
      await repo.delete(widget.accountId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir conta')),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
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
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
        appBar: AppBar(title: const Text('Detalhes da Conta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Conta')),
        body: Center(child: Text(_errorMessage ?? 'Conta não encontrada', style: const TextStyle(color: Colors.red))),
      );
    }

    final acc = _account!;
    return Scaffold(
      appBar: AppBar(
        title: Text(acc.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/accounts/edit', arguments: acc.id);
              if (result == true) _load();
            },
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Tipo', acc.tipo.apiValue, Icons.category),
                const Divider(color: Colors.white24),
                _buildInfoRow('Saldo Inicial', 'R\$ ${acc.saldoInicial.toStringAsFixed(2)}', Icons.flag),
                const Divider(color: Colors.white24),
                _buildInfoRow(
                  'Saldo Atual',
                  'R\$ ${acc.saldoAtual.toStringAsFixed(2)}',
                  acc.saldoAtual >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
                if (acc.limiteCredito != null) ...[
                  const Divider(color: Colors.white24),
                  _buildInfoRow('Limite de Crédito', 'R\$ ${acc.limiteCredito!.toStringAsFixed(2)}', Icons.credit_card),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
