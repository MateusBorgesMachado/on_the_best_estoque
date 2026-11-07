import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_customer.dart';
import 'package:on_the_best_estoque/models/customer.dart';
import 'package:on_the_best_estoque/pages/add_customer_screen.dart';
import 'package:on_the_best_estoque/widgets/customer_list_item.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  late Future<List<Customer>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _customersFuture = ControllerCustomer.getCustomers();
  }

  Future<void> _reload() async {
    setState(() {
      _customersFuture = ControllerCustomer.getCustomers();
    });
    await _customersFuture;
  }

  Future<void> _openAddCustomer() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
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
          'Clientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFCC00),
        onRefresh: _reload,
        child: FutureBuilder<List<Customer>>(
          future: _customersFuture,
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
                      'Não foi possível carregar os clientes.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              );
            }

            final customers = snapshot.data ?? [];
            if (customers.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum cliente cadastrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: customers.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF2A2A2A),
                thickness: 1,
                height: 16,
              ),
              itemBuilder: (context, index) {
                return CustomerListItem(customer: customers[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_customer',
        onPressed: _openAddCustomer,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Novo Cliente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
