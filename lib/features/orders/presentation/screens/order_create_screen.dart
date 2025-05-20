import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/order_model.dart';
import '../widgets/prefecture_picker.dart';
import '../bloc/order_bloc.dart';
import 'order_confirmation_screen.dart';

class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({super.key});

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _prefecture = '';
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.creditCard;
  double? _shippingFee;

  @override
  void dispose() {
    _nameController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _buildingNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _calculateShippingFee() {
    if (_postalCodeController.text.length == 7 && _prefecture.isNotEmpty) {
      context.read<OrderBloc>().add(
            OrderCalculateShippingFeeEvent(
              postalCode: _postalCodeController.text,
              prefecture: _prefecture,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配送情報の入力'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderShippingFeeCalculatedState) {
            setState(() {
              _shippingFee = state.shippingFee;
            });
          } else if (state is OrderErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '氏名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '氏名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: '郵便番号',
                    hintText: '1234567（ハイフンなし）',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onChanged: (value) {
                    if (value.length == 7) {
                      _calculateShippingFee();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '郵便番号を入力してください';
                    }
                    if (value.length != 7) {
                      return '郵便番号は7桁で入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PrefecturePicker(
                  selectedPrefecture: _prefecture,
                  onChanged: (value) {
                    setState(() {
                      _prefecture = value;
                    });
                    _calculateShippingFee();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: '市区町村',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '市区町村を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: '番地',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '番地を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _buildingNameController,
                  decoration: const InputDecoration(
                    labelText: '建物名・部屋番号（任意）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: '電話番号',
                    hintText: '09012345678（ハイフンなし）',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '電話番号を入力してください';
                    }
                    if (value.length < 10 || value.length > 11) {
                      return '電話番号は10桁または11桁で入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '支払い方法',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RadioListTile<PaymentMethod>(
                  title: const Text('クレジットカード'),
                  value: PaymentMethod.creditCard,
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<PaymentMethod>(
                  title: const Text('銀行振込'),
                  value: PaymentMethod.bankTransfer,
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<PaymentMethod>(
                  title: const Text('代金引換'),
                  value: PaymentMethod.cashOnDelivery,
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (_shippingFee != null) ...[
                  Text(
                    '配送料: ¥${_shippingFee!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ElevatedButton(
                  onPressed: state is OrderLoadingState
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderConfirmationScreen(
                                  paymentMethod: _paymentMethod,
                                  shippingName: _nameController.text,
                                  shippingPostalCode: _postalCodeController.text,
                                  shippingPrefecture: _prefecture,
                                  shippingCity: _cityController.text,
                                  shippingAddress: _addressController.text,
                                  shippingBuildingName:
                                      _buildingNameController.text.isEmpty
                                          ? null
                                          : _buildingNameController.text,
                                  shippingPhoneNumber: _phoneNumberController.text,
                                  shippingFee: _shippingFee ?? 0,
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text('注文内容の確認へ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 