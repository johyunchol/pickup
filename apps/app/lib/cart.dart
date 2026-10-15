import 'package:app_api/app_api.dart';
import 'package:flutter/foundation.dart';

import 'shot.dart';

typedef CartLine = ({MenuItem item, int quantity, int extraShot});

/// 장바구니 — 메뉴를 담은 순서대로 기억한다. 앱 안에서만 쓰고 저장하지 않는다.
/// 샷 추가는 메뉴마다 하나 — 그 메뉴를 담은 잔 모두에 같이 붙는다.
class Cart extends ChangeNotifier {
  final Map<int, CartLine> _lines = {};

  Iterable<CartLine> get lines => _lines.values;

  bool get isEmpty => _lines.isEmpty;

  int quantityOf(int menuId) => _lines[menuId]?.quantity ?? 0;

  int extraShotOf(int menuId) => _lines[menuId]?.extraShot ?? 0;

  int get count => lines.fold(0, (sum, l) => sum + l.quantity);

  int get total => lines.fold(0, (sum, l) => sum + amountOf(l));

  static int amountOf(CartLine l) => lineAmount(
    price: l.item.price,
    extraShot: l.extraShot,
    quantity: l.quantity,
  );

  void add(MenuItem item) {
    _lines[item.id] = (
      item: item,
      quantity: quantityOf(item.id) + 1,
      extraShot: extraShotOf(item.id),
    );
    notifyListeners();
  }

  void remove(MenuItem item) {
    final quantity = quantityOf(item.id) - 1;
    if (quantity <= 0) {
      _lines.remove(item.id);
    } else {
      _lines[item.id] = (
        item: item,
        quantity: quantity,
        extraShot: extraShotOf(item.id),
      );
    }
    notifyListeners();
  }

  /// 담은 커피의 샷 추가를 바꾼다 — 담지 않았거나 커피가 아니면 무시한다.
  void setExtraShot(MenuItem item, int extraShot) {
    final line = _lines[item.id];
    if (line == null || !item.canAddShot) return;
    _lines[item.id] = (
      item: item,
      quantity: line.quantity,
      extraShot: extraShot.clamp(0, maxExtraShot),
    );
    notifyListeners();
  }

  /// 새로 불러온 메뉴에 맞춘다 — 없어졌거나 품절된 메뉴는 빼고, 가격·이름은 새 값으로.
  void sync(List<MenuItem> menu) {
    final byId = {for (final m in menu) m.id: m};
    for (final id in _lines.keys.toList()) {
      final item = byId[id];
      if (item == null || item.soldOut) {
        _lines.remove(id);
      } else {
        final line = _lines[id]!;
        _lines[id] = (
          item: item,
          quantity: line.quantity,
          extraShot: item.canAddShot ? line.extraShot : 0,
        );
      }
    }
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  List<CreateOrderItem> toOrderItems() => [
    for (final l in lines)
      CreateOrderItem(
        menuId: l.item.id,
        quantity: l.quantity,
        extraShot: l.extraShot,
      ),
  ];
}
