import 'package:app_core/app_core.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'menu_api.dart';
import 'menu_item.dart';

// 화면 디자인: design/pickup.pen 의 "03 손님 · 메뉴". 담기·장바구니는 주문 기능과 함께 붙인다.
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: FutureBuilder<List<MenuItem>>(
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
                          const SizedBox(height: PickupSpace.s3),
                          FilledButton(
                            onPressed: _reload,
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }
                  final menu = snapshot.requireData;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      PickupSpace.s5,
                      PickupSpace.s2,
                      PickupSpace.s5,
                      PickupSpace.s6,
                    ),
                    itemCount: menu.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: PickupSpace.s3),
                    itemBuilder: (context, i) => _MenuCard(item: menu[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PickupSpace.s5,
        PickupSpace.s4,
        PickupSpace.s5,
        PickupSpace.s3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '메뉴',
            style: text.bodyMedium?.copyWith(color: PickupColors.textMuted),
          ),
          const SizedBox(height: PickupSpace.s1),
          Text('무엇을 마실까요?', style: text.titleLarge),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PickupSpace.s3),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: PickupColors.primarySoft,
                borderRadius: BorderRadius.circular(PickupRadius.md),
              ),
              child: const Icon(
                Icons.local_cafe_outlined,
                size: 32,
                color: PickupColors.primary,
              ),
            ),
            const SizedBox(width: PickupSpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: text.titleMedium),
                  const SizedBox(height: PickupSpace.s1),
                  Text(
                    formatPrice(item.price),
                    style: text.bodyLarge?.copyWith(
                      fontWeight: PickupFontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
