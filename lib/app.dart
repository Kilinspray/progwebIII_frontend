import 'package:flutter/material.dart';

import 'core/theme.dart';
// Auth
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
// System
import 'features/system/screens/main_menu_screen.dart';
// Users
import 'features/users/screens/users_list_screen.dart';
// Accounts
import 'features/accounts/screens/accounts_list_screen.dart';
import 'features/accounts/screens/account_create_screen.dart';
import 'features/accounts/screens/account_edit_screen.dart';
import 'features/accounts/screens/account_detail_screen.dart';
// Categories
import 'features/categories/screens/categories_list_screen.dart';
import 'features/categories/screens/category_create_screen.dart';
import 'features/categories/screens/category_edit_screen.dart';
// Transactions
import 'features/transactions/screens/transactions_list_screen.dart';
import 'features/transactions/screens/transaction_create_screen.dart';
import 'features/transactions/screens/transaction_edit_screen.dart';
import 'features/transactions/screens/transaction_detail_screen.dart';
// Transfers
import 'features/transfers/screens/transfers_list_screen.dart';
import 'features/transfers/screens/transfer_create_screen.dart';
import 'features/transfers/screens/transfer_detail_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanças - App',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/': (c) => const MainMenuScreen(),
        '/menu': (c) => const MainMenuScreen(),
        '/login': (c) => const LoginScreen(),
        '/signup': (c) => const SignupScreen(),
        // Users
        '/users': (c) => const UsersListScreen(),
        // Accounts
        '/accounts': (c) => const AccountsListScreen(),
        '/accounts/create': (c) => const AccountCreateScreen(),
        // Categories
        '/categories': (c) => const CategoriesListScreen(),
        '/categories/create': (c) => const CategoryCreateScreen(),
        // Transactions
        '/transactions': (c) => const TransactionsListScreen(),
        '/transactions/create': (c) => const TransactionCreateScreen(),
        // Transfers
        '/transfers': (c) => const TransfersListScreen(),
        '/transfers/create': (c) => const TransferCreateScreen(),
      },
      onGenerateRoute: (settings) {
        // Account routes with arguments
        if (settings.name == '/accounts/edit') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => AccountEditScreen(accountId: id));
        }
        if (settings.name == '/accounts/detail') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => AccountDetailScreen(accountId: id));
        }
        // Category routes with arguments
        if (settings.name == '/categories/edit') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => CategoryEditScreen(categoryId: id));
        }
        // Transaction routes with arguments
        if (settings.name == '/transactions/edit') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => TransactionEditScreen(transactionId: id));
        }
        if (settings.name == '/transactions/detail') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => TransactionDetailScreen(transactionId: id));
        }
        // Transfer routes with arguments
        if (settings.name == '/transfers/detail') {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => TransferDetailScreen(transferId: id));
        }
        return null;
      },
    );
  }
}
