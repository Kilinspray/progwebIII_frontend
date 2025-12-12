import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../transfers/repository.dart';
import '../../../transfers/model.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class TransferCreateScreen extends StatefulWidget {
  const TransferCreateScreen({super.key});

  @override
  State<TransferCreateScreen> createState() => _TransferCreateScreenState();
}

class _TransferCreateScreenState extends State<TransferCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valor = TextEditingController();
  int? _contaOrigemId;
  int? _contaDestinoId;
  DateTime _data = DateTime.now();

  List<Account> _accounts = [];
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
      _accounts = await AccountsRepository(api).listAll();
    } catch (_) {}
    if (mounted) setState(() => loadingData = false);
  }

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

    if (_contaOrigemId == null || _contaDestinoId == null) {
      setState(() => _errorMessage = 'Selecione as contas de origem e destino');
      return;
    }

    if (_contaOrigemId == _contaDestinoId) {
      setState(
        () => _errorMessage = 'Conta de origem e destino devem ser diferentes',
      );
      return;
    }

    setState(() {
      saving = true;
      _errorMessage = null;
    });

    final api = ApiClient();
    final repo = TransfersRepository(api);
    try {
      final payload = TransferCreate(
        contaOrigemId: _contaOrigemId!,
        contaDestinoId: _contaDestinoId!,
        valor: double.parse(_valor.text),
        data: _data,
      );
      await repo.create(payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      String msg = 'Erro ao criar transferencia';
      String errorStr = e.toString().toLowerCase();

      // Tentar extrair mensagem do ApiException
      if (e is ApiException) {
        errorStr = e.body.toLowerCase();
      }

      if (errorStr.contains('saldo insuficiente') ||
          errorStr.contains('insufficient')) {
        msg = 'Saldo insuficiente na conta de origem';
      } else if (errorStr.contains('400') || errorStr.contains('bad request')) {
        msg = 'Saldo insuficiente para realizar esta transferencia';
      }
      _showErrorDialog(msg);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Ops!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            if (message.contains('Saldo insuficiente')) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withAlpha(75)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Verifique o saldo da conta de origem ou escolha um valor menor.',
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nova Transferência')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_accounts.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nova Transferência')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Você precisa ter pelo menos 2 contas para fazer uma transferência',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/accounts/create'),
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Transferência')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
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
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Valor
                  TextFormField(
                    controller: _valor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Valor é obrigatório';
                      if (double.tryParse(v) == null) return 'Valor inválido';
                      if (double.parse(v) <= 0) {
                        return 'Valor deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Conta Origem
                  DropdownButtonFormField<int>(
                    initialValue: _contaOrigemId,
                    decoration: const InputDecoration(
                      labelText: 'Conta de origem',
                      prefixIcon: Icon(Icons.logout, color: Colors.red),
                    ),
                    items: _accounts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(a.nome),
                                Text(
                                  'R\$ ${a.saldoAtual.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: a.saldoAtual >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _contaOrigemId = v),
                    validator: (v) =>
                        v == null ? 'Selecione a conta de origem' : null,
                  ),
                  const SizedBox(height: 16),

                  // Ícone de seta
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conta Destino
                  DropdownButtonFormField<int>(
                    initialValue: _contaDestinoId,
                    decoration: const InputDecoration(
                      labelText: 'Conta de destino',
                      prefixIcon: Icon(Icons.login, color: Colors.green),
                    ),
                    items: _accounts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(a.nome),
                                Text(
                                  'R\$ ${a.saldoAtual.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: a.saldoAtual >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _contaDestinoId = v),
                    validator: (v) =>
                        v == null ? 'Selecione a conta de destino' : null,
                  ),
                  const SizedBox(height: 24),

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
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Transferir'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}
