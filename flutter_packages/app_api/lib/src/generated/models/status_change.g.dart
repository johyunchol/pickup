// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusChange _$StatusChangeFromJson(Map<String, dynamic> json) => StatusChange(
  at: DateTime.parse(json['at'] as String),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
);

Map<String, dynamic> _$StatusChangeToJson(StatusChange instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'status': instance.status,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.received: 'received',
  OrderStatus.making: 'making',
  OrderStatus.ready: 'ready',
  OrderStatus.done: 'done',
};
