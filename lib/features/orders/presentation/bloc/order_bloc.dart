import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';

// Events
abstract class OrderEvent {}

class OrdersLoadEvent extends OrderEvent {
  final int skip;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<OrderStatus>? statuses;

  OrdersLoadEvent({
    required this.skip,
    required this.limit,
    this.startDate,
    this.endDate,
    this.statuses,
  });
}

class OrderLoadEvent extends OrderEvent {
  final String orderId;

  OrderLoadEvent({required this.orderId});
}

class OrderCreateEvent extends OrderEvent {
  final PaymentMethod paymentMethod;
  final String shippingName;
  final String shippingPostalCode;
  final String shippingPrefecture;
  final String shippingCity;
  final String shippingAddress;
  final String? shippingBuildingName;
  final String shippingPhoneNumber;
  final double shippingFee;

  OrderCreateEvent({
    required this.paymentMethod,
    required this.shippingName,
    required this.shippingPostalCode,
    required this.shippingPrefecture,
    required this.shippingCity,
    required this.shippingAddress,
    this.shippingBuildingName,
    required this.shippingPhoneNumber,
    required this.shippingFee,
  });
}

class OrderCancelEvent extends OrderEvent {
  final String orderId;

  OrderCancelEvent({required this.orderId});
}

class OrderCalculateShippingFeeEvent extends OrderEvent {
  final String postalCode;
  final String prefecture;

  OrderCalculateShippingFeeEvent({
    required this.postalCode,
    required this.prefecture,
  });
}

// States
abstract class OrderState {}

class OrderInitialState extends OrderState {}

class OrderLoadingState extends OrderState {}

class OrdersLoadedState extends OrderState {
  final List<OrderModel> orders;

  OrdersLoadedState({required this.orders});
}

class OrderLoadedState extends OrderState {
  final OrderModel order;

  OrderLoadedState({required this.order});
}

class OrderCreatedState extends OrderState {
  final OrderModel order;

  OrderCreatedState({required this.order});
}

class OrderCancelledState extends OrderState {
  final String orderId;

  OrderCancelledState({required this.orderId});
}

class OrderErrorState extends OrderState {
  final String message;

  OrderErrorState({required this.message});
}

class OrderShippingFeeCalculatedState extends OrderState {
  final double shippingFee;

  OrderShippingFeeCalculatedState({required this.shippingFee});
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitialState()) {
    on<OrdersLoadEvent>(_onLoadOrders);
    on<OrderLoadEvent>(_onLoadOrder);
    on<OrderCreateEvent>(_onCreateOrder);
    on<OrderCancelEvent>(_onCancelOrder);
    on<OrderCalculateShippingFeeEvent>(_onCalculateShippingFee);
  }

  Future<void> _onLoadOrders(
    OrdersLoadEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoadingState());
      final orders = await _orderRepository.getOrders(
        skip: event.skip,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
        statuses: event.statuses,
      );
      emit(OrdersLoadedState(orders: orders));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoadOrder(
    OrderLoadEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoadingState());
      final order = await _orderRepository.getOrderById(event.orderId);
      emit(OrderLoadedState(order: order));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    OrderCreateEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoadingState());
      final order = await _orderRepository.createOrder(
        paymentMethod: event.paymentMethod,
        shippingName: event.shippingName,
        shippingPostalCode: event.shippingPostalCode,
        shippingPrefecture: event.shippingPrefecture,
        shippingCity: event.shippingCity,
        shippingAddress: event.shippingAddress,
        shippingBuildingName: event.shippingBuildingName,
        shippingPhoneNumber: event.shippingPhoneNumber,
        shippingFee: event.shippingFee,
      );
      emit(OrderCreatedState(order: order));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _onCancelOrder(
    OrderCancelEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoadingState());
      await _orderRepository.cancelOrder(event.orderId);
      emit(OrderCancelledState(orderId: event.orderId));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _onCalculateShippingFee(
    OrderCalculateShippingFeeEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoadingState());
      final shippingFee = await _orderRepository.calculateShippingFee(
        postalCode: event.postalCode,
        prefecture: event.prefecture,
      );
      emit(OrderShippingFeeCalculatedState(shippingFee: shippingFee));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
} 