import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cart_item.dart';
import '../models/http_exception.dart';
import '../utils/constants.dart';
import '../utils/private_constants.dart';

class Cart with ChangeNotifier {

  final String? _authToken;
  final String? _userId;
  Map<String, CartItem> _items;

  Cart(this._authToken, this._userId, this._items);

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

    final cartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}/$_userId.json/?auth=$_authToken');

    try {
      final response = await http.get(cartUrl);
      final data = json.decode(response.body);

      if (data == null) {
        return;
      }

      data.forEach((id, data) {
        _items.putIfAbsent(id, () => CartItem(
            id: data['id'],
            title: data['title'],
            quantity: data['quantity'],
            price: data['price']
        ));
      });

      notifyListeners();

    } catch(error) {
      rethrow;
    }

  }

  Future<void> addItem(String id, double price, String title) async {

    var cartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}/$_userId.json/?auth=$_authToken');

    try {

      // item doesn't exist in cart
      if (!_items.containsKey(id)) {

        final response = await http.post(
            cartUrl,
            body: json.encode({
              'id': '',
              'title': title,
              'price': price,
              'quantity': 1
            })
        );

        final id = json.decode(response.body)['name'];
        cartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}/$_userId/$id.json?auth=$_authToken');

        await http.patch(
            cartUrl,
            body: json.encode({
              'id': id,
            })
        );

        _items.putIfAbsent(
            id, () => CartItem(
            id: id,
            title: title,
            quantity: 1,
            price: price)
        );
      }

      notifyListeners();

    } catch(error) {
      rethrow;
    }

  }

  Future<void> increaseItemQuantity(String id, int quantity) async {
    // item exist in cart

    print('cart item id $id');
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

    final quantityCartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}/$_userId/$id.json?auth=$_authToken');

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
      throw HttpException('Could not update item quantity!');
    }

  }

  Future<void> decreaseItemQuantity(String id, int quantity) async {
    // item exist in cart

    print('cart item id $id');
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

    final quantityCartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}/$_userId/$id.json?auth=$_authToken');

    final response = await http.patch(
        quantityCartUrl,
        body: json.encode({
          'quantity': quantity - 1,
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
                quantity: currentItem.quantity + 1,
                price: currentItem.price
            ),
        );
      }
      notifyListeners();
      throw HttpException('Could not update item quantity!');
    }

  }

  Future<void> removeItem(String id, String title, double price) async {
    _items.remove(id);
    notifyListeners();

    final deleteCartUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.cartEndPoint}/$_userId/$id.json?auth=$_authToken');
    final response = await http.delete(deleteCartUrl);

    if (response.statusCode >= 400) {
      _items.putIfAbsent(id, () => CartItem(id: id, title: title, quantity: 1, price: price));
      notifyListeners();
      throw HttpException('Could not delete this item!');
    }
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

}