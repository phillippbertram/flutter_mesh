import 'package:flutter/material.dart';

class ProxyPage extends StatelessWidget {
  const ProxyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy'),
      ),
      body: const Center(
        child: Text('Proxy Page'),
      ),
    );
  }
}
