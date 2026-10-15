/// api 의 GET /menu 가 돌려주는 메뉴 한 줄. (apps/api/src/menu/menu.service.ts 의 MenuItem)
class MenuItem {
  const MenuItem({required this.id, required this.name, required this.price});

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as int,
    name: json['name'] as String,
    price: json['price'] as int,
  );

  final int id;
  final String name;
  final int price;
}
