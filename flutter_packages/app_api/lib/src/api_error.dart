import 'package:dio/dio.dart';

/// 서버의 오류 응답 본문 `{ statusCode, code, message }` 를 읽는다.
extension ApiErrorMessage on DioException {
  /// 서버가 보낸 오류 메시지 — 응답이 없거나(연결 실패 등) 모양이 다르면 null
  String? get serverMessage {
    final data = response?.data;
    return data is Map && data['message'] is String
        ? data['message'] as String
        : null;
  }
}
