import 'package:json_annotation/json_annotation.dart';
import '../../../auth/domain/models/user_model.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final List<String> images;
  final UserModel farmer;
  final List<String>? tags;
  final bool isOrganic;
  final bool isSeasonalProduct;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.images,
    required this.farmer,
    this.tags,
    required this.isOrganic,
    required this.isSeasonalProduct,
    this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<String>? images,
    UserModel? farmer,
    List<String>? tags,
    bool? isOrganic,
    bool? isSeasonalProduct,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      images: images ?? this.images,
      farmer: farmer ?? this.farmer,
      tags: tags ?? this.tags,
      isOrganic: isOrganic ?? this.isOrganic,
      isSeasonalProduct: isSeasonalProduct ?? this.isSeasonalProduct,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 