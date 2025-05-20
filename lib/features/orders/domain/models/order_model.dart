import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonEnum()
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

@JsonEnum()
enum PaymentMethod {
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('cash_on_delivery')
  cashOnDelivery,
}

@JsonSerializable()
class OrderItemModel {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}

@JsonSerializable()
class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String shippingName;
  final String shippingPostalCode;
  final String shippingPrefecture;
  final String shippingCity;
  final String shippingAddress;
  final String? shippingBuildingName;
  final String shippingPhoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.shippingName,
    required this.shippingPostalCode,
    required this.shippingPrefecture,
    required this.shippingCity,
    required this.shippingAddress,
    this.shippingBuildingName,
    required this.shippingPhoneNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
} 