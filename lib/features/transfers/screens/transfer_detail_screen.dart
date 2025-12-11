import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../transfers/repository.dart';
import '../../../transfers/model.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class TransferDetailScreen extends StatefulWidget {
  final int transferId;
  const TransferDetailScreen({super.key, required this.transferId});

  @override
  State<TransferDetailScreen> createState() => _TransferDetailScreenState();
}

class _TransferDetailScreenState extends State<TransferDetailScreen> {
  bool loading = true;
  Transfer? _transfer;
  Account? _contaOrigem;
  Account? _contaDestino;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ApiClient();
    try {
      _transfer = await TransfersRepository(api).getById(widget.transferId);
      
      // Load accounts
      try {
        _contaOrigem = await AccountsRepository(api).getById(_transfer!.contaOrigemId);
      } catch (_) {}
      try {
        _contaDestino = await AccountsRepository(api).getById(_transfer!.contaDestinoId);
      } catch (_) {}
      
      if (!mounted) return;
      setState(() => loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar transferência';
        loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Excluir Transferência'),
        content: const Text('Tem certeza que deseja excluir esta transferência? Os saldos das contas serão revertidos.'),
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
      await TransfersRepository(api).delete(widget.transferId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir transferência')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Transferência')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _transfer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Transferência')),
        body: Center(child: Text(_errorMessage ?? 'Transferência não encontrada', style: const TextStyle(color: Colors.red))),
      );
    }

    final tr = _transfer!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Transferência'),
        actions: [
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
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      child: const Icon(Icons.swap_horiz, color: Colors.blue, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'R\$ ${tr.valor.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(tr.data),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Contas
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Conta Origem
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          child: const Icon(Icons.logout, color: Colors.red),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Conta de origem', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                _contaOrigem?.nome ?? 'Conta #${tr.contaOrigemId}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (_contaOrigem != null)
                                Text(
                                  'Saldo: R\$ ${_contaOrigem!.saldoAtual.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: _contaOrigem!.saldoAtual >= 0 ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Seta
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward, color: Colors.blue, size: 20),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                    ),
                    
                    // Conta Destino
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.green.withValues(alpha: 0.2),
                          child: const Icon(Icons.login, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Conta de destino', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                _contaDestino?.nome ?? 'Conta #${tr.contaDestinoId}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (_contaDestino != null)
                                Text(
                                  'Saldo: R\$ ${_contaDestino!.saldoAtual.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: _contaDestino!.saldoAtual >= 0 ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
