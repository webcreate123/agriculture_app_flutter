import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final String shippingName;
  final String shippingPostalCode;
  final String shippingPrefecture;
  final String shippingCity;
  final String shippingAddress;
  final String? shippingBuildingName;
  final String shippingPhoneNumber;
  final double shippingFee;

  const OrderConfirmationScreen({
    super.key,
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

  String get _formattedAddress {
    final buffer = StringBuffer()
      ..write('〒')
      ..write(shippingPostalCode.replaceAllMapped(
          RegExp(r'(\d{3})(\d{4})'), (m) => '${m[1]}-${m[2]}'))
      ..write('\n')
      ..write(shippingPrefecture)
      ..write(shippingCity)
      ..write(shippingAddress);

    if (shippingBuildingName != null && shippingBuildingName!.isNotEmpty) {
      buffer.write('\n');
      buffer.write(shippingBuildingName);
    }

    return buffer.toString();
  }

  String get _formattedPhoneNumber {
    return shippingPhoneNumber.replaceAllMapped(
        RegExp(r'(\d{2,4})(\d{2,4})(\d{3,4})'), (m) => '${m[1]}-${m[2]}-${m[3]}');
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'クレジットカード';
      case PaymentMethod.bankTransfer:
        return '銀行振込';
      case PaymentMethod.cashOnDelivery:
        return '代金引換';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注文内容の確認'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreatedState) {
            context.read<CartBloc>().add(CartClearEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ご注文ありがとうございます')),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is OrderErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '配送先情報',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shippingName),
                      const SizedBox(height: 8),
                      Text(_formattedAddress),
                      const SizedBox(height: 8),
                      Text('TEL: $_formattedPhoneNumber'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '支払い方法',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_getPaymentMethodText(paymentMethod)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '注文金額',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      if (cartState is CartLoadedState) {
                        final subtotal = cartState.items.fold<double>(
                          0,
                          (sum, item) => sum + (item.product.price * item.quantity),
                        );
                        final total = subtotal + shippingFee;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('商品合計'),
                                Text('¥${subtotal.toStringAsFixed(0)}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('配送料'),
                                Text('¥${shippingFee.toStringAsFixed(0)}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '合計',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '¥${total.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state is OrderLoadingState
                    ? null
                    : () {
                        context.read<OrderBloc>().add(
                              OrderCreateEvent(
                                paymentMethod: paymentMethod,
                                shippingName: shippingName,
                                shippingPostalCode: shippingPostalCode,
                                shippingPrefecture: shippingPrefecture,
                                shippingCity: shippingCity,
                                shippingAddress: shippingAddress,
                                shippingBuildingName: shippingBuildingName,
                                shippingPhoneNumber: shippingPhoneNumber,
                                shippingFee: shippingFee,
                              ),
                            );
                      },
                child: state is OrderLoadingState
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('注文を確定する'),
              ),
            ],
          );
        },
      ),
    );
  }
} 