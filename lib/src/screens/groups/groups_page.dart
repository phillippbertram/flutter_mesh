import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        centerTitle: false,
      ),
      body: Center(
        child: EmptyView(
          image: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Image.network(
              "https://picsum.photos/seed/groups/100/100",
            ),
          ),
          title: const Text("Groups"),
          subtitle: const Text(
            "No groups found in the network.",
          ),
        ),
      ),
    );
  }
}
