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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return const Center(
                  child: Text('An error occurred!')
              );
            } else {
              return Consumer<Orders>(builder: (context, orderData, child) => ListView.builder(
                itemBuilder: (context, index) => OrderListItem(orderData.orders[index]),
                itemCount: orderData.orders.length,
              )
              );
            }
          }
        },
      ),
    );
  }
}
