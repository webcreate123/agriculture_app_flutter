import '../models/user_model.dart';

abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<String?> getAccessToken();

  Future<UserModel> getCurrentUser();

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImage,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetPassword({
    required String email,
  });
} 