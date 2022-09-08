import 'package:flutter/material.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import './main_drawer_item.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            alignment: Alignment.center,
            child: const Text(
              'Hello Friend!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20
              ),
            ),
          ),
          const Divider(),
          MainDrawerItem(icon: Icons.shop, label: 'Shop', handler: () => Navigator.of(context).pushReplacementNamed('/')),
          const Divider(),
          MainDrawerItem(icon: Icons.payment, label: 'Orders', handler: () => Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName)),
          const Divider(),
          MainDrawerItem(icon: Icons.edit, label: 'Manage Products', handler: () => Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName))
        ],
      ),
    );
  }
}
