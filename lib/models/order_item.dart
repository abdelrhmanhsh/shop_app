import 'cart_item.dart';

class OrderItem {
  final String id;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.totalAmount,
    required this.products,
    required this.dateTime
  });
}