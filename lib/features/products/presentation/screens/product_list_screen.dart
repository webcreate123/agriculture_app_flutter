import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_drawer.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  bool? _isOrganic;
  bool? _isSeasonalProduct;
  String? _sortBy;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(
          ProductLoadEvent(
            skip: _currentPage * _itemsPerPage,
            limit: _itemsPerPage,
            category: _selectedCategory,
            searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            isOrganic: _isOrganic,
            isSeasonalProduct: _isSeasonalProduct,
            sortBy: _sortBy,
            sortAscending: _sortAscending,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: ProductFilterDrawer(
        selectedCategory: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        isOrganic: _isOrganic,
        isSeasonalProduct: _isSeasonalProduct,
        onApplyFilters: (category, minPrice, maxPrice, isOrganic, isSeasonalProduct) {
          setState(() {
            _selectedCategory = category;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _isOrganic = isOrganic;
            _isSeasonalProduct = isSeasonalProduct;
            _currentPage = 0;
          });
          _loadProducts();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '商品を検索',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadProducts();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _loadProducts(),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (String value) {
                    setState(() {
                      if (_sortBy == value) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = value;
                        _sortAscending = true;
                      }
                      _currentPage = 0;
                    });
                    _loadProducts();
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'price',
                      child: Text('価格順'),
                    ),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('名前順'),
                    ),
                    const PopupMenuItem(
                      value: 'createdAt',
                      child: Text('登録日順'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoadedState) {
                  if (state.products.isEmpty) {
                    return const Center(child: Text('商品が見つかりませんでした'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadProducts();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ProductCard(product: product);
                      },
                    ),
                  );
                } else if (state is ProductErrorState) {
                  return Center(child: Text('エラーが発生しました: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 