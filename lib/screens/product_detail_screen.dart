import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product-detail';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findProductById(productId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
                child: Container(
                    color: Colors.black26,
                    width: 250,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5
                    ),
                    child: Text(loadedProduct.title)
                ),
              ),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            const SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedProduct.price}',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                loadedProduct.description,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ]))
        ],
      ),
    );
  }
}
