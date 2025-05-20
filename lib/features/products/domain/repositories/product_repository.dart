import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({
    int? skip,
    int? limit,
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? farmerId,
    bool? isOrganic,
    bool? isSeasonalProduct,
    String? sortBy,
    bool? sortAscending,
  });

  Future<ProductModel> getProductById(String id);

  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<String> images,
    List<String>? tags,
    required bool isOrganic,
    required bool isSeasonalProduct,
  });

  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<String>? images,
    List<String>? tags,
    bool? isOrganic,
    bool? isSeasonalProduct,
  });

  Future<void> deleteProduct(String id);

  Future<List<String>> getCategories();

  Future<List<String>> getPopularTags();

  Future<List<ProductModel>> getRecommendedProducts({
    String? category,
    List<String>? tags,
    int? limit,
  });

  Future<List<ProductModel>> getSeasonalProducts({
    int? limit,
  });

  Future<List<ProductModel>> getPopularProducts({
    int? limit,
  });

  Future<List<ProductModel>> getFarmerProducts({
    required String farmerId,
    int? skip,
    int? limit,
  });
} 