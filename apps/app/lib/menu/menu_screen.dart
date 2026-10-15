import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

import 'menu_api.dart';
import 'menu_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.menuApi});

  final MenuApi menuApi;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<MenuItem>> _menu = widget.menuApi.fetchMenu();

  void _reload() {
    setState(() {
      _menu = widget.menuApi.fetchMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메뉴')),
      body: FutureBuilder<List<MenuItem>>(
        future: _menu,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('메뉴를 불러오지 못했습니다'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _reload, child: const Text('다시 시도')),
                ],
              ),
            );
          }
          final menu = snapshot.requireData;
          return ListView.separated(
            itemCount: menu.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => ListTile(
              title: Text(menu[i].name),
              trailing: Text(formatPrice(menu[i].price)),
            ),
          );
        },
      ),
    );
  }
}
