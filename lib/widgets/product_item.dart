import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

import '../providers/auth.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {

  final String id;
  final String title;
  final String imageUrl;
  final double price;

  const ProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final product = Provider.of<Product>(context, listen: false);
    final cartProvider = Provider.of<Cart>(context, listen: false);
    final authProvider = Provider.of<Auth>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    void _addItemToCart(BuildContext context) {
      // item not in cart
      if (!cartProvider.items.containsKey(id)) {
        cartProvider.addItem(product.id, product.price, product.title);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Item added  to cart!'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () => cartProvider.removeItem(id, title, price),
              ),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item already in cart!'),
            ));
      }

    }

    Future<void> _toggleFavorite() async {
      try {
        await Provider.of<Product>(context, listen: false).toggleFavoriteStatus(authProvider.token ?? '', authProvider.userId ?? '');
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Error while adding item to favorites!'),
            ));
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border
              ),
              onPressed: _toggleFavorite,
              color: Colors.deepOrange,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _addItemToCart(context),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: product.id
          ),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
