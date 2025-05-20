import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

// Events
abstract class ProductEvent {}

class ProductLoadEvent extends ProductEvent {
  final int? skip;
  final int? limit;
  final String? category;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String? farmerId;
  final bool? isOrganic;
  final bool? isSeasonalProduct;
  final String? sortBy;
  final bool? sortAscending;

  ProductLoadEvent({
    this.skip,
    this.limit,
    this.category,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.farmerId,
    this.isOrganic,
    this.isSeasonalProduct,
    this.sortBy,
    this.sortAscending,
  });
}

class ProductLoadByIdEvent extends ProductEvent {
  final String id;

  ProductLoadByIdEvent(this.id);
}

class ProductCreateEvent extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final List<String> images;
  final List<String>? tags;
  final bool isOrganic;
  final bool isSeasonalProduct;

  ProductCreateEvent({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.images,
    this.tags,
    required this.isOrganic,
    required this.isSeasonalProduct,
  });
}

class ProductUpdateEvent extends ProductEvent {
  final String id;
  final String? name;
  final String? description;
  final double? price;
  final int? stock;
  final String? category;
  final List<String>? images;
  final List<String>? tags;
  final bool? isOrganic;
  final bool? isSeasonalProduct;

  ProductUpdateEvent({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.category,
    this.images,
    this.tags,
    this.isOrganic,
    this.isSeasonalProduct,
  });
}

class ProductDeleteEvent extends ProductEvent {
  final String id;

  ProductDeleteEvent(this.id);
}

class ProductLoadCategoriesEvent extends ProductEvent {}

class ProductLoadPopularTagsEvent extends ProductEvent {}

class ProductLoadRecommendedEvent extends ProductEvent {
  final String? category;
  final List<String>? tags;
  final int? limit;

  ProductLoadRecommendedEvent({
    this.category,
    this.tags,
    this.limit,
  });
}

class ProductLoadSeasonalEvent extends ProductEvent {
  final int? limit;

  ProductLoadSeasonalEvent({this.limit});
}

class ProductLoadPopularEvent extends ProductEvent {
  final int? limit;

  ProductLoadPopularEvent({this.limit});
}

class ProductLoadFarmerProductsEvent extends ProductEvent {
  final String farmerId;
  final int? skip;
  final int? limit;

  ProductLoadFarmerProductsEvent({
    required this.farmerId,
    this.skip,
    this.limit,
  });
}

// States
abstract class ProductState {}

class ProductInitialState extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductLoadedState extends ProductState {
  final List<ProductModel> products;

  ProductLoadedState(this.products);
}

class ProductDetailLoadedState extends ProductState {
  final ProductModel product;

  ProductDetailLoadedState(this.product);
}

class ProductCategoriesLoadedState extends ProductState {
  final List<String> categories;

  ProductCategoriesLoadedState(this.categories);
}

class ProductTagsLoadedState extends ProductState {
  final List<String> tags;

  ProductTagsLoadedState(this.tags);
}

class ProductErrorState extends ProductState {
  final String message;

  ProductErrorState(this.message);
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitialState()) {
    on<ProductLoadEvent>(_onLoadProducts);
    on<ProductLoadByIdEvent>(_onLoadProductById);
    on<ProductCreateEvent>(_onCreateProduct);
    on<ProductUpdateEvent>(_onUpdateProduct);
    on<ProductDeleteEvent>(_onDeleteProduct);
    on<ProductLoadCategoriesEvent>(_onLoadCategories);
    on<ProductLoadPopularTagsEvent>(_onLoadPopularTags);
    on<ProductLoadRecommendedEvent>(_onLoadRecommendedProducts);
    on<ProductLoadSeasonalEvent>(_onLoadSeasonalProducts);
    on<ProductLoadPopularEvent>(_onLoadPopularProducts);
    on<ProductLoadFarmerProductsEvent>(_onLoadFarmerProducts);
  }

  Future<void> _onLoadProducts(
    ProductLoadEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final products = await _productRepository.getProducts(
        skip: event.skip,
        limit: event.limit,
        category: event.category,
        searchQuery: event.searchQuery,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        farmerId: event.farmerId,
        isOrganic: event.isOrganic,
        isSeasonalProduct: event.isSeasonalProduct,
        sortBy: event.sortBy,
        sortAscending: event.sortAscending,
      );
      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadProductById(
    ProductLoadByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final product = await _productRepository.getProductById(event.id);
      emit(ProductDetailLoadedState(product));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    ProductCreateEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final product = await _productRepository.createProduct(
        name: event.name,
        description: event.description,
        price: event.price,
        stock: event.stock,
        category: event.category,
        images: event.images,
        tags: event.tags,
        isOrganic: event.isOrganic,
        isSeasonalProduct: event.isSeasonalProduct,
      );
      emit(ProductDetailLoadedState(product));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    ProductUpdateEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final product = await _productRepository.updateProduct(
        id: event.id,
        name: event.name,
        description: event.description,
        price: event.price,
        stock: event.stock,
        category: event.category,
        images: event.images,
        tags: event.tags,
        isOrganic: event.isOrganic,
        isSeasonalProduct: event.isSeasonalProduct,
      );
      emit(ProductDetailLoadedState(product));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    ProductDeleteEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      await _productRepository.deleteProduct(event.id);
      emit(ProductInitialState());
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    ProductLoadCategoriesEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final categories = await _productRepository.getCategories();
      emit(ProductCategoriesLoadedState(categories));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadPopularTags(
    ProductLoadPopularTagsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final tags = await _productRepository.getPopularTags();
      emit(ProductTagsLoadedState(tags));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadRecommendedProducts(
    ProductLoadRecommendedEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final products = await _productRepository.getRecommendedProducts(
        category: event.category,
        tags: event.tags,
        limit: event.limit,
      );
      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadSeasonalProducts(
    ProductLoadSeasonalEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final products = await _productRepository.getSeasonalProducts(
        limit: event.limit,
      );
      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadPopularProducts(
    ProductLoadPopularEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final products = await _productRepository.getPopularProducts(
        limit: event.limit,
      );
      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> _onLoadFarmerProducts(
    ProductLoadFarmerProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      final products = await _productRepository.getFarmerProducts(
        farmerId: event.farmerId,
        skip: event.skip,
        limit: event.limit,
      );
      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }
} 