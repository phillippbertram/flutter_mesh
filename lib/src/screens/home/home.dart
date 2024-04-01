import 'package:flutter_mesh/src/screens/network/network_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../groups/groups_page.dart';
import '../local_node/local_node_page.dart';
import '../proxy/proxy_page.dart';
import '../settings/settings_page.dart';

class HomePage extends HookWidget {
  const HomePage({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = useState(0);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          currentPageIndex.value = index;
        },
        selectedIndex: currentPageIndex.value,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.lightbulb),
            icon: Icon(Icons.lightbulb_outline),
            label: 'Local Node',
          ),
          NavigationDestination(
            icon: Icon(Icons.cell_tower),
            label: 'Network',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.group),
            icon: Icon(Icons.group_outlined),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_rounded),
            label: 'Proxy',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex.value,
        children: <Widget>[
          const LocalNodePage(),
          const NetworkPage(),
          const GroupsPage(),
          const ProxyPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}
