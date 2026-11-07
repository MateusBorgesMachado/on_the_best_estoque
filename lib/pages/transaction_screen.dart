import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_transaction.dart';
import 'package:on_the_best_estoque/models/app_transaction.dart';
import 'package:on_the_best_estoque/pages/add_transaction_screen.dart';
import 'package:on_the_best_estoque/widgets/transaction_list_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<AppTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = ControllerTransaction.getTransactions();
  }

  Future<void> _reload() async {
    setState(() {
      _transactionsFuture = ControllerTransaction.getTransactions();
    });
    await _transactionsFuture;
  }

  Future<void> _openAddTransaction() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
    if (saved == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendas & Compras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFCC00),
        onRefresh: _reload,
        child: FutureBuilder<List<AppTransaction>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.cloud_off, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Não foi possível carregar as transações.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              );
            }

            final transactions = snapshot.data ?? [];
            if (transactions.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação cadastrada',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF2A2A2A),
                thickness: 1,
                height: 16,
              ),
              itemBuilder: (context, index) {
                return TransactionListItem(transaction: transactions[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_transaction',
        backgroundColor: const Color(0xFF5E42A6),
        foregroundColor: Colors.white,
        onPressed: _openAddTransaction,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text(
          'Nova Transação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
