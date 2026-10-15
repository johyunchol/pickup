// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// received 접수 → making 제조 중 → ready 픽업 대기 → done 완료
@JsonEnum()
enum OrderStatus {
  @JsonValue('received')
  received('received'),
  @JsonValue('making')
  making('making'),
  @JsonValue('ready')
  ready('ready'),
  @JsonValue('done')
  done('done');

  const OrderStatus(this.json);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
}
