/// 원 단위 가격을 세 자리마다 쉼표를 찍어 표시한다. 예: 4500 → '4,500원'
String formatPrice(int won) {
  final digits = won.abs().toString();
  final buffer = StringBuffer(won < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  buffer.write('원');
  return buffer.toString();
}
