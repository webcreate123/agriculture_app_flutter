import 'package:json_annotation/json_annotation.dart';
import '../../../products/domain/models/product_model.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
} 