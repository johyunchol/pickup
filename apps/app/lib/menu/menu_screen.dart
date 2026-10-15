import 'package:app_api/app_api.dart';
import 'package:app_core/app_core.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../cart.dart';
import '../labels.dart';
import '../order/checkout_screen.dart';
import '../order/order_status_screen.dart';
import '../shot.dart';

// 화면 디자인: design/pickup.pen 의 "03 손님 · 메뉴"
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.api});

  final PickupApi api;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _cart = Cart();
  late Future<List<MenuItem>> _menu = _load();

  /// null 이면 전체
  MenuCategory? _category;

  /// 마지막으로 주문한 주문 — 오른쪽 위 버튼으로 다시 본다.
  Order? _lastOrder;

  Future<List<MenuItem>> _load() async {
    final menu = await widget.api.menu.listMenu();
    _cart.sync(menu);
    return menu;
  }

  void _reload() {
    setState(() {
      _menu = _load();
    });
  }

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final order = await Navigator.of(context).push<Order>(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(api: widget.api, cart: _cart),
      ),
    );
    if (!mounted) return;
    // 주문하는 사이 품절이 바뀌었을 수 있으니 돌아오면 메뉴를 다시 불러온다.
    _reload();
    if (order == null) return;
    _cart.clear();
    setState(() => _lastOrder = order);
    _showOrder(order);
  }

  void _showOrder(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderStatusScreen(api: widget.api, initial: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              onMyOrder: _lastOrder == null
                  ? null
                  : () => _showOrder(_lastOrder!),
            ),
            const _PickupInfo(),
            _CategoryChips(
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),
            Expanded(
              child: FutureBuilder<List<MenuItem>>(
                future: _menu,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _LoadError(onRetry: _reload);
                  }
                  final menu = snapshot.requireData
                      .where(
                        (m) => _category == null || m.category == _category,
                      )
                      .toList();
                  return ListenableBuilder(
                    listenable: _cart,
                    builder: (context, _) => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        PickupSpace.s5,
                        PickupSpace.s2,
                        PickupSpace.s5,
                        PickupSpace.s6,
                      ),
                      itemCount: menu.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: PickupSpace.s3),
                      itemBuilder: (context, i) => _MenuCard(
                        item: menu[i],
                        quantity: _cart.quantityOf(menu[i].id),
                        extraShot: _cart.extraShotOf(menu[i].id),
                        onAdd: () => _cart.add(menu[i]),
                        onRemove: () => _cart.remove(menu[i]),
                        onExtraShot: (n) => _cart.setExtraShot(menu[i], n),
                      ),
                    ),
                  );
                },
              ),
            ),
            ListenableBuilder(
              listenable: _cart,
              builder: (context, _) => _cart.isEmpty
                  ? const SizedBox.shrink()
                  : _CartBar(
                      count: _cart.count,
                      total: _cart.total,
                      onTap: _checkout,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onMyOrder});

  final VoidCallback? onMyOrder;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PickupSpace.s5,
        PickupSpace.s4,
        PickupSpace.s5,
        PickupSpace.s2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '온기 커피 · 연남점',
                  style: text.bodyMedium?.copyWith(
                    color: PickupColors.textMuted,
                  ),
                ),
                const SizedBox(height: PickupSpace.s1),
                Text('무엇을 마실까요?', style: text.titleLarge),
              ],
            ),
          ),
          if (onMyOrder != null)
            IconButton.outlined(
              tooltip: '내 주문',
              onPressed: onMyOrder,
              style: IconButton.styleFrom(
                backgroundColor: PickupColors.surface,
                side: const BorderSide(color: PickupColors.border),
                fixedSize: const Size.square(44),
              ),
              icon: const Icon(
                Icons.receipt_long_outlined,
                size: 22,
                color: PickupColors.text,
              ),
            ),
        ],
      ),
    );
  }
}

class _PickupInfo extends StatelessWidget {
  const _PickupInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PickupSpace.s5,
        vertical: PickupSpace.s2,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _Pill(
          color: PickupColors.statusReady,
          background: PickupColors.statusReadySoft,
          label: '영업 중 · 로그인 없이 닉네임으로 주문해요',
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.color,
    required this.background,
    required this.label,
  });

  final Color color;
  final Color background;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PickupSpace.s3,
        vertical: PickupSpace.s2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PickupRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: PickupSpace.s2),
          Text(
            label,
            style: pickupFont(
              TextStyle(
                color: color,
                fontSize: PickupFontSize.xs,
                fontWeight: PickupFontWeight.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final MenuCategory? selected;
  final ValueChanged<MenuCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(MenuCategory? category) {
      final on = category == selected;
      return Padding(
        padding: const EdgeInsets.only(right: PickupSpace.s2),
        child: Material(
          color: on ? PickupColors.text : PickupColors.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: on ? PickupColors.text : PickupColors.border,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => onSelected(category),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PickupSpace.s4,
                vertical: PickupSpace.s2,
              ),
              child: Text(
                category?.label ?? '전체',
                style: pickupFont(
                  TextStyle(
                    color: on ? PickupColors.surface : PickupColors.text,
                    fontSize: PickupFontSize.sm,
                    fontWeight: PickupFontWeight.medium,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: PickupSpace.s5,
        vertical: PickupSpace.s3,
      ),
      child: Row(
        children: [chip(null), for (final c in MenuCategory.values) chip(c)],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
    required this.quantity,
    required this.extraShot,
    required this.onAdd,
    required this.onRemove,
    required this.onExtraShot,
  });

  final MenuItem item;
  final int quantity;
  final int extraShot;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<int> onExtraShot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = item.soldOut;
    // 커피를 담았을 때만 샷 추가를 고른다.
    final showShot = !muted && quantity > 0 && item.canAddShot;
    return Container(
      padding: const EdgeInsets.all(PickupSpace.s3),
      decoration: BoxDecoration(
        color: PickupColors.surface,
        borderRadius: BorderRadius.circular(PickupRadius.lg),
        border: Border.all(
          color: quantity > 0 ? PickupColors.primary : PickupColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: muted
                      ? PickupColors.surfaceMuted
                      : PickupColors.primarySoft,
                  borderRadius: BorderRadius.circular(PickupRadius.md),
                ),
                child: Icon(
                  item.category.icon,
                  size: 32,
                  color: muted ? PickupColors.textMuted : PickupColors.primary,
                ),
              ),
              const SizedBox(width: PickupSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: text.titleMedium?.copyWith(
                              color: muted ? PickupColors.textMuted : null,
                            ),
                          ),
                        ),
                        if (muted) ...[
                          const SizedBox(width: PickupSpace.s2),
                          const _SoldOutBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: PickupSpace.s1),
                    Text(
                      item.description,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: PickupSpace.s1),
                    Text(
                      formatPrice(item.price + extraShot * extraShotPrice),
                      style: text.titleMedium?.copyWith(
                        color: muted ? PickupColors.textMuted : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (!muted) ...[
                const SizedBox(width: PickupSpace.s2),
                quantity == 0
                    ? _RoundButton(
                        icon: Icons.add_rounded,
                        size: 36,
                        iconSize: 20,
                        background: PickupColors.primarySoft,
                        foreground: PickupColors.primary,
                        tooltip: '${item.name} 담기',
                        onPressed: onAdd,
                      )
                    : _Stepper(
                        name: item.name,
                        quantity: quantity,
                        onAdd: onAdd,
                        onRemove: onRemove,
                      ),
              ],
            ],
          ),
          if (showShot)
            _ShotPicker(
              name: item.name,
              extraShot: extraShot,
              onChanged: onExtraShot,
            ),
        ],
      ),
    );
  }
}

/// 샷 추가 없음 · +1 · +2
class _ShotPicker extends StatelessWidget {
  const _ShotPicker({
    required this.name,
    required this.extraShot,
    required this.onChanged,
  });

  final String name;
  final int extraShot;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: PickupSpace.s3),
      padding: const EdgeInsets.only(top: PickupSpace.s3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PickupColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '샷 추가 · 한 번에 ${formatPrice(extraShotPrice)}',
              style: text.bodySmall,
            ),
          ),
          for (var n = 0; n <= maxExtraShot; n++)
            Padding(
              padding: const EdgeInsets.only(left: PickupSpace.s2),
              child: _ShotChip(
                label: n == 0 ? '없음' : '+$n',
                tooltip: n == 0 ? '$name 샷 추가 없음' : '$name 샷 +$n',
                selected: n == extraShot,
                onTap: () => onChanged(n),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShotChip extends StatelessWidget {
  const _ShotChip({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? PickupColors.primary : PickupColors.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? PickupColors.primary : PickupColors.border,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PickupSpace.s3,
                vertical: PickupSpace.s1,
              ),
              child: Text(
                label,
                style: pickupFont(
                  TextStyle(
                    color: selected
                        ? PickupColors.onPrimary
                        : PickupColors.text,
                    fontSize: PickupFontSize.xs,
                    fontWeight: PickupFontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoldOutBadge extends StatelessWidget {
  const _SoldOutBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PickupSpace.s2,
        vertical: PickupSpace.s1 / 2,
      ),
      decoration: BoxDecoration(
        color: PickupColors.dangerSoft,
        borderRadius: BorderRadius.circular(PickupRadius.sm),
      ),
      child: Text(
        '품절',
        style: pickupFont(
          const TextStyle(
            color: PickupColors.danger,
            fontSize: PickupFontSize.xs,
            fontWeight: PickupFontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.name,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final String name;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PickupSpace.s1),
      decoration: BoxDecoration(
        color: PickupColors.primarySoft,
        borderRadius: BorderRadius.circular(PickupRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            icon: Icons.remove_rounded,
            size: 28,
            iconSize: 16,
            background: PickupColors.surface,
            foreground: PickupColors.primary,
            tooltip: '$name 빼기',
            onPressed: onRemove,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: pickupFont(
                const TextStyle(
                  color: PickupColors.primary,
                  fontSize: PickupFontSize.sm,
                  fontWeight: PickupFontWeight.bold,
                ),
              ),
            ),
          ),
          _RoundButton(
            icon: Icons.add_rounded,
            size: 28,
            iconSize: 16,
            background: PickupColors.primary,
            foreground: PickupColors.onPrimary,
            tooltip: '$name 더 담기',
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.background,
    required this.foreground,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.count,
    required this.total,
    required this.onTap,
  });

  final int count;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = pickupFont(
      const TextStyle(
        color: PickupColors.onPrimary,
        fontSize: PickupFontSize.md,
        fontWeight: PickupFontWeight.bold,
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        color: PickupColors.bg,
        border: Border(top: BorderSide(color: PickupColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        PickupSpace.s4,
        PickupSpace.s3,
        PickupSpace.s4,
        PickupSpace.s3,
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: PickupColors.primary,
          borderRadius: BorderRadius.circular(PickupRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(PickupRadius.lg),
            onTap: onTap,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: PickupSpace.s5),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: PickupColors.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: pickupFont(
                        const TextStyle(
                          color: PickupColors.primary,
                          fontSize: PickupFontSize.sm,
                          fontWeight: PickupFontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: PickupSpace.s3),
                  Expanded(child: Text('장바구니 보기', style: label)),
                  Text(formatPrice(total), style: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('메뉴를 불러오지 못했습니다'),
          const SizedBox(height: PickupSpace.s3),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
