import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/empty_view.dart';

class LocalNodePage extends StatelessWidget {
  const LocalNodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Node'),
      ),
      body: _buildEmptyView(),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: EmptyView(
        image: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Image.network(
            "https://picsum.photos/seed/pilot/100/100",
          ),
        ),
        title: const Text("Local Node"),
        subtitle: const Text(
          "No local node found in the network.",
        ),
      ),
    );
  }
}
