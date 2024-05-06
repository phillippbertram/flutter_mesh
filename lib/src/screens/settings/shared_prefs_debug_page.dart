import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsDebugPage extends StatefulWidget {
  const SharedPrefsDebugPage({super.key});

  @override
  State<SharedPrefsDebugPage> createState() => _SharedPrefsDebugPageState();
}

class _SharedPrefsDebugPageState extends State<SharedPrefsDebugPage> {
  SharedPreferences? _sharedPrefs;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _sharedPrefs = prefs;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Preferences"),
      ),
      body: _sharedPrefsContent(context),
    );
  }

  Widget _sharedPrefsContent(BuildContext context) {
    if (_sharedPrefs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(children: [
      Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: context.theme.appColors.error.defaultColor,
          ),
          onPressed: () async {
            final shouldDelete = await _showDeleteAllPrompt(context);
            if (!shouldDelete) {
              return;
            }
            _sharedPrefs!.clear();
            setState(() {});
          },
          child: const Text("Clear all shared preferences"),
        ),
      ),
      ..._sharedPrefsEntries(context),
      // list all entries
    ]);
  }

  List<Widget> _sharedPrefsEntries(BuildContext context) {
    final keysSet = _sharedPrefs?.getKeys();
    if (keysSet == null || keysSet.isEmpty) {
      return [
        const ListTile(
          title: Text("No entries found"),
        )
      ];
    }

    // sort keys
    final keys = keysSet.toList()..sort();

    return keys.map((key) {
      final value = _sharedPrefs?.getString(key);
      return _sharedPrefsEntry(context, key, value ?? "");
    }).toList();
  }

  Widget _sharedPrefsEntry(BuildContext context, String key, String value) {
    return ListTile(
        title: Text(key),
        subtitle: Text(value),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_forever,
            color: context.theme.appColors.error.defaultColor,
          ),
          onPressed: () async {
            await _sharedPrefs?.remove(key);
            setState(() {});
          },
        ));
  }
}

Future<bool> _showDeleteAllPrompt(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete all shared preferences"),
            content: const Text(
                "Are you sure you want to delete all shared preferences?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.theme.appColors.error.defaultColor,
                ),
                child: const Text("Delete"),
              ),
            ],
          );
        },
      ) ??
      false;
}
