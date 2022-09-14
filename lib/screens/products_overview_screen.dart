import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../screens/cart_screen.dart';
import '../widgets/product_grid.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/main_drawer.dart';

enum FilterOptions {
  favorites,
  all
}

class ProductsOverviewScreen extends StatefulWidget {
  static const String routeName = '/products-overview';

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {

  bool _showFavoritesOnly = false;
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        return showDialog<Null>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('An error occurred'),
              content: const Text('Something went wrong while trying to get data!'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay')
                )
              ],
            )
        );
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
      });

      Provider.of<Cart>(context).fetchCart().catchError((error) {
        print('error fetching cart items: $error');
      });

      _isInit = true;

    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              value: cart.itemCount.toString(),
              child: child ?? IconButton(
                onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
                icon: const Icon(Icons.shopping_cart),
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          PopupMenuButton(
            onSelected: (selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showFavoritesOnly = true;
                } else {
                  _showFavoritesOnly = false;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favorites,
                child: Text('Favorites'),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text('Show All'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      drawer: const Drawer(
        child: MainDrawer(),
      ),
      body: _isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : ProductGrid(_showFavoritesOnly)
    );
  }
}
