import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';

class ProductFilterDrawer extends StatefulWidget {
  final String? selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final bool? isOrganic;
  final bool? isSeasonalProduct;
  final Function(String? category, double? minPrice, double? maxPrice,
      bool? isOrganic, bool? isSeasonalProduct) onApplyFilters;

  const ProductFilterDrawer({
    super.key,
    this.selectedCategory,
    this.minPrice,
    this.maxPrice,
    this.isOrganic,
    this.isSeasonalProduct,
    required this.onApplyFilters,
  });

  @override
  State<ProductFilterDrawer> createState() => _ProductFilterDrawerState();
}

class _ProductFilterDrawerState extends State<ProductFilterDrawer> {
  late String? _selectedCategory;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late bool? _isOrganic;
  late bool? _isSeasonalProduct;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _minPriceController =
        TextEditingController(text: widget.minPrice?.toString() ?? '');
    _maxPriceController =
        TextEditingController(text: widget.maxPrice?.toString() ?? '');
    _isOrganic = widget.isOrganic;
    _isSeasonalProduct = widget.isSeasonalProduct;

    // カテゴリー一覧を取得
    context.read<ProductBloc>().add(ProductLoadCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'フィルター',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('リセット'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'カテゴリー',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductCategoriesLoadedState) {
                        return Wrap(
                          spacing: 8.0,
                          children: [
                            FilterChip(
                              label: const Text('すべて'),
                              selected: _selectedCategory == null,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                }
                              },
                            ),
                            ...state.categories.map(
                              (category) => FilterChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _selectedCategory =
                                        selected ? category : null;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '価格帯',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '最小価格',
                            prefixText: '¥',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('〜'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '最大価格',
                            prefixText: '¥',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '商品タイプ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('オーガニック'),
                    value: _isOrganic ?? false,
                    tristate: true,
                    onChanged: (bool? value) {
                      setState(() {
                        _isOrganic = value;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('旬の商品'),
                    value: _isSeasonalProduct ?? false,
                    tristate: true,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSeasonalProduct = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('フィルターを適用'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _isOrganic = null;
      _isSeasonalProduct = null;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(
      _selectedCategory,
      _minPriceController.text.isNotEmpty
          ? double.tryParse(_minPriceController.text)
          : null,
      _maxPriceController.text.isNotEmpty
          ? double.tryParse(_maxPriceController.text)
          : null,
      _isOrganic,
      _isSeasonalProduct,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
} 