// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'order_status.dart';

part 'status_change.g.dart';

@JsonSerializable()
class StatusChange {
  const StatusChange({
    required this.at,
    required this.status,
  });
  
  factory StatusChange.fromJson(Map<String, Object?> json) => _$StatusChangeFromJson(json);
  
  final DateTime at;
  final OrderStatus status;

  Map<String, Object?> toJson() => _$StatusChangeToJson(this);
}
