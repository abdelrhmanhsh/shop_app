import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_list_item.dart';
import '../providers/cart.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cart = Provider.of<Cart>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const Spacer(),
                    Chip(
                        label: Text(
                          '\$${cart.totalAmount}',
                          style: TextStyle(
                            color: Theme.of(context).primaryTextTheme.headline6?.color
                          ),
                        ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          'ORDER NOW',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => CartListItem(
                    id: cart.items.values.toList()[index].id,
                    price: cart.items.values.toList()[index].price,
                    quantity: cart.items.values.toList()[index].quantity,
                    title: cart.items.values.toList()[index].title,
                  ),
                  itemCount: cart.itemCount,
                )
            )
          ],
        )
    );
  }
}
