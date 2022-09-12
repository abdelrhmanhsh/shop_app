import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cart_item.dart';
import '../models/http_exception.dart';
import '../utils/constants.dart';
import '../utils/private_constants.dart';

class Cart with ChangeNotifier {

  final cartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}');

  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double totalSum = 0.0;
    _items.forEach((key, cartItem) {
      totalSum += cartItem.price * cartItem.quantity;
    });
    return totalSum;
  }

  Future<void> fetchCart() async {

    try {
      final response = await http.get(cartUrl);
      final data = json.decode(response.body);

      if (data == null) {
        return;
      }

      data.forEach((id, data) {
        _items.putIfAbsent(id, () => CartItem(id: data['id'], title: data['title'], quantity: data['quantity'], price: data['price']));
      });

      notifyListeners();

    } catch(error) {
      rethrow;
    }

  }

  Future<void> addItem(String id, double price, String title) async {

    try {

      // item doesn't exist in cart
      if (!_items.containsKey(id)) {

        await http.post(
            cartUrl,
            body: json.encode({
              'id': id,
              'title': title,
              'price': price,
              'quantity': 1
            })
        );
        _items.putIfAbsent(id, () => CartItem(id: id, title: title, quantity: 1, price: price));
      }

      notifyListeners();

    } catch(error) {
      rethrow;
    }

  }

  // Future<void> toggleFavoriteStatus() async {
  //
  //   bool? favState = isFavorite;
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  //
  //   final favProductsUrl = Uri.parse('${PrivateConstants.mainUrl}products/$id.json');
  //
  //   final response = await http.patch(
  //       favProductsUrl,
  //       body: json.encode({
  //         'isFavorite': !favState,
  //       })
  //   );
  //
  //   if (response.statusCode >= 400) {
  //     isFavorite = !isFavorite;
  //     notifyListeners();
  //     throw HttpException('Could not add item to favorites!');
  //   }
  //
  //   favState = null;
  //
  // }

  Future<void> increaseItemQuantity(String id, int quantity) async {
    // item exist in cart

    // int? currQuantity = quantity;
    if (_items.containsKey(id)) {
      _items.update(
        id, (currentItem) =>
          CartItem(
              id: currentItem.id,
              title: currentItem.title,
              quantity: currentItem.quantity + 1,
              price: currentItem.price
          ),
      );
    }
    notifyListeners();

    final quantityCartUrl = Uri.parse('${PrivateConstants.mainUrl}cart/$id');

    final response = await http.patch(
        quantityCartUrl,
        body: json.encode({
          'quantity': quantity + 1,
        })
    );

    // rollback changes
    if (response.statusCode >= 400) {
      if (_items.containsKey(id)) {
        _items.update(
          id, (currentItem) =>
            CartItem(
                id: currentItem.id,
                title: currentItem.title,
                quantity: currentItem.quantity - 1,
                price: currentItem.price
            ),
        );
      }
      notifyListeners();
      throw HttpException('Could not update item to quantity!');
    }

  }

  void decreaseItemQuantity(String id, int quantity) {
    // item exist in cart
    if(_items[id]!.quantity > 1) {
      _items.update(id, (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price)
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeAddedItem(String id) {
    if (!_items.containsKey(id)) {
      return;
    }
    if(_items[id]!.quantity > 1) { // item already in cart - reduce quantity
      _items.update(id, (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price)
      );
    } else { // item wasn't in card - remove it
      _items.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

}