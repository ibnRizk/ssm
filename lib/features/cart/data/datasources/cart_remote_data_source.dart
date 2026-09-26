import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/cart.dart';
import '../models/cart_line_model.dart';

/// Changes answer with the whole cart as a bare array. Should one ever
/// answer with something else, the cart is fetched again instead of
/// guessing at its shape.
abstract class CartRemoteDataSource {
  Future<Cart> getCart();

  Future<Cart> addItem({
    required int itemId,
    required double unitPrice,
    required int quantity,
  });

  Future<Cart> updateQuantity({required int cartLineId, required int quantity});

  Future<Cart> removeLine(int cartLineId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioConsumer consumer;

  const CartRemoteDataSourceImpl({required this.consumer});

  @override
  Future<Cart> getCart() async =>
      CartLineModel.cartFromJson(await consumer.get(ApiEndpoints.cartList));

  /// `model: "Item"` — the cart also takes other kinds of products.
  @override
  Future<Cart> addItem({
    required int itemId,
    required double unitPrice,
    required int quantity,
  }) async => _cartOrRefetch(
    await consumer.post(
      ApiEndpoints.cartAdd,
      body: <String, dynamic>{
        'item_id': itemId,
        'model': 'Item',
        'quantity': quantity,
        'price': unitPrice,
      },
    ),
  );

  @override
  Future<Cart> updateQuantity({
    required int cartLineId,
    required int quantity,
  }) async => _cartOrRefetch(
    await consumer.post(
      ApiEndpoints.cartUpdate,
      body: <String, dynamic>{'cart_id': cartLineId, 'quantity': quantity},
    ),
  );

  @override
  Future<Cart> removeLine(int cartLineId) async => _cartOrRefetch(
    await consumer.delete(
      ApiEndpoints.cartRemoveItem,
      data: <String, dynamic>{'cart_id': cartLineId},
    ),
  );

  Future<Cart> _cartOrRefetch(dynamic json) async =>
      json is List ? CartLineModel.cartFromJson(json) : getCart();
}
