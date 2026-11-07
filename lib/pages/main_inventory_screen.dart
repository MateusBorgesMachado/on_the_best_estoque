import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_product.dart';
import 'package:on_the_best_estoque/models/product.dart';
import 'package:on_the_best_estoque/pages/add_product_screen.dart';
import 'package:on_the_best_estoque/widgets/product_list_item.dart';

class MainInventoryScreen extends StatefulWidget {
  const MainInventoryScreen({super.key});

  @override
  State<MainInventoryScreen> createState() => _MainInventoryScreenState();
}

class _MainInventoryScreenState extends State<MainInventoryScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ControllerProduct.getProducts();
  }

  Future<void> _reload() async {
    setState(() {
      _productsFuture = ControllerProduct.getProducts();
    });
    await _productsFuture;
  }

  Future<void> _openAddProduct() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
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
          'Estoque',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFCC00),
        onRefresh: _reload,
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
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
                      'Não foi possível carregar o estoque.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              );
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto cadastrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: products.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF2A2A2A),
                thickness: 1,
                height: 16,
              ),
              itemBuilder: (context, index) {
                return ProductListItem(product: products[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFCC00),
        heroTag: 'add_product',
        onPressed: _openAddProduct,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Adicionar Produto',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
