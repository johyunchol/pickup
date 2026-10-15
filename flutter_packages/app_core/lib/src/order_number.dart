/// 주문 번호를 세 자리로 보여 준다. 예: 42 → '042'
String formatOrderNumber(int number) => number.toString().padLeft(3, '0');
