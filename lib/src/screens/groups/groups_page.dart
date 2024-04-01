import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('Groups Page'),
      ),
    );
  }
}
