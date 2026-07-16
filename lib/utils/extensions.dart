import '../core/api/api_exception.dart';

extension ObjectExtension on Object {
  String toUserMessage(String fallback) {
    return this is ApiException ? (this as ApiException).message : fallback;
  }
}
