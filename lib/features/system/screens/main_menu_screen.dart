import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../accounts/repository.dart';
import '../../../accounts/model.dart';
import '../../../transactions/repository.dart';
import '../../../transactions/model.dart';
import '../../../transfers/repository.dart';
import '../../../transfers/model.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  List<Transfer> _transfers = [];

  double _saldoTotal = 0;
  double _receitaTotal = 0;
  double _despesaTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = ApiClient();
    try {
      _accounts = await AccountsRepository(api).listAll();
      _transactions = await TransactionsRepository(api).listAll();
      _transfers = await TransfersRepository(api).listAll();

      _saldoTotal = _accounts.fold(0.0, (sum, a) => sum + a.saldoAtual);
      _receitaTotal = _transactions
          .where((t) => t.tipo.apiValue == 'Receita')
          .fold(0.0, (sum, t) => sum + t.valor);
      _despesaTotal = _transactions
          .where((t) => t.tipo.apiValue == 'Despesa')
          .fold(0.0, (sum, t) => sum + t.valor);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _logout() {
    ApiClient().clearToken();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildDashboardContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: const Color(0xFF0a0e1a),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'WebIII Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white38,
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFF151929),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
          _buildMenuItem(1, Icons.account_balance_wallet, 'Contas'),
          _buildMenuItem(2, Icons.category, 'Categorias'),
          _buildMenuItem(3, Icons.receipt_long, 'Transacoes'),
          _buildMenuItem(4, Icons.swap_horiz, 'Transferencias'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade300, size: 20),
                    const SizedBox(width: 12),
                    Text('Sair', style: TextStyle(color: Colors.red.shade300)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
          } else if (index == 1) {
            Navigator.pushNamed(context, '/accounts');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/categories');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/transactions');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/transfers');
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.shade700.withAlpha(75)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.blue.shade700.withAlpha(125))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue.shade300 : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0f1320),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(12))),
      ),
      child: Row(
        children: [
          const Text(
            'Visao Geral do Sistema',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white54),
            tooltip: 'Atualizar dados',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white54,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'U',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Container(
      color: const Color(0xFF0f1320),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildChartCard()),
                const SizedBox(width: 24),
                Expanded(child: _buildActivityCard()),
              ],
            ),
            const SizedBox(height: 24),
            _buildTransactionsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Saldo Total',
            'R\$ ${_formatNumber(_saldoTotal)}',
            _saldoTotal >= 0 ? 'Positivo' : 'Negativo',
            _saldoTotal >= 0 ? Colors.green : Colors.red,
            Icons.attach_money,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Receitas',
            'R\$ ${_formatNumber(_receitaTotal)}',
            '+${_transactions.where((t) => t.tipo.apiValue == 'Receita').length} registros',
            Colors.green,
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Despesas',
            'R\$ ${_formatNumber(_despesaTotal)}',
            '${_transactions.where((t) => t.tipo.apiValue == 'Despesa').length} registros',
            Colors.red,
            Icons.trending_down,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Contas Ativas',
            '${_accounts.length}',
            'Sem mudanca',
            Colors.white54,
            Icons.account_balance_wallet,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color subtitleColor,
    IconData icon,
    Color iconBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconBgColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (subtitleColor == Colors.green)
                const Icon(Icons.arrow_upward, color: Colors.green, size: 14),
              if (subtitleColor == Colors.red)
                const Icon(Icons.arrow_downward, color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desempenho (Ultimos 6 meses)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                child: const Text(
                  'Ver Detalhes',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1a2035),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.blue.shade300),
                  const SizedBox(height: 12),
                  Text(
                    '[Visualizacao de Grafico Aqui]',
                    style: TextStyle(color: Colors.blue.shade300),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Receitas: R\$ ${_formatNumber(_receitaTotal)} | Despesas: R\$ ${_formatNumber(_despesaTotal)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atividade Recente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ..._buildRecentActivities(),
        ],
      ),
    );
  }

  List<Widget> _buildRecentActivities() {
    final activities = <Widget>[];

    for (var i = 0; i < _transactions.length.clamp(0, 3); i++) {
      final t = _transactions[i];
      activities.add(
        _buildActivityItem(
          t.tipo.apiValue == 'Receita'
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          t.tipo.apiValue == 'Receita' ? Colors.green : Colors.red,
          '${t.tipo.apiValue} #${t.id}',
          t.descricao ?? 'R\$ ${t.valor.toStringAsFixed(2)}',
        ),
      );
    }

    for (var i = 0; i < _transfers.length.clamp(0, 2); i++) {
      final t = _transfers[i];
      activities.add(
        _buildActivityItem(
          Icons.swap_horiz,
          Colors.blue,
          'Transferencia #${t.id}',
          'R\$ ${t.valor.toStringAsFixed(2)}',
        ),
      );
    }

    if (activities.isEmpty) {
      activities.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Nenhuma atividade recente',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ),
      );
    }

    return activities;
  }

  Widget _buildActivityItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ultimas Transacoes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/transactions/create'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nova Transacao'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a2035),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'ID',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Descricao',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Data',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Valor',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (_transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Colors.white.withAlpha(60),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhuma transacao encontrada',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(
              _transactions.length.clamp(0, 5),
              (index) => _buildTransactionRow(_transactions[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Transaction t) {
    final isReceita = t.tipo.apiValue == 'Receita';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(12))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '#TR-${t.id}',
              style: const TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              t.descricao ?? 'Sem descricao',
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${t.data.day} ${_getMonthName(t.data.month)}, ${t.data.year}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'R\$ ${t.valor.toStringAsFixed(2)}',
              style: TextStyle(
                color: isReceita ? Colors.green : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isReceita
                    ? Colors.green.withAlpha(50)
                    : Colors.orange.withAlpha(50),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isReceita
                      ? Colors.green.withAlpha(125)
                      : Colors.orange.withAlpha(125),
                ),
              ),
              child: Text(
                isReceita ? 'Receita' : 'Despesa',
                style: TextStyle(
                  color: isReceita ? Colors.green : Colors.orange,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k'.replaceAll('.', ',');
    }
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }
}
