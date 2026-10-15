// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  category: $enumDecode(_$MenuCategoryEnumMap, json['category']),
  description: json['description'] as String,
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  price: (json['price'] as num).toInt(),
  soldOut: json['soldOut'] as bool,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'category': instance.category,
  'description': instance.description,
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'soldOut': instance.soldOut,
};

const _$MenuCategoryEnumMap = {
  MenuCategory.coffee: 'coffee',
  MenuCategory.nonCoffee: 'non_coffee',
  MenuCategory.dessert: 'dessert',
};
