import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import '../providers/auth.dart';
import './main_drawer_item.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Hello Friend!'),
          ),
          MainDrawerItem(icon: Icons.shop, label: 'Shop', handler: () => Navigator.of(context).pushReplacementNamed('/')),
          const Divider(),
          MainDrawerItem(icon: Icons.payment, label: 'Orders', handler: () => Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName)),
          const Divider(),
          MainDrawerItem(icon: Icons.edit, label: 'Manage Products', handler: () => Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName)),
          const Divider(),
          MainDrawerItem(icon: Icons.exit_to_app, label: 'Logout', handler: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context, listen: false).logout();
          })
        ],
      ),
    );
  }
}
