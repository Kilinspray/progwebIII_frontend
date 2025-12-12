import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_client.dart';
import '../../../transfers/repository.dart';
import '../../../transfers/model.dart';

class AdminTransfersScreen extends StatefulWidget {
  const AdminTransfersScreen({super.key});

  @override
  State<AdminTransfersScreen> createState() => _AdminTransfersScreenState();
}

class _AdminTransfersScreenState extends State<AdminTransfersScreen> {
  List<Transfer>? _transfers;
  bool _loading = true;
  bool _hasPermission = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final api = ApiClient();
    final transfersRepo = TransfersRepository(api);

    try {
      final transfers = await transfersRepo.listAllAdmin();
      setState(() => _transfers = transfers);
    } catch (e) {
      // Verificar se é erro 403 (sem permissão)
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        setState(() => _hasPermission = false);
      } else {
        setState(() => _errorMessage = 'Erro ao carregar transferências: $e');
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
            'Apenas administradores podem visualizar todas as transferências.',
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_hasPermission ? 'Admin - Todas as Transferências' : 'Acesso Negado'),
        actions: _hasPermission ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransfers,
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
                        onPressed: _loadTransfers,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : _transfers == null || _transfers!.isEmpty
                  ? const Center(child: Text('Nenhuma transferência encontrada'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transfers!.length,
                      itemBuilder: (context, index) {
                        final transfer = _transfers![index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.swap_horiz),
                            ),
                            title: Text(
                              'R\$ ${transfer.valor.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${transfer.id} | Usuário ID: ${transfer.usuarioId}'),
                                Text(
                                  'Origem: ${transfer.contaOrigemId} → Destino: ${transfer.contaDestinoId}',
                                ),
                                Text(
                                  'Data: ${dateFormat.format(transfer.data)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
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
