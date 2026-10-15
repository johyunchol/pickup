// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  history: (json['history'] as List<dynamic>)
      .map((e) => StatusChange.fromJson(e as Map<String, dynamic>))
      .toList(),
  id: (json['id'] as num).toInt(),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  nickname: json['nickname'] as String,
  number: (json['number'] as num).toInt(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'history': instance.history,
  'id': instance.id,
  'lines': instance.lines,
  'nickname': instance.nickname,
  'number': instance.number,
  'status': instance.status,
  'total': instance.total,
};

const _$OrderStatusEnumMap = {
  OrderStatus.received: 'received',
  OrderStatus.making: 'making',
  OrderStatus.ready: 'ready',
  OrderStatus.done: 'done',
};
