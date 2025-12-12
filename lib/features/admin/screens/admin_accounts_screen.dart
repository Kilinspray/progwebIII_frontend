import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  List<Account>? _accounts;
  bool _loading = true;
  bool _hasPermission = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final api = ApiClient();
    final accountsRepo = AccountsRepository(api);

    try {
      final accounts = await accountsRepo.listAllAdmin();
      setState(() => _accounts = accounts);
    } catch (e) {
      // Verificar se é erro 403 (sem permissão)
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        setState(() => _hasPermission = false);
      } else {
        setState(() => _errorMessage = 'Erro ao carregar contas: $e');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildNoPermissionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Você não tem permissão para acessar esta área.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Apenas administradores podem visualizar todas as contas.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasPermission ? 'Admin - Todas as Contas' : 'Acesso Negado'),
        actions: _hasPermission ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccounts,
          ),
        ] : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildNoPermissionScreen()
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAccounts,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : _accounts == null || _accounts!.isEmpty
                  ? const Center(child: Text('Nenhuma conta encontrada'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _accounts!.length,
                      itemBuilder: (context, index) {
                        final account = _accounts![index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(account.tipo.name[0].toUpperCase()),
                            ),
                            title: Text(account.nome),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${account.id} | Usuário ID: ${account.usuarioId}'),
                                Text('Tipo: ${account.tipo.name}'),
                                Text(
                                  'Saldo Atual: ${account.saldoAtual.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: account.saldoAtual >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}
