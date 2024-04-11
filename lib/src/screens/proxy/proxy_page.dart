import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class ProxyPage extends StatelessWidget {
  const ProxyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy'),
      ),
      body: SectionedListView(
        children: [
          Section.children(
            children: [
              // TODO:
              const ListTile(
                title: Text('Automatic Connection'),
                trailing: Switch(value: false, onChanged: null),
              ),
              const ListTile(
                title: Text('Proxy'),
                trailing: Text('TBD'),
              ),
              ListTile(
                trailing: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          context.theme.appColors.error.defaultColor,
                    ),
                    onPressed: null,
                    child: const Text("Disconnect")),
              )
            ],
          ),
          Section.children(
            header: const Text("Proxy Filter"),
            children: const [],
          )
        ],
      ),
    );
  }
}
