import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../widgets/order_filter_drawer.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _scrollController = ScrollController();
  static const _pageSize = 10;
  bool _hasReachedMax = false;
  DateTime? _startDate;
  DateTime? _endDate;
  final _selectedStatuses = <OrderStatus>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    context.read<OrderBloc>().add(
          OrdersLoadEvent(
            skip: 0,
            limit: _pageSize,
            startDate: _startDate,
            endDate: _endDate,
            statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses.toList(),
          ),
        );
  }

  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<OrderBloc>().state;
      if (state is OrdersLoadedState) {
        context.read<OrderBloc>().add(
              OrdersLoadEvent(
                skip: state.orders.length,
                limit: _pageSize,
                startDate: _startDate,
                endDate: _endDate,
                statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses.toList(),
              ),
            );
      }
    }
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

  void _showFilterDrawer() {
    Scaffold.of(context).openEndDrawer();
  }

  void _onApplyFilter(
    DateTime? startDate,
    DateTime? endDate,
    Set<OrderStatus> selectedStatuses,
  ) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _selectedStatuses.clear();
      _selectedStatuses.addAll(selectedStatuses);
      _hasReachedMax = false;
    });
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注文履歴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDrawer,
          ),
        ],
      ),
      endDrawer: OrderFilterDrawer(
        startDate: _startDate,
        endDate: _endDate,
        selectedStatuses: _selectedStatuses,
        onApplyFilter: _onApplyFilter,
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is OrdersLoadedState) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Text('注文履歴がありません'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadOrders();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.orders.length) {
                    if (state.orders.length % _pageSize != 0) {
                      _hasReachedMax = true;
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final order = state.orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              orderId: order.id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 8),
                            Text(
                              '¥${order.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '注文日時: ${order.createdAt.toLocal().toString().split('.')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
} 