import 'package:app_api/app_api.dart';
import 'package:flutter/foundation.dart';

/// 장바구니 — 메뉴를 담은 순서대로 기억한다. 앱 안에서만 쓰고 저장하지 않는다.
class Cart extends ChangeNotifier {
  final Map<int, ({MenuItem item, int quantity})> _lines = {};

  Iterable<({MenuItem item, int quantity})> get lines => _lines.values;

  bool get isEmpty => _lines.isEmpty;

  int quantityOf(int menuId) => _lines[menuId]?.quantity ?? 0;

  int get count => lines.fold(0, (sum, l) => sum + l.quantity);

  int get total => lines.fold(0, (sum, l) => sum + l.item.price * l.quantity);

  void add(MenuItem item) {
    _lines[item.id] = (item: item, quantity: quantityOf(item.id) + 1);
    notifyListeners();
  }

  void remove(MenuItem item) {
    final quantity = quantityOf(item.id) - 1;
    if (quantity <= 0) {
      _lines.remove(item.id);
    } else {
      _lines[item.id] = (item: item, quantity: quantity);
    }
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
        _lines[id] = (item: item, quantity: _lines[id]!.quantity);
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
      CreateOrderItem(menuId: l.item.id, quantity: l.quantity),
  ];
}
