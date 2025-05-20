import 'package:dio/dio.dart';
import '../../domain/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiClient _apiClient;

  OrderRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<OrderModel> createOrder({
    required PaymentMethod paymentMethod,
    required String shippingName,
    required String shippingPostalCode,
    required String shippingPrefecture,
    required String shippingCity,
    required String shippingAddress,
    String? shippingBuildingName,
    required String shippingPhoneNumber,
    required double shippingFee,
  }) async {
    try {
      final response = await _apiClient.post(
        '/orders',
        data: {
          'paymentMethod': paymentMethod.toString().split('.').last,
          'shippingName': shippingName,
          'shippingPostalCode': shippingPostalCode,
          'shippingPrefecture': shippingPrefecture,
          'shippingCity': shippingCity,
          'shippingAddress': shippingAddress,
          'shippingBuildingName': shippingBuildingName,
          'shippingPhoneNumber': shippingPhoneNumber,
          'shippingFee': shippingFee,
        },
      );
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await _apiClient.post('/orders/$id/cancel');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<OrderModel>> getOrders({
    required int skip,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    List<OrderStatus>? statuses,
  }) async {
    try {
      final queryParameters = {
        'skip': skip,
        'limit': limit,
        if (startDate != null)
          'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null)
          'endDate': endDate.toUtc().toIso8601String(),
        if (statuses != null && statuses.isNotEmpty)
          'statuses': statuses
              .map((status) => status.toString().split('.').last)
              .join(','),
      };

      final response = await _apiClient.get(
        '/orders',
        queryParameters: queryParameters,
      );

      return (response.data as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _apiClient.get('/orders/$id');
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<double> calculateShippingFee({
    required String postalCode,
    required String prefecture,
  }) async {
    try {
      final response = await _apiClient.get(
        '/shipping/calculate',
        queryParameters: {
          'postalCode': postalCode,
          'prefecture': prefecture,
        },
      );
      return (response.data['fee'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkTimeoutException();
      case DioExceptionType.connectionError:
        return NetworkConnectionException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] as String?;
        switch (statusCode) {
          case 400:
            return BadRequestException(message);
          case 401:
            return UnauthorizedException(message);
          case 403:
            return ForbiddenException(message);
          case 404:
            return NotFoundException(message);
          case 409:
            return ConflictException(message);
          case 422:
            return ValidationException(message);
          case 500:
            return ServerException(message);
          default:
            return UnknownException(message);
        }
      default:
        return UnknownException(e.message);
    }
  }
} 