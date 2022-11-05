import 'package:flutter/material.dart';
import 'package:reddit/features/community/screen/add_mod_screen.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});
  void navigateToEditCommunity(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$name');
  }

  void navigateToAddModCommunity(BuildContext context) {
    Routemaster.of(context).push('/add-mod/$name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text("Add Modarator"),
            onTap: () => navigateToAddModCommunity(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Community"),
            onTap: () => navigateToEditCommunity(context),
          ),
        ],
      ),
    );
  }
}
