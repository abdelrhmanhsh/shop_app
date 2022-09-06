import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class CartListItem extends StatelessWidget {
  // final CartItem? cartItem;

  final String id;
  final double price;
  final int quantity;
  final String title;

  const CartListItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) { // direction gives you how to handle

      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: FittedBox(
                    child: Text(
                      '\$$price',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.headline6?.color
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text('Total: ${price * quantity}'),
              trailing: Text('${quantity}x')),
        ),
      ),
    );
  }
}
