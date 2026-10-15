import 'package:app_api/app_api.dart';

// 샷 추가 — 커피만, 한 줄에 0~2번. 값은 계약(packages/contract)의
// EXTRA_SHOT_PRICE · OrderLine.extraShot 의 최대값과 같다.

const extraShotPrice = 500;
const maxExtraShot = 2;

extension MenuItemShot on MenuItem {
  bool get canAddShot => category == MenuCategory.coffee;
}

/// "아메리카노 (샷 +1)" — 샷 추가가 없으면 이름만
String nameWithShot(String name, int extraShot) =>
    extraShot == 0 ? name : '$name (샷 +$extraShot)';

/// 한 줄 금액 — (메뉴 가격 + 샷 추가) × 수량
int lineAmount({
  required int price,
  required int extraShot,
  required int quantity,
}) => (price + extraShot * extraShotPrice) * quantity;

extension OrderLineAmount on OrderLine {
  int get amount =>
      lineAmount(price: price, extraShot: extraShot, quantity: quantity);
}
