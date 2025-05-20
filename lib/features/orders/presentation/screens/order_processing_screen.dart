import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/order_model.dart';
import '../bloc/order_bloc.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key});

  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _prefectureController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  double? _shippingFee;

  @override
  void initState() {
    super.initState();
    _postalCodeController.addListener(_onPostalCodeChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _postalCodeController.dispose();
    _prefectureController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _onPostalCodeChanged() {
    if (_postalCodeController.text.length == 7) {
      context.read<OrderBloc>().add(
            OrderCalculateShippingFeeEvent(
              postalCode: _postalCodeController.text,
              prefecture: _prefectureController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注文手続き'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderShippingFeeCalculatedState) {
            setState(() {
              _shippingFee = state.shippingFee;
            });
          }
        },
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 配送先情報
                const Text(
                  '配送先情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'お名前',
                    hintText: '山田 太郎',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'お名前を入力してください';
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
                  ),
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
                TextFormField(
                  controller: _prefectureController,
                  decoration: const InputDecoration(
                    labelText: '都道府県',
                    hintText: '東京都',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '都道府県を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: '市区町村',
                    hintText: '渋谷区',
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
                    labelText: '番地・建物名',
                    hintText: '1-2-3 ○○マンション101',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '番地・建物名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: '電話番号',
                    hintText: '09012345678（ハイフンなし）',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '電話番号を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 支払い方法
                const Text(
                  '支払い方法',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                RadioListTile<PaymentMethod>(
                  title: const Text('クレジットカード'),
                  value: PaymentMethod.creditCard,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<PaymentMethod>(
                  title: const Text('銀行振込'),
                  value: PaymentMethod.bankTransfer,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                RadioListTile<PaymentMethod>(
                  title: const Text('代金引換'),
                  value: PaymentMethod.cashOnDelivery,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // 配送料
                if (_shippingFee != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '配送料',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '¥${_shippingFee!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                // 注文ボタン
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _shippingFee != null) {
                      context.read<OrderBloc>().add(
                            OrderCreateEvent(
                              shippingName: _nameController.text,
                              shippingPostalCode: _postalCodeController.text,
                              shippingPrefecture: _prefectureController.text,
                              shippingCity: _cityController.text,
                              shippingAddress: _addressController.text,
                              shippingPhoneNumber: _phoneNumberController.text,
                              paymentMethod: _selectedPaymentMethod,
                              shippingFee: _shippingFee!,
                            ),
                          );
                    }
                  },
                  child: const Text('注文を確定する'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 