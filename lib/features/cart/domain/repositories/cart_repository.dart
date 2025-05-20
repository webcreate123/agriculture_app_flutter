import '../models/cart_item_model.dart';

abstract class CartRepository {
  /// カート内のアイテムを全て取得
  Future<List<CartItemModel>> getCartItems();

  /// カートにアイテムを追加
  Future<CartItemModel> addToCart({
    required String productId,
    required int quantity,
  });

  /// カート内のアイテムの数量を更新
  Future<CartItemModel> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  /// カートからアイテムを削除
  Future<void> removeFromCart(String cartItemId);

  /// カートを空にする
  Future<void> clearCart();

  /// カート内のアイテムの合計金額を取得
  Future<double> getCartTotal();

  /// カート内のアイテム数を取得
  Future<int> getCartItemCount();

  /// 特定の商品がカートに存在するか確認
  Future<bool> isProductInCart(String productId);

  /// 特定の商品のカート内での数量を取得
  Future<int?> getProductQuantityInCart(String productId);
} 