import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class SingleOrderRow extends StatelessWidget {

  final CartItem item;

  const SingleOrderRow(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${item.quantity}x \$${item.price}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey
              ),
            )
          ],
      ),
    );
  }
}
