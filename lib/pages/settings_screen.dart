import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/pages/groups_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuração',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.category_outlined,
                color: Color(0xFFFFCC00),
              ),
            ),
            title: const Text(
              'Grupos e Subgrupos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Cadastre as categorias usadas nos produtos',
              style: TextStyle(color: Colors.grey[500]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
