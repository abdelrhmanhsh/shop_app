import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cart_item.dart';
import '../models/order_item.dart';
import '../utils/constants.dart';
import '../utils/private_constants.dart';

class Orders extends ChangeNotifier {

  final ordersUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.ordersEndPoint}');

  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {

    try {
      final response = await http.get(ordersUrl);
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }
      data.forEach((id, data) {
        _orders.add(
            OrderItem(
                id: id,
                totalAmount: data['totalAmount'],
                dateTime: DateTime.parse(data['dateTime']),
                products: (data['products'] as List<dynamic>).map((item) =>
                    CartItem(
                        id: item['id'],
                        title: item['title'],
                        quantity: item['quantity'],
                        price: item['price']
                    )
                ).toList()
            )
        );
      });
      _orders.reversed;
      notifyListeners();
    } catch (error) {
      rethrow;
    }

  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {

    try {

      final timestamp = DateTime.now();
      final response = await http.post(
          ordersUrl,
          body: json.encode({
            'totalAmount': total,
            'products': cartProducts.map((item) => {
              'id': item.id,
              'title': item.title,
              'quantity': item.quantity,
              'price': item.price
            }).toList(),
            'dateTime': timestamp.toIso8601String(),
          })
      );

      final newOrder = OrderItem(
          id: json.decode(response.body)['name'],
          totalAmount: total,
          products: cartProducts,
          dateTime: timestamp,
      );

      _orders.add(newOrder);
      notifyListeners();

    } catch(error) {
      rethrow;
    }

  }

}
