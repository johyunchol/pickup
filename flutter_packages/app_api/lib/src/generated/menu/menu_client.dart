// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/menu_item.dart';
import '../models/update_menu_item_body.dart';

part 'menu_client.g.dart';

@RestApi()
abstract class MenuClient {
  factory MenuClient(Dio dio, {String? baseUrl}) = _MenuClient;

  /// 메뉴 목록
  @GET('/menu')
  Future<List<MenuItem>> listMenu();

  /// 메뉴 품절 켜고 끄기 (사장님)
  @PATCH('/menu/{id}')
  Future<MenuItem> updateMenuItem({
    @Path('id') required int id,
    @Body() required UpdateMenuItemBody body,
  });
}
