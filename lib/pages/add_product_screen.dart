import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_group.dart';
import 'package:on_the_best_estoque/data/controller_product.dart';
import 'package:on_the_best_estoque/models/product.dart';
import 'package:on_the_best_estoque/models/product_group.dart';
import 'package:on_the_best_estoque/pages/groups_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _finalPriceController = TextEditingController();
  final _stockController = TextEditingController();

  bool _loadingGroups = true;
  String? _loadError;
  List<ProductGroup> _groups = [];
  List<ProductSubgroup> _subgroups = [];
  String? _selectedGroupId;
  String? _selectedSubgroupId;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _finalPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loadingGroups = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        ControllerProductGroup.getGroups(),
        ControllerProductSubgroup.getSubgroups(),
      ]);
      if (!mounted) return;
      setState(() {
        _groups = results[0] as List<ProductGroup>;
        _subgroups = results[1] as List<ProductSubgroup>;
        if (_selectedGroupId != null &&
            !_groups.any((group) => group.id == _selectedGroupId)) {
          _selectedGroupId = null;
          _selectedSubgroupId = null;
        }
        _loadingGroups = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loadingGroups = false;
      });
    }
  }

  List<ProductSubgroup> get _filteredSubgroups {
    if (_selectedGroupId == null) return [];
    return _subgroups
        .where((item) => item.groupId == _selectedGroupId)
        .toList();
  }

  Future<void> _openGroupsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsScreen()),
    );
    await _loadGroups();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final group = _groups.firstWhere((item) => item.id == _selectedGroupId);
    final subgroup = _filteredSubgroups.firstWhere(
      (item) => item.id == _selectedSubgroupId,
    );

    try {
      await ControllerProduct.insertProduct(
        Product(
          name: _nameController.text.trim(),
          category: group.name,
          subcategory: subgroup.name,
          costPrice: double.parse(_costPriceController.text.trim()),
          finalPrice: double.parse(_finalPriceController.text.trim()),
          lastPurchaseDate: DateTime.now().toIso8601String().split('T').first,
          stockQuantity: int.parse(_stockController.text.trim()),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto salvo com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar produto: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Produto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loadingGroups
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Não foi possível carregar os grupos.\n$_loadError',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGroups,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nome do Produto',
                          icon: Icons.shopping_bag_outlined,
                          validatorMsg: 'Informe o nome do produto',
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Grupo',
                          icon: Icons.category_outlined,
                          value: _selectedGroupId,
                          items: {
                            for (final group in _groups) group.id: group.name,
                          },
                          validatorMsg: 'Selecione o grupo',
                          onChanged: (val) {
                            setState(() {
                              _selectedGroupId = val;
                              _selectedSubgroupId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Subgrupo',
                          icon: Icons.subdirectory_arrow_right,
                          value: _selectedSubgroupId,
                          items: {
                            for (final subgroup in _filteredSubgroups)
                              subgroup.id: subgroup.name,
                          },
                          validatorMsg: _selectedGroupId == null
                              ? 'Selecione o grupo primeiro'
                              : 'Selecione o subgrupo',
                          onChanged: (val) {
                            setState(() => _selectedSubgroupId = val);
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _openGroupsScreen,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Cadastrar grupo ou subgrupo'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _costPriceController,
                                label: 'Custo',
                                icon: Icons.attach_money,
                                isNumeric: true,
                                prefixText: 'R\$ ',
                                validatorMsg: 'Informe o custo',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _finalPriceController,
                                label: 'Venda',
                                icon: Icons.sell_outlined,
                                isNumeric: true,
                                prefixText: 'R\$ ',
                                validatorMsg: 'Informe o valor',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _stockController,
                          label: 'Estoque Inicial',
                          icon: Icons.inventory_2_outlined,
                          isNumeric: true,
                          suffixText: 'unid',
                          validatorMsg: 'Informe a quantidade',
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Salvar Produto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required Map<String, String> items,
    required String validatorMsg,
    required void Function(String?) onChanged,
  }) {
    final safeValue = items.containsKey(value) ? value : null;
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-${items.keys.join()}-$safeValue'),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null || selected.isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    bool isNumeric = false,
    String? prefixText,
    String? suffixText,
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
        suffixText: suffixText,
        suffixStyle: TextStyle(color: Colors.grey[400]),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }
}
