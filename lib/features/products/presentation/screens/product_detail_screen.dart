import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../bloc/product_bloc.dart';
import '../../domain/models/product_model.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductLoadByIdEvent(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductDetailLoadedState) {
            final product = state.product;
            return CustomScrollView(
              slivers: [
                _buildAppBar(product),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageCarousel(product),
                      _buildProductInfo(product),
                      const Divider(),
                      _buildFarmerInfo(product),
                      const Divider(),
                      _buildDescription(product),
                      if (product.tags != null && product.tags!.isNotEmpty) ...[
                        const Divider(),
                        _buildTags(product),
                      ],
                      const SizedBox(height: 80), // 購入ボタンの高さ分の余白
                    ],
                  ),
                ),
              ],
            );
          } else if (state is ProductErrorState) {
            return Center(child: Text('エラーが発生しました: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      bottomSheet: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductDetailLoadedState) {
            return _buildBottomSheet(state.product);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAppBar(ProductModel product) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      title: Text(product.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: シェア機能の実装
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel(ProductModel product) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 1,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: product.images.map((imageUrl) {
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          }).toList(),
        ),
        if (product.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: product.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withValues(red: 128, green: 128, blue: 128, alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(red: Theme.of(context).primaryColor.r, green: Theme.of(context).primaryColor.g, blue: Theme.of(context).primaryColor.b, alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (product.isOrganic)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'オーガニック',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (product.isSeasonalProduct) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '旬',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '¥${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (product.rating != null) ...[
                Icon(
                  Icons.star,
                  color: Colors.amber[700],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  product.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${product.reviewCount}件)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '在庫: ${product.stock}個',
            style: TextStyle(
              fontSize: 14,
              color: product.stock > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: product.farmer.profileImage != null
                ? NetworkImage(product.farmer.profileImage!)
                : null,
            child: product.farmer.profileImage == null
                ? Text(
                    product.farmer.name[0],
                    style: const TextStyle(fontSize: 20),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.farmer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  product.farmer.address ?? '場所未設定',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 生産者詳細画面に遷移
            },
            child: const Text('生産者を見る'),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '商品説明',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: product.tags!.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '#$tag',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomSheet(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<bool>(
              future: context.read<CartBloc>().isProductInCart(product.id),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return FutureBuilder<int?>(
                    future: context.read<CartBloc>().getProductQuantityInCart(product.id),
                    builder: (context, quantitySnapshot) {
                      if (quantitySnapshot.hasData) {
                        return Row(
                          children: [
                            IconButton(
                              onPressed: quantitySnapshot.data! > 1
                                  ? () {
                                      context.read<CartBloc>().add(
                                            CartUpdateQuantityEvent(
                                              cartItemId: product.id,
                                              quantity: quantitySnapshot.data! - 1,
                                            ),
                                          );
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              '${quantitySnapshot.data}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: product.stock > quantitySnapshot.data!
                                  ? () {
                                      context.read<CartBloc>().add(
                                            CartUpdateQuantityEvent(
                                              cartItemId: product.id,
                                              quantity: quantitySnapshot.data! + 1,
                                            ),
                                          );
                                    }
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        CartRemoveItemEvent(product.id),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('カートから削除'),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                }
                return ElevatedButton(
                  onPressed: product.stock > 0
                      ? () {
                          context.read<CartBloc>().add(
                                CartAddItemEvent(
                                  productId: product.id,
                                  quantity: 1,
                                ),
                              );
                        }
                      : null,
                  child: const Text('カートに追加'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 