import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('주문 번호는 세 자리로 채운다', () {
    expect(formatOrderNumber(1), '001');
    expect(formatOrderNumber(42), '042');
    expect(formatOrderNumber(1234), '1234');
  });
}
