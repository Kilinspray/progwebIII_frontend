import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../users/repository.dart';
import '../../../users/model.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final api = ApiClient();
    try {
      _currentUser = await UsersRepository(api).getCurrentUser();
      _isAdmin = _currentUser?.role.name.toLowerCase() == 'admin';
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Painel Administrativo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              const Text(
                'Você não tem permissão para acessar esta área.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.account_balance),
              ),
              title: const Text('Todas as Contas'),
              subtitle: const Text('Visualizar contas de todos os usuários'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, '/admin/accounts'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.swap_horiz),
              ),
              title: const Text('Todas as Transferências'),
              subtitle: const Text('Visualizar transferências de todos os usuários'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, '/admin/transfers'),
            ),
          ),
        ],
      ),
    );
  }
}
