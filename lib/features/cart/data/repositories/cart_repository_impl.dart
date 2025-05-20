import 'package:dio/dio.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiClient _apiClient;

  CartRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final response = await _apiClient.get('/cart');
      final List<dynamic> data = response.data['items'];
      return data.map((item) => CartItemModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CartItemModel> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.post('/cart/items', data: {
        'productId': productId,
        'quantity': quantity,
      });
      return CartItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CartItemModel> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/cart/items/$cartItemId',
        data: {'quantity': quantity},
      );
      return CartItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _apiClient.delete('/cart/items/$cartItemId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _apiClient.delete('/cart');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<double> getCartTotal() async {
    try {
      final response = await _apiClient.get('/cart/total');
      return response.data['total'].toDouble();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<int> getCartItemCount() async {
    try {
      final response = await _apiClient.get('/cart/count');
      return response.data['count'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> isProductInCart(String productId) async {
    try {
      final response = await _apiClient.get('/cart/check/$productId');
      return response.data['exists'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<int?> getProductQuantityInCart(String productId) async {
    try {
      final response = await _apiClient.get('/cart/quantity/$productId');
      return response.data['quantity'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('カートが見つかりません');
    } else if (e.response?.statusCode == 400) {
      return ValidationException(e.response?.data['message'] ?? '無効なリクエストです');
    } else if (e.response?.statusCode == 401) {
      return UnauthorizedException('認証が必要です');
    } else {
      return ServerException('サーバーエラーが発生しました');
    }
  }
} 