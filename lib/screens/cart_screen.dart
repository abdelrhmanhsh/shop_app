import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
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
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryTextTheme.headline6?.color
                          ),
                        ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    OrderButton(cart: cart)
                  ],
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => CartListItem(
                    id: cart.items.values.toList()[index].id,
                    productId: cart.items.keys.toList()[index],
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

class OrderButton extends StatefulWidget {

  final Cart cart;

  const OrderButton({
    required this.cart,
    Key? key
  }) : super(key: key);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {

  bool _isLoading = false;

  Future<void> _orderNow() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Orders>(context, listen: false).addOrder(
        widget.cart.items.values.toList(),
        widget.cart.totalAmount
    );
    setState(() {
      _isLoading = false;
    });
    widget.cart.clear();
  }

  @override
  Widget build(BuildContext context) {

    return TextButton(
        onPressed: (widget.cart.itemCount <= 0 || _isLoading) ? null : _orderNow,
        child: _isLoading ? const Center(
          child: CircularProgressIndicator(),
        ) : Text(
          'ORDER NOW',
          style: TextStyle(
              color: Theme.of(context).primaryColor
          ),
        )
    );
  }
}
