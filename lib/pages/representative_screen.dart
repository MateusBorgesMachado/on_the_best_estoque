import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/data/controller_representative.dart';
import 'package:on_the_best_estoque/models/representative.dart';
import 'package:on_the_best_estoque/pages/add_representative_screen.dart';
import 'package:on_the_best_estoque/widgets/representative_list_item.dart';

class RepresentativesScreen extends StatefulWidget {
  const RepresentativesScreen({super.key});

  @override
  State<RepresentativesScreen> createState() => _RepresentativesScreenState();
}

class _RepresentativesScreenState extends State<RepresentativesScreen> {
  late Future<List<Representative>> _representativesFuture;

  @override
  void initState() {
    super.initState();
    _representativesFuture = ControllerRepresentative.getRepresentatives();
  }

  Future<void> _reload() async {
    setState(() {
      _representativesFuture = ControllerRepresentative.getRepresentatives();
    });
    await _representativesFuture;
  }

  Future<void> _openAddRepresentative() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddRepresentativeScreen()),
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
          'Representantes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFCC00),
        onRefresh: _reload,
        child: FutureBuilder<List<Representative>>(
          future: _representativesFuture,
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
                      'Não foi possível carregar os representantes.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              );
            }

            final representatives = snapshot.data ?? [];
            if (representatives.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.badge_outlined, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum representante cadastrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: representatives.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF2A2A2A),
                thickness: 1,
                height: 16,
              ),
              itemBuilder: (context, index) {
                return RepresentativeListItem(
                  representative: representatives[index],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_representative',
        onPressed: _openAddRepresentative,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Representante',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
