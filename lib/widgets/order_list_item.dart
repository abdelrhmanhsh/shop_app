import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './single_order_row.dart';
import '../models/order_item.dart';

class OrderListItem extends StatefulWidget {

  final OrderItem order;

  const OrderListItem(this.order, {Key? key}) : super(key: key);

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem> with SingleTickerProviderStateMixin{

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      height: _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.totalAmount.toStringAsFixed(2)}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded ? min(widget.order.products.length * 20.0 + 10, 180) : 0,
              child: ListView(
                children:
                  widget.order.products.map((product) => SingleOrderRow(product)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
