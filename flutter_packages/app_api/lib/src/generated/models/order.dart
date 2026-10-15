// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'order_line.dart';
import 'order_status.dart';
import 'status_change.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  const Order({
    required this.history,
    required this.id,
    required this.lines,
    required this.nickname,
    required this.number,
    required this.status,
    required this.total,
  });
  
  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json);
  
  /// 상태가 바뀐 시각 — 첫 줄이 접수(주문) 시각
  final List<StatusChange> history;
  final int id;
  final List<OrderLine> lines;
  final String nickname;

  /// 그날의 주문 번호 — 날짜가 바뀌면 1부터 다시
  final int number;
  final OrderStatus status;
  final int total;

  Map<String, Object?> toJson() => _$OrderToJson(this);
}
