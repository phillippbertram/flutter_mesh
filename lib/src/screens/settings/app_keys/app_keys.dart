import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/mesh/mesh.dart';
import 'package:flutter_mesh/src/mesh_app/app_network_manager.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class AppKeysPage extends StatelessWidget {
  const AppKeysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Keys'),
        actions: [
          IconButton(
            onPressed: () {
              _showAppKey(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppNetworkManager.instance.meshNetworkManager.meshNetwork!,
        builder: (context, child) {
          return _body(context,
              AppNetworkManager.instance.meshNetworkManager.meshNetwork!);
        },
      ),
    );
  }

  Widget _body(BuildContext context, MeshNetwork network) {
    final keys = network.applicationKeys;
    if (keys.isEmpty) {
      return _emptyView(context);
    }

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return ListTile(
          title: Text(key.name),
          subtitle: Text("Bound to: ${key.boundNetworkKey?.name}"),
          trailing: const Icon(Icons.edit),
          onTap: () {
            _showAppKey(context, key: key);
          },
        );
      },
    );
  }

  Widget _emptyView(BuildContext context) {
    return Center(
      child: EmptyView(
        title: const Text("No Keys"),
        subtitle: const Text("Create a new key"),
        action: ElevatedButton(
          child: const Text("Generate"),
          onPressed: () {
            _showAppKey(context);
          },
        ),
      ),
    );
  }

  void _showAppKey(BuildContext context, {ApplicationKey? key}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const AppKeyDetailPage(),
      ),
    );
  }
}

class AppKeyDetailPage extends StatefulWidget {
  const AppKeyDetailPage({
    super.key,
    this.appKey,
  });

  final ApplicationKey? appKey;

  @override
  State<AppKeyDetailPage> createState() => _AppKeyDetailPageState();
}

class _AppKeyDetailPageState extends State<AppKeyDetailPage> {
  ApplicationKey? get _key => widget.appKey;

  late String _name;
  late Data _newKeyData;
  late KeyIndex _newKeyIndex;

  @override
  void initState() {
    _newKeyData = _key?.key ?? ApplicationKey.randomKeyData();
    _newKeyIndex = _key?.index ??
        AppNetworkManager.instance.meshNetworkManager.meshNetwork!
            .nextAvailableApplicationKeyIndex!;
    _name = _key?.name ?? "App Key $_newKeyIndex";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create App Key'),
        actions: [
          TextButton(
            onPressed: _onDone,
            child: const Text("Done"),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SectionedListView(
      children: [
        Section.children(
          children: [
            ListTile(
              title: const Text("Name"),
              trailing: Text(_name),
            ),
          ],
        ),
        Section.children(
          header: const Text("Key Details"),
          children: [
            ListTile(
              title: const Text("Key"),
              trailing: Text(_newKeyData.toHex()),
            ),
            ListTile(
              title: const Text("Old Key"),
              trailing: Text(_key?.oldKey?.toHex() ?? "N/A"),
            ),
            ListTile(
              title: const Text("Index"),
              trailing: Text(_newKeyIndex.toString()),
            ),
          ],
        ),
        Section.children(
          header: const Text("Bound Network Keys"),
          children: const [
            ListTile(
              leading: Icon(Icons.key),
              title: Text("Primary Network Key (TBD)"),
            ),
          ],
        ),
        Section.children(children: [
          // Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: context.theme.appColors.error.defaultColor,
                  )),
            ),
          ),
        ])
      ],
    );
  }

  void _onDone() {
    final success = _saveKey();
    if (success) {
      Navigator.of(context).pop();
    }
  }

  bool _saveKey() {
    final network = AppNetworkManager.instance.meshNetworkManager.meshNetwork!;

    final res = network.addApplicationKey(
      name: _name,
      keyData: _newKeyData,
      index: _newKeyIndex,
    );

    if (res.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create key: ${res.asError!.error}"),
        ),
      );
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Key created successfully"),
      ),
    );
    return true;
  }
}
