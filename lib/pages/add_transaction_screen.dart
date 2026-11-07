import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_customer.dart';
import 'package:on_the_best_estoque/data/controller_group.dart';
import 'package:on_the_best_estoque/data/controller_product.dart';
import 'package:on_the_best_estoque/data/controller_representative.dart';
import 'package:on_the_best_estoque/data/controller_transaction.dart';
import 'package:on_the_best_estoque/models/app_transaction.dart';
import 'package:on_the_best_estoque/models/customer.dart';
import 'package:on_the_best_estoque/models/product.dart';
import 'package:on_the_best_estoque/models/product_group.dart';
import 'package:on_the_best_estoque/models/representative.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isSale = true;
  bool _loadingData = true;
  bool _saving = false;
  String? _loadError;

  final _totalController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String? _selectedEntity;
  String? _selectedGroup;
  String? _selectedSubgroup;
  String? _selectedProduct;

  List<Customer> _customers = [];
  List<Representative> _representatives = [];
  List<Product> _products = [];
  List<ProductGroup> _catalogGroups = [];
  List<ProductSubgroup> _catalogSubgroups = [];
  final List<Map<String, dynamic>> _addedItems = [];

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _totalController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _loadingData = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        ControllerCustomer.getCustomers(),
        ControllerRepresentative.getRepresentatives(),
        ControllerProduct.getProducts(),
        ControllerProductGroup.getGroups(),
        ControllerProductSubgroup.getSubgroups(),
      ]);
      if (!mounted) return;
      setState(() {
        _customers = results[0] as List<Customer>;
        _representatives = results[1] as List<Representative>;
        _products = results[2] as List<Product>;
        _catalogGroups = results[3] as List<ProductGroup>;
        _catalogSubgroups = results[4] as List<ProductSubgroup>;
        _loadingData = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loadingData = false;
      });
    }
  }

  List<String> get _entityItems {
    if (_isSale) {
      return _customers.map((customer) => customer.name).toList();
    }
    return _representatives.map((rep) => rep.storeName).toList();
  }

  List<String> get _groups {
    return _catalogGroups.map((group) => group.name).toList();
  }

  List<String> get _subgroups {
    ProductGroup? selectedGroup;
    for (final group in _catalogGroups) {
      if (group.name == _selectedGroup) {
        selectedGroup = group;
        break;
      }
    }
    if (selectedGroup == null) return [];
    return _catalogSubgroups
        .where((item) => item.groupId == selectedGroup!.id)
        .map((item) => item.name)
        .toList();
  }

  List<Product> get _filteredProducts {
    return _products.where((product) {
      final matchesGroup =
          _selectedGroup == null || product.category == _selectedGroup;
      final matchesSubgroup = _selectedSubgroup == null ||
          product.subcategory == _selectedSubgroup;
      return matchesGroup && matchesSubgroup;
    }).toList();
  }

  void _addItem() {
    if (_selectedProduct == null) return;
    final product = _products.firstWhere(
      (item) => item.name == _selectedProduct,
      orElse: () => _filteredProducts.first,
    );
    setState(() {
      _addedItems.add({
        'name': product.name,
        'group': '${product.category} > ${product.subcategory}',
        'quantity': _quantityController.text,
        'price': product.finalPrice.toStringAsFixed(2).replaceAll('.', ','),
        'value': product.finalPrice,
      });
      _selectedProduct = null;
      _quantityController.text = '1';
      _updateTotalFromItems();
    });
  }

  void _updateTotalFromItems() {
    var total = 0.0;
    for (final item in _addedItems) {
      final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
      final value = (item['value'] as num?)?.toDouble() ?? 0;
      total += value * quantity;
    }
    if (total > 0) {
      _totalController.text = total.toStringAsFixed(2);
    }
  }

  Future<void> _saveTransaction() async {
    if (_selectedEntity == null || _selectedEntity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o cliente ou fornecedor'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final total = double.tryParse(
          _totalController.text.trim().replaceAll(',', '.'),
        ) ??
        0;
    final itemCount = _addedItems.fold<int>(0, (sum, item) {
      return sum + (int.tryParse(item['quantity'].toString()) ?? 1);
    });

    setState(() => _saving = true);
    try {
      await ControllerTransaction.insertTransaction(
        AppTransaction(
          type: _isSale ? 'Venda' : 'Compra',
          entityName: _selectedEntity!,
          date: DateTime.now().toIso8601String().split('T').first,
          totalValue: total,
          itemCount: itemCount == 0 ? 1 : itemCount,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_isSale ? 'Venda' : 'Compra'} salva com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar transação: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isSale
        ? Colors.greenAccent[400]!
        : Colors.redAccent[400]!;
    final entityLabel = _isSale ? 'Cliente' : 'Fornecedor';
    final entityIcon = _isSale
        ? Icons.person_outline
        : Icons.storefront_outlined;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Transação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Não foi possível carregar os dados.\n$_loadError',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadFormData,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Row(
                          children: [
                            _buildToggleButton(
                              title: 'Venda',
                              isActive: _isSale,
                              activeColor: Colors.greenAccent[400]!,
                              onTap: () => setState(() {
                                _isSale = true;
                                _selectedEntity = null;
                              }),
                            ),
                            _buildToggleButton(
                              title: 'Compra',
                              isActive: !_isSale,
                              activeColor: Colors.redAccent[400]!,
                              onTap: () => setState(() {
                                _isSale = false;
                                _selectedEntity = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Dados Principais',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Selecionar $entityLabel',
                        icon: entityIcon,
                        value: _selectedEntity,
                        items: _entityItems,
                        onChanged: (val) =>
                            setState(() => _selectedEntity = val),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _totalController,
                        label: 'Valor Total',
                        icon: Icons.attach_money,
                        isNumeric: true,
                        prefixText: 'R\$ ',
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF2A2A2A), thickness: 1),
                      const SizedBox(height: 16),
                      const Text(
                        'Adicionar Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Grupo',
                              icon: Icons.category_outlined,
                              value: _selectedGroup,
                              items: _groups,
                              onChanged: (val) => setState(() {
                                _selectedGroup = val;
                                _selectedSubgroup = null;
                                _selectedProduct = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Subgrupo',
                              icon: Icons.subdirectory_arrow_right,
                              value: _selectedSubgroup,
                              items: _subgroups,
                              onChanged: (val) => setState(() {
                                _selectedSubgroup = val;
                                _selectedProduct = null;
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Produto',
                        icon: Icons.shopping_bag_outlined,
                        value: _selectedProduct,
                        items: _filteredProducts
                            .map((product) => product.name)
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedProduct = val),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _quantityController,
                              label: 'Qtd',
                              icon: Icons.numbers,
                              isNumeric: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: _addItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E1E1E),
                                foregroundColor: activeColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: activeColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 20),
                              label: const Text(
                                'Adicionar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_addedItems.isNotEmpty) ...[
                        const Text(
                          'Itens na Transação',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _addedItems.length,
                          itemBuilder: (context, index) {
                            final item = _addedItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFF2A2A2A)),
                              ),
                              child: ListTile(
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  item['group'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'R\$ ${item['price']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Qtd: ${item['quantity']}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            backgroundColor: activeColor,
            foregroundColor: Colors.black,
            onPressed: _saving ? null : _saveTransaction,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(
              'Salvar ${_isSale ? 'Venda' : 'Compra'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final safeValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      dropdownColor: const Color(0xFF2A2A2A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumeric = false,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.white, fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
        ),
      ),
    );
  }
}
