// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shop_app/providers/cart.dart';
// import 'package:shop_app/widgets/product_item.dart';
//
// class CartGrid extends StatelessWidget {
//   const CartGrid({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     final cartData = Provider.of<Cart>(context);
//     final products = cartData.items;
//
//     return GridView.builder(
//         padding: const EdgeInsets.all(10.0),
//         itemCount: products.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 3 / 2,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10
//         ),
//         itemBuilder: (context, index) => ChangeNotifierProvider.value(
//             value: products[index],
//             child: ProductItem(
//                 id: products[index].id,
//                 title: products[index].title,
//                 imageUrl: products[index].imageUrl)
//         )
//     );
//   }
// }
