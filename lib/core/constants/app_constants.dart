class AppConstants {
  static const String appName = 'AgriMarket';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = 'http://localhost:3000/api';  // Update this with your actual API URL
  static const String wsUrl = 'wss://api.agrimarket.com/api/v1/chat/ws';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  
  // Asset Paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int chatPageSize = 50;
  
  // Timeouts
  static const int connectionTimeout = 30000;  // 30 seconds
  static const int receiveTimeout = 30000;     // 30 seconds
  
  // Cache Duration
  static const int cacheDuration = 7200; // 2 hours in seconds
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 1000;
  static const int maxChatMessageLength = 500;
  
  // File Upload
  static const int maxImageSize = 5242880; // 5MB in bytes
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Product Categories
  static const List<String> productCategories = [
    '野菜',
    '果物',
    '米・穀物',
    '肉類',
    '魚介類',
    '加工食品',
    '乳製品',
    '卵',
    'お茶',
    'その他'
  ];
  
  // Order Status
  static const String orderStatusPending = 'PENDING';
  static const String orderStatusPaid = 'PAID';
  static const String orderStatusProcessing = 'PROCESSING';
  static const String orderStatusShipped = 'SHIPPED';
  static const String orderStatusDelivered = 'DELIVERED';
  static const String orderStatusCancelled = 'CANCELLED';
  
  // User Roles
  static const String roleFarmer = 'FARMER';
  static const String roleCustomer = 'CUSTOMER';
  
  // Error Messages
  static const String networkError = 'ネットワークエラーが発生しました。';
  static const String serverError = 'サーバーエラーが発生しました。';
  static const String unauthorizedError = '認証エラーが発生しました。';
  static const String validationError = '入力内容に誤りがあります。';
  
  // Success Messages
  static const String loginSuccess = 'ログインしました。';
  static const String registerSuccess = '登録が完了しました。';
  static const String orderSuccess = '注文が完了しました。';
  static const String updateSuccess = '更新が完了しました。';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String getCurrentUserEndpoint = '/auth/me';
  static const String updateProfileEndpoint = '/auth/profile';
  static const String changePasswordEndpoint = '/auth/password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String cartEndpoint = '/cart';
} 