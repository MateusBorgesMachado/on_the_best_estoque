import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_group.dart';
import 'package:on_the_best_estoque/models/product_group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  bool _loading = true;
  String? _error;
  List<ProductGroup> _groups = [];
  List<ProductSubgroup> _subgroups = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
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
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<ProductSubgroup> _subgroupsOf(String groupId) {
    return _subgroups.where((item) => item.groupId == groupId).toList();
  }

  Future<void> _showNameDialog({
    required String title,
    required String label,
    required Future<void> Function(String name) onSave,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NamePromptDialog(title: title, label: label),
    );
    if (!mounted || name == null || name.isEmpty) return;

    try {
      await onSave(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro salvo com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _reload();
    } catch (error) {
      if (!mounted) return;
      final message = error is PostgrestException && error.code == '23505'
          ? 'Já existe um cadastro com esse nome.'
          : 'Erro ao salvar: $error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addGroup() {
    return _showNameDialog(
      title: 'Novo grupo',
      label: 'Nome do grupo',
      onSave: (name) => ControllerProductGroup.insertGroup(
        ProductGroup(name: name),
      ),
    );
  }

  Future<void> _addSubgroup(ProductGroup group) {
    return _showNameDialog(
      title: 'Novo subgrupo',
      label: 'Nome do subgrupo em ${group.name}',
      onSave: (name) => ControllerProductSubgroup.insertSubgroup(
        ProductSubgroup(name: name, groupId: group.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grupos e Subgrupos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFCC00),
        onRefresh: _reload,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.cloud_off, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Não foi possível carregar os grupos.\n$_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  )
                : _groups.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum grupo cadastrado',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cadastre um grupo antes de criar produtos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _groups.length,
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          final subgroups = _subgroupsOf(group.id);
                          return ExpansionTile(
                            collapsedIconColor: Colors.grey[500],
                            iconColor: const Color(0xFFFFCC00),
                            leading: const Icon(
                              Icons.category_outlined,
                              color: Color(0xFFFFCC00),
                            ),
                            title: Text(
                              group.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${subgroups.length} subgrupo(s)',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            children: [
                              ...subgroups.map(
                                (subgroup) => ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 72,
                                    right: 16,
                                  ),
                                  leading: Icon(
                                    Icons.subdirectory_arrow_right,
                                    color: Colors.grey[500],
                                  ),
                                  title: Text(
                                    subgroup.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 72,
                                  right: 16,
                                ),
                                leading: const Icon(
                                  Icons.add,
                                  color: Color(0xFFFFCC00),
                                ),
                                title: const Text(
                                  'Adicionar subgrupo',
                                  style: TextStyle(color: Color(0xFFFFCC00)),
                                ),
                                onTap: () => _addSubgroup(group),
                              ),
                            ],
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_group',
        backgroundColor: const Color(0xFFFFCC00),
        foregroundColor: Colors.black,
        onPressed: _addGroup,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Grupo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _NamePromptDialog extends StatefulWidget {
  const _NamePromptDialog({required this.title, required this.label});

  final String title;
  final String label;

  @override
  State<_NamePromptDialog> createState() => _NamePromptDialogState();
}

class _NamePromptDialogState extends State<_NamePromptDialog> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Salvar',
            style: TextStyle(color: Color(0xFFFFCC00)),
          ),
        ),
      ],
    );
  }
}
