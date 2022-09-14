import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/utils/custom_route.dart';

import './providers/cart.dart';
import './providers/products_provider.dart';
import './providers/auth.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/orders_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          create: (context) => ProductsProvider('', '', []),
          update: (context, auth, prevProducts) => ProductsProvider(
            auth.token,
            auth.userId,
            prevProducts?.items == null ? [] : prevProducts!.items
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (context) => Cart('', '', {}),
          update: (context, auth, prevCart) => Cart(
              auth.token,
              auth.userId,
              prevCart?.items == null ? {} : prevCart!.items
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders('', '', []),
          update: (context, auth, prevOrders) => Orders(
              auth.token,
              auth.userId,
              prevOrders?.orders == null ? [] : prevOrders!.orders
          ),
        ),
      ],
      child: Consumer<Auth> (builder: (context, auth, _) => MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          primaryColor: Colors.purple,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: Colors.purple, secondary: Colors.deepOrange),
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder()
          },)
        ),
        home: auth.isAuth ? const ProductsOverviewScreen() :
        FutureBuilder(
            future: auth.canAutoLogin(),
            builder: (context, authResultSnapshot) =>
            authResultSnapshot.connectionState == ConnectionState.waiting ? const SplashScreen() : const AuthScreen()
        ),
        routes: {
          ProductDetailScreen.routeName: (context) => const ProductDetailScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          OrdersScreen.routeName: (context) => const OrdersScreen(),
          UserProductsScreen.routeName: (context) => const UserProductsScreen(),
          EditProductScreen.routeName: (context) => const EditProductScreen(),
        },
      ),
      )
    );
  }
}
