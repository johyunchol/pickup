import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('세 자리마다 쉼표를 찍고 원을 붙인다', () {
    expect(formatPrice(4500), '4,500원');
    expect(formatPrice(1234567), '1,234,567원');
  });

  test('세 자리 이하는 쉼표가 없다', () {
    expect(formatPrice(0), '0원');
    expect(formatPrice(500), '500원');
  });

  test('음수는 앞에 - 를 붙인다', () {
    expect(formatPrice(-4500), '-4,500원');
  });
}
