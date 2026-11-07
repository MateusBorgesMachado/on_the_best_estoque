import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_representative.dart';
import 'package:on_the_best_estoque/models/representative.dart';

class AddRepresentativeScreen extends StatefulWidget {
  const AddRepresentativeScreen({super.key});

  @override
  State<AddRepresentativeScreen> createState() =>
      _AddRepresentativeScreenState();
}

class _AddRepresentativeScreenState extends State<AddRepresentativeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _repNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    _repNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveRepresentative() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ControllerRepresentative.insertRepresentative(
        Representative(
          storeName: _storeNameController.text.trim(),
          repName: _repNameController.text.trim(),
          contactNumber: _contactController.text.trim(),
          address: _addressController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Representante salvo com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar representante: $error'),
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
          'Novo Representante',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _storeNameController,
                label: 'Nome da Loja ou Distribuidora',
                icon: Icons.storefront_outlined,
                validatorMsg: 'Informe o nome da loja',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _repNameController,
                label: 'Nome do Representante',
                icon: Icons.badge_outlined,
                validatorMsg: 'Informe o nome do representante',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _contactController,
                label: 'Telefone / WhatsApp',
                icon: Icons.phone_outlined,
                isPhone: true,
                validatorMsg: 'Informe um número de contato',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _addressController,
                label: 'Endereço Completo',
                icon: Icons.location_on_outlined,
                validatorMsg: 'Informe o endereço',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                validatorMsg: 'Informe um e-mail válido',
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveRepresentative,
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
                  'Salvar Representante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),

        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? (maxLines * 12.0) : 0,
          ),
          child: Icon(icon, color: Colors.grey[400]),
        ),

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
        if (value == null || value.trim().isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }
}
