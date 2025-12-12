import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';

class AccountCreateScreen extends StatefulWidget {
  const AccountCreateScreen({super.key});

  @override
  State<AccountCreateScreen> createState() => _AccountCreateScreenState();
}

class _AccountCreateScreenState extends State<AccountCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _saldoInicial = TextEditingController(text: '0');
  final _limiteCredito = TextEditingController(text: '0');
  AccountType _tipo = AccountType.carteira;
  bool loading = false;
  String? _errorMessage;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      _errorMessage = null;
    });
    final api = ApiClient();
    final repo = AccountsRepository(api);
    try {
      final payload = AccountCreate(
        nome: _nome.text.trim(),
        tipo: _tipo,
        saldoInicial: double.tryParse(_saldoInicial.text) ?? 0,
        limiteCredito: _tipo == AccountType.banco ? double.tryParse(_limiteCredito.text) : null,
      );
      await repo.create(payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao criar conta');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Conta')),
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
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome da conta', prefixIcon: Icon(Icons.account_balance_wallet)),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AccountType>(
                    value: _tipo,
                    decoration: const InputDecoration(labelText: 'Tipo', prefixIcon: Icon(Icons.category)),
                    items: AccountType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.apiValue))).toList(),
                    onChanged: (v) => setState(() => _tipo = v ?? AccountType.carteira),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _saldoInicial,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Saldo inicial', prefixIcon: Icon(Icons.attach_money)),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Valor inválido' : null,
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
                      onPressed: loading ? null : _save,
                      child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
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
