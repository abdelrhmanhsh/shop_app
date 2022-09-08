import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_item.dart';

class Cart with ChangeNotifier {

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

  void addItem(String id, double price, String title) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (currentItem) => CartItem(id: currentItem.id, title: currentItem.title, quantity: currentItem.quantity + 1, price: currentItem.price),
      );
    } else {
      _items.putIfAbsent(id, () => CartItem(id: DateTime.now().toString(), title: title, quantity: 1, price: price));
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