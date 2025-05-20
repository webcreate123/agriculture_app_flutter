import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/repositories/cart_repository.dart';

// Events
abstract class CartEvent {}

class CartLoadEvent extends CartEvent {}

class CartAddItemEvent extends CartEvent {
  final String productId;
  final int quantity;

  CartAddItemEvent({
    required this.productId,
    required this.quantity,
  });
}

class CartUpdateQuantityEvent extends CartEvent {
  final String cartItemId;
  final int quantity;

  CartUpdateQuantityEvent({
    required this.cartItemId,
    required this.quantity,
  });
}

class CartRemoveItemEvent extends CartEvent {
  final String cartItemId;

  CartRemoveItemEvent(this.cartItemId);
}

class CartClearEvent extends CartEvent {}

// States
abstract class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  CartLoadedState({
    required this.items,
    required this.total,
    required this.itemCount,
  });
}

class CartErrorState extends CartState {
  final String message;

  CartErrorState(this.message);
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(CartInitialState()) {
    on<CartLoadEvent>(_onLoadCart);
    on<CartAddItemEvent>(_onAddItem);
    on<CartUpdateQuantityEvent>(_onUpdateQuantity);
    on<CartRemoveItemEvent>(_onRemoveItem);
    on<CartClearEvent>(_onClearCart);
  }

  Future<void> _onLoadCart(
    CartLoadEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoadingState());
    try {
      final items = await _cartRepository.getCartItems();
      final total = await _cartRepository.getCartTotal();
      final itemCount = await _cartRepository.getCartItemCount();
      emit(CartLoadedState(
        items: items,
        total: total,
        itemCount: itemCount,
      ));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onAddItem(
    CartAddItemEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.addToCart(
        productId: event.productId,
        quantity: event.quantity,
      );
      add(CartLoadEvent());
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
    CartUpdateQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.updateQuantity(
        cartItemId: event.cartItemId,
        quantity: event.quantity,
      );
      add(CartLoadEvent());
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onRemoveItem(
    CartRemoveItemEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.removeFromCart(event.cartItemId);
      add(CartLoadEvent());
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onClearCart(
    CartClearEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartRepository.clearCart();
      add(CartLoadEvent());
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<bool> isProductInCart(String productId) {
    return _cartRepository.isProductInCart(productId);
  }

  Future<int?> getProductQuantityInCart(String productId) {
    return _cartRepository.getProductQuantityInCart(productId);
  }
} 