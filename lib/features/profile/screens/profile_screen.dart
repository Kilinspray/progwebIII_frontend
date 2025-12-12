import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api_client.dart';
import '../../../users/repository.dart';
import '../../../users/model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  
  User? _currentUser;
  CurrencyType? _selectedCurrency;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;
  String? _newImageBase64; // Armazena a nova imagem selecionada

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    final api = ApiClient();
    final usersRepo = UsersRepository(api);
    
    try {
      final user = await usersRepo.getCurrentUser();
      setState(() {
        _currentUser = user;
        _nome.text = user.nome ?? '';
        _selectedCurrency = user.moeda;
        _newImageBase64 = null; // Limpa imagem temporária ao recarregar
      });
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao carregar perfil: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        setState(() {
          _newImageBase64 = 'data:image/jpeg;base64,$base64Image';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    
    final api = ApiClient();
    final usersRepo = UsersRepository(api);
    
    try {
      final update = UserUpdate(
        nome: _nome.text.trim().isEmpty ? null : _nome.text.trim(),
        moeda: _selectedCurrency,
        profileImageBase64: _newImageBase64,
      );
      
      await usersRepo.updateMyProfile(update);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      await _loadProfile();
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao atualizar perfil: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _buildAvatar() {
    // Prioriza a nova imagem selecionada, senão usa a do usuário atual
    final imageBase64 = _newImageBase64 ?? _currentUser?.profileImageBase64;
    
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        // Remove o prefixo data:image/...;base64, se existir
        final base64String = imageBase64.contains(',')
            ? imageBase64.split(',')[1]
            : imageBase64;
        
        final Uint8List bytes = base64Decode(base64String);
        
        return CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Se falhar ao decodificar, mostra ícone padrão
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.grey[600],
          ),
        );
      }
    }
    
    // Sem imagem: mostra ícone padrão
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          if (_saving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          _buildAvatar(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Selecionar Foto'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Informações básicas (não editáveis)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações da Conta',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'ID',
                              value: _currentUser?.id.toString() ?? '-',
                            ),
                            _InfoRow(
                              label: 'Email',
                              value: _currentUser?.email ?? '-',
                            ),
                            _InfoRow(
                              label: 'Perfil',
                              value: _currentUser?.role.name ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campos editáveis
                    Text(
                      'Editar Perfil',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty && v.trim().length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<CurrencyType>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Moeda',
                        border: OutlineInputBorder(),
                      ),
                      items: CurrencyType.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.apiValue),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCurrency = v),
                    ),
                    const SizedBox(height: 24),

                    // Mensagem de erro
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),

                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _loadProfile,
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _updateProfile,
                            child: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
