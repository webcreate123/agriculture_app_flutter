class NetworkTimeoutException implements Exception {
  final String? message;
  NetworkTimeoutException([this.message = 'ネットワークタイムアウトが発生しました']);
}

class NetworkConnectionException implements Exception {
  final String? message;
  NetworkConnectionException([this.message = 'ネットワーク接続エラーが発生しました']);
}

class BadRequestException implements Exception {
  final String? message;
  BadRequestException([this.message = 'リクエストが不正です']);
}

class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException([this.message = '認証が必要です']);
}

class ForbiddenException implements Exception {
  final String? message;
  ForbiddenException([this.message = 'アクセスが拒否されました']);
}

class NotFoundException implements Exception {
  final String? message;
  NotFoundException([this.message = 'リソースが見つかりません']);
}

class ConflictException implements Exception {
  final String? message;
  ConflictException([this.message = 'リソースが競合しています']);
}

class ValidationException implements Exception {
  final String? message;
  ValidationException([this.message = '入力内容が正しくありません']);
}

class ServerException implements Exception {
  final String? message;
  ServerException([this.message = 'サーバーエラーが発生しました']);
}

class UnknownException implements Exception {
  final String? message;
  UnknownException([this.message = '予期せぬエラーが発生しました']);
} 