import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../widgets/main_drawer.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      await Provider.of<ProductsProvider>(context, listen: false).fetchOwnerProducts();
    } catch (error) {
      await showDialog<Null>(
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
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pushNamed(EditProductScreen.routeName),
              icon: const Icon(Icons.add)
          )
        ],
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting ? const Center(
          child: CircularProgressIndicator(),
        ) : RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Consumer<ProductsProvider>(
          builder: (context, productsData, _) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemBuilder: (_, index) => Column(
                children: [
                  UserProductItem(
                    id: productsData.ownerItems[index].id,
                    title: productsData.ownerItems[index].title,
                    imageUrl: productsData.ownerItems[index].imageUrl,
                  ),
                  const Divider()
                ],
              ),
              itemCount: productsData.ownerItems.length,
            ),
          ),
        ),
      ),
      )
    );
  }
}
