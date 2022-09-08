import 'package:flutter/material.dart';
import '../models/cart_item.dart';

import '../models/order_item.dart';

class Orders extends ChangeNotifier {

  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(0, OrderItem(id: DateTime.now().toString(), totalAmount: total, products: cartProducts, dateTime: DateTime.now()));
    notifyListeners();
  }

}
