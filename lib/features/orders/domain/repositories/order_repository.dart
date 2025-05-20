import '../models/order_model.dart';

abstract class OrderRepository {
  /// 注文を作成
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
  });

  /// 注文をキャンセル
  Future<void> cancelOrder(String id);

  /// 注文履歴を取得
  Future<List<OrderModel>> getOrders({
    required int skip,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    List<OrderStatus>? statuses,
  });

  /// 注文の詳細を取得
  Future<OrderModel> getOrderById(String id);

  /// 配送料を計算
  Future<double> calculateShippingFee({
    required String postalCode,
    required String prefecture,
  });
} 