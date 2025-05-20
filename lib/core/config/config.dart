class Config {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  
  // APIのタイムアウト設定
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);
  
  // ストレージのキー
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
} 