import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/main_drawer.dart';
import '../widgets/order_list_item.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final orderData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const MainDrawer(),
      body: ListView.builder(
        itemBuilder: (context, index) => OrderListItem(orderData.orders[index]),
        itemCount: orderData.orders.length,
      ),
    );
  }
}
