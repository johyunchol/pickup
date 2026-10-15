import 'package:app_api/app_api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

// API 의 enum 값 → 화면에 보이는 말·아이콘·색. 디자인: design/pickup.pen

extension MenuCategoryLabel on MenuCategory {
  String get label => switch (this) {
    MenuCategory.coffee => '커피',
    MenuCategory.nonCoffee => '논커피',
    MenuCategory.dessert => '디저트',
  };

  IconData get icon => switch (this) {
    MenuCategory.coffee => Icons.local_cafe_outlined,
    MenuCategory.nonCoffee => Icons.emoji_food_beverage_outlined,
    MenuCategory.dessert => Icons.bakery_dining_outlined,
  };
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.received => '접수',
    OrderStatus.making => '제조 중',
    OrderStatus.ready => '픽업 대기',
    OrderStatus.done => '완료',
  };

  /// 손님에게 보여 주는 지금 상태
  String get headline => switch (this) {
    OrderStatus.received => '주문을 받았어요',
    OrderStatus.making => '지금 만들고 있어요',
    OrderStatus.ready => '픽업대에 나왔어요',
    OrderStatus.done => '픽업을 마쳤어요',
  };

  String get detail => switch (this) {
    OrderStatus.received => '곧 만들기 시작할게요',
    OrderStatus.making => '다 되면 번호를 불러 드릴게요',
    OrderStatus.ready => '번호를 확인하고 받아 가세요',
    OrderStatus.done => '맛있게 드세요!',
  };

  IconData get icon => switch (this) {
    OrderStatus.received => Icons.check_circle_outline_rounded,
    OrderStatus.making => Icons.coffee_maker_outlined,
    OrderStatus.ready => Icons.shopping_bag_outlined,
    OrderStatus.done => Icons.check_circle_outline_rounded,
  };

  Color get color => switch (this) {
    OrderStatus.received => PickupColors.statusReceived,
    OrderStatus.making => PickupColors.statusMaking,
    OrderStatus.ready => PickupColors.statusReady,
    OrderStatus.done => PickupColors.statusDone,
  };

  Color get softColor => switch (this) {
    OrderStatus.received => PickupColors.statusReceivedSoft,
    OrderStatus.making => PickupColors.statusMakingSoft,
    OrderStatus.ready => PickupColors.statusReadySoft,
    OrderStatus.done => PickupColors.statusDoneSoft,
  };
}
