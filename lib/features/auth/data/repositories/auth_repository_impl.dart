import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      await _secureStorage.setAccessToken(data['accessToken']);
      await _secureStorage.setRefreshToken(data['refreshToken']);
      await _secureStorage.setUserId(data['userId']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await _apiClient.post(
        AppConstants.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null;
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getCurrentUserEndpoint,
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImage,
  }) async {
    try {
      await _apiClient.put(
        AppConstants.updateProfileEndpoint,
        data: {
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (address != null) 'address': address,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put(
        AppConstants.changePasswordEndpoint,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _apiClient.post(
        AppConstants.resetPasswordEndpoint,
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception(AppConstants.networkError);
    }

    if (error.response?.statusCode == 401) {
      return Exception(AppConstants.unauthorizedError);
    }

    if (error.response?.statusCode == 400) {
      return Exception(AppConstants.validationError);
    }

    return Exception(AppConstants.serverError);
  }
} 