import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../users/repository.dart';
import '../../../users/model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _name = TextEditingController();
  bool loading = false;
  String? _errorMessage;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      _errorMessage = null;
    });
    final api = ApiClient();
    final usersRepo = UsersRepository(api);
    try {
      final payload = UserCreate(
        email: _email.text.trim(),
        password: _password.text,
        nome: _name.text.isEmpty ? null : _name.text.trim(),
        roleId: 2, // 1 = admin, 2 = user
      );
      await usersRepo.create(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro realizado! Faça login agora.')));
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Falha no cadastro. Email pode já estar registrado.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width > 600 ? (size.width - 400) / 2 : 24,
            vertical: 16,
          ),
          child: Card(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Criar Conta', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.blue[300], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Cadastre-se para começar', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blue[200])),
                    const SizedBox(height: 32),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade900.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade700)),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                            ],
                          ),
                        ),
                      ),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person)),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Nome é obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: (v) => v?.isEmpty ?? true ? 'Email é obrigatório' : (!v!.contains('@') ? 'Email inválido' : null),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock)),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Senha é obrigatória' : (v!.length < 8 ? 'Mínimo 8 caracteres' : null),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordConfirm,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirme a senha', prefixIcon: Icon(Icons.lock)),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Confirmação obrigatória' : (v != _password.text ? 'Senhas não conferem' : null),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: loading ? null : _signup,
                        child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Text('Cadastrar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Já tem uma conta? ', style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                          child: const Text('Entrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
