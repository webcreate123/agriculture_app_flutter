import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/order_model.dart';
import '../bloc/order_bloc.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderLoadEvent(orderId: widget.orderId));
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '注文受付';
      case OrderStatus.processing:
        return '処理中';
      case OrderStatus.shipped:
        return '発送済み';
      case OrderStatus.delivered:
        return '配達完了';
      case OrderStatus.cancelled:
        return 'キャンセル';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
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

  String _formatAddress(OrderModel order) {
    final buffer = StringBuffer()
      ..write('〒')
      ..write(order.shippingPostalCode.replaceAllMapped(
          RegExp(r'(\d{3})(\d{4})'), (m) => '${m[1]}-${m[2]}'))
      ..write('\n')
      ..write(order.shippingPrefecture)
      ..write(order.shippingCity)
      ..write(order.shippingAddress);

    if (order.shippingBuildingName != null &&
        order.shippingBuildingName!.isNotEmpty) {
      buffer.write('\n');
      buffer.write(order.shippingBuildingName);
    }

    return buffer.toString();
  }

  String _formatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAllMapped(
        RegExp(r'(\d{2,4})(\d{2,4})(\d{3,4})'), (m) => '${m[1]}-${m[2]}-${m[3]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注文詳細'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OrderCancelledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('注文をキャンセルしました')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is OrderLoadedState) {
            final order = state.order;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '注文番号: ${order.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withValues(
                          red: _getStatusColor(order.status).r,
                          green: _getStatusColor(order.status).g,
                          blue: _getStatusColor(order.status).b,
                          alpha: 0.1
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(order.status),
                        style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '注文商品',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final item in order.items)
                        ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.quantity}個'),
                          trailing: Text(
                            '¥${(item.price * item.quantity).toStringAsFixed(0)}',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                        Text(order.shippingName),
                        const SizedBox(height: 8),
                        Text(_formatAddress(order)),
                        const SizedBox(height: 8),
                        Text('TEL: ${_formatPhoneNumber(order.shippingPhoneNumber)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '支払い情報',
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('支払い方法'),
                            Text(_getPaymentMethodText(order.paymentMethod)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('商品合計'),
                            Text('¥${order.subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('配送料'),
                            Text('¥${order.shippingFee.toStringAsFixed(0)}'),
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
                              '¥${order.total.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (order.status == OrderStatus.pending)
                  ElevatedButton(
                    onPressed: state is OrderLoadingState
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('注文のキャンセル'),
                                content: const Text('この注文をキャンセルしてもよろしいですか？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('いいえ'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<OrderBloc>().add(
                                            OrderCancelEvent(
                                              orderId: order.id,
                                            ),
                                          );
                                    },
                                    child: const Text(
                                      'はい',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: state is OrderLoadingState
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('注文をキャンセルする'),
                  ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
} 