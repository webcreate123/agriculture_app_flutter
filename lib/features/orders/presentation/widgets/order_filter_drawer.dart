import 'package:flutter/material.dart';
import '../../domain/models/order_model.dart';

class OrderFilterDrawer extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<OrderStatus> selectedStatuses;
  final Function(DateTime?, DateTime?, Set<OrderStatus>) onApplyFilter;

  const OrderFilterDrawer({
    super.key,
    this.startDate,
    this.endDate,
    required this.selectedStatuses,
    required this.onApplyFilter,
  });

  @override
  State<OrderFilterDrawer> createState() => _OrderFilterDrawerState();
}

class _OrderFilterDrawerState extends State<OrderFilterDrawer> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late Set<OrderStatus> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedStatuses = Set.from(widget.selectedStatuses);
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '絞り込み',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _selectedStatuses.clear();
                      });
                    },
                    child: const Text('リセット'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    '期間',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(
                            _startDate == null
                                ? '開始日'
                                : '${_startDate!.year}/${_startDate!.month}/${_startDate!.day}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('〜'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(
                            _endDate == null
                                ? '終了日'
                                : '${_endDate!.year}/${_endDate!.month}/${_endDate!.day}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '注文状態',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...OrderStatus.values.map(
                    (status) => CheckboxListTile(
                      title: Text(_getStatusText(status)),
                      value: _selectedStatuses.contains(status),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedStatuses.add(status);
                          } else {
                            _selectedStatuses.remove(status);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilter(
                    _startDate,
                    _endDate,
                    _selectedStatuses,
                  );
                  Navigator.pop(context);
                },
                child: const Text('適用'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 