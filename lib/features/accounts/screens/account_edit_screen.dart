import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class AccountEditScreen extends StatefulWidget {
  final int accountId;
  const AccountEditScreen({super.key, required this.accountId});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _limiteCredito = TextEditingController();
  AccountType _tipo = AccountType.carteira;
  bool loading = true;
  bool saving = false;
  String? _errorMessage;
  Account? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final api = ApiClient();
    final repo = AccountsRepository(api);
    try {
      final acc = await repo.getById(widget.accountId);
      if (!mounted) return;
      setState(() {
        _account = acc;
        _nome.text = acc.nome;
        _tipo = acc.tipo;
        _limiteCredito.text = (acc.limiteCredito ?? 0).toString();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      saving = true;
      _errorMessage = null;
    });
    final api = ApiClient();
    final repo = AccountsRepository(api);
    try {
      final payload = AccountUpdate(
        nome: _nome.text.trim(),
        limiteCredito: _tipo == AccountType.banco ? double.tryParse(_limiteCredito.text) : null,
      );
      await repo.update(widget.accountId, payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao atualizar conta');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Conta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome da conta', prefixIcon: Icon(Icons.account_balance_wallet)),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Tipo', prefixIcon: Icon(Icons.category)),
                    child: Text(_tipo.apiValue, style: const TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Saldo atual', prefixIcon: Icon(Icons.attach_money)),
                    child: Text((_account?.saldoAtual ?? 0).toStringAsFixed(2), style: const TextStyle(color: Colors.white70)),
                  ),
                  if (_tipo == AccountType.banco) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _limiteCredito,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Limite de crédito', prefixIcon: Icon(Icons.credit_card)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving ? null : _save,
                      child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
