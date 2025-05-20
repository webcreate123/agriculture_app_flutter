import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;

  ProductRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
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
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {
          if (skip != null) 'skip': skip,
          if (limit != null) 'limit': limit,
          if (category != null) 'category': category,
          if (searchQuery != null) 'search': searchQuery,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (farmerId != null) 'farmerId': farmerId,
          if (isOrganic != null) 'isOrganic': isOrganic,
          if (isSeasonalProduct != null) 'isSeasonalProduct': isSeasonalProduct,
          if (sortBy != null) 'sortBy': sortBy,
          if (sortAscending != null) 'sortAscending': sortAscending,
        },
      );

      final List<dynamic> products = response.data!['products'];
      return products
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/$id',
      );

      return ProductModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
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
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/products',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category': category,
          'images': images,
          if (tags != null) 'tags': tags,
          'isOrganic': isOrganic,
          'isSeasonalProduct': isSeasonalProduct,
        },
      );

      return ProductModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
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
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/products/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          if (stock != null) 'stock': stock,
          if (category != null) 'category': category,
          if (images != null) 'images': images,
          if (tags != null) 'tags': tags,
          if (isOrganic != null) 'isOrganic': isOrganic,
          if (isSeasonalProduct != null) 'isSeasonalProduct': isSeasonalProduct,
        },
      );

      return ProductModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete<void>('/products/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/categories',
      );

      final List<dynamic> categories = response.data!['categories'];
      return categories.map((category) => category.toString()).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<String>> getPopularTags() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/tags/popular',
      );

      final List<dynamic> tags = response.data!['tags'];
      return tags.map((tag) => tag.toString()).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProductModel>> getRecommendedProducts({
    String? category,
    List<String>? tags,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/recommended',
        queryParameters: {
          if (category != null) 'category': category,
          if (tags != null) 'tags': tags.join(','),
          if (limit != null) 'limit': limit,
        },
      );

      final List<dynamic> products = response.data!['products'];
      return products
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProductModel>> getSeasonalProducts({
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/seasonal',
        queryParameters: {
          if (limit != null) 'limit': limit,
        },
      );

      final List<dynamic> products = response.data!['products'];
      return products
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProductModel>> getPopularProducts({
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/popular',
        queryParameters: {
          if (limit != null) 'limit': limit,
        },
      );

      final List<dynamic> products = response.data!['products'];
      return products
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProductModel>> getFarmerProducts({
    required String farmerId,
    int? skip,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/farmer/$farmerId',
        queryParameters: {
          if (skip != null) 'skip': skip,
          if (limit != null) 'limit': limit,
        },
      );

      final List<dynamic> products = response.data!['products'];
      return products
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return Exception(AppConstants.unauthorizedError);
    } else if (error.response?.statusCode == 400) {
      return Exception(AppConstants.validationError);
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception(AppConstants.networkError);
    }
    return Exception(AppConstants.serverError);
  }
} 