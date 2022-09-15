import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../utils/constants.dart';
import '../utils/private_constants.dart';

import 'product.dart';

class ProductsProvider with ChangeNotifier {

  final String? _authToken;
  final String? _userId;
  final List<Product> _items;
  final List<Product> _ownerItems = [];

  ProductsProvider(this._authToken, this._userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get ownerItems {
    return [..._ownerItems];
  }

  List<Product> get favItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findProductById(String id) {
    return items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts() async {

    _items.clear();
    var url = Uri.parse('${PrivateConstants.mainUrl}${Constants.productsEndPoint}?auth=$_authToken');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }

      url = Uri.parse('${PrivateConstants.mainUrl}${Constants.userFavoritesEndPoint}/$_userId.json?auth=$_authToken');
      final favResponse = await http.get(url);
      final favData = json.decode(favResponse.body);

      data.forEach((id, data) {
        _items.add(
            Product(
                id: id,
                title: data['title'],
                description: data['description'],
                price: data['price'],
                imageUrl: data['imageUrl'],
                isFavorite: favData == null ? false : favData[id] == null ? false : favData[id]['isFavorite']
            )
        );
      });
      notifyListeners();
    } catch(error) {
      rethrow;
    }

  }

  Future<void> fetchOwnerProducts() async {

    _ownerItems.clear();
    var ownerProductsUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.productsEndPoint}?auth=$_authToken&orderBy="ownerId"&equalTo="$_userId"');

    try {
      final response = await http.get(ownerProductsUrl);
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }

      data.forEach((id, data) {
          _ownerItems.add(
              Product(
                  id: id,
                  title: data['title'],
                  description: data['description'],
                  price: data['price'],
                  imageUrl: data['imageUrl']
              )
          );
      });

      notifyListeners();
    } catch(error) {
      rethrow;
    }

  }

  Future<void> addProduct(Product product) async {

    var productsUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.productsEndPoint}?auth=$_authToken');

    try {

      final response = await http.post(
          productsUrl,
          body: json.encode({
            'id': '',
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'ownerId': _userId
          })
      );

      final id = json.decode(response.body)['name'];

      final newProduct = Product(
          id: id,
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl
      );

      productsUrl = Uri.parse('${PrivateConstants.mainUrl}products/$id.json?auth=$_authToken');

      await http.patch(
          productsUrl,
          body: json.encode({
            'id': id,
          })
      );

      _items.add(newProduct);
      _ownerItems.add(newProduct);
      notifyListeners();

    } catch(error) {
      rethrow;
    }

  }

  Future<void> updateProduct(String id, Product product) async {
    final editProductsUrl = Uri.parse('${PrivateConstants.mainUrl}products/$id.json?auth=$_authToken');
    final productIndex = _items.indexWhere((product) => product.id == id);
    final ownerProductIndex = _ownerItems.indexWhere((product) => product.id == id);
    try {
      await http.patch(
          editProductsUrl,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl
          })
      ).then((response) {
        if (response.statusCode >= 400) {
          throw HttpException('Could not edit this item!');
        }
      });
      _items[productIndex] = product;
      _ownerItems[ownerProductIndex] = product;
      notifyListeners();

    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {

    final deleteProductsUrl = Uri.parse('${PrivateConstants.mainUrl}products/$id.json?auth=$_authToken');
    final existingProductIndex = _items.indexWhere((product) => product.id == id);
    final ownerExistingProductIndex = _ownerItems.indexWhere((product) => product.id == id);
    Product? existingProduct = _items.firstWhere((product) => product.id == id);

    _items.removeAt(existingProductIndex);
    _ownerItems.removeAt(ownerExistingProductIndex);
    notifyListeners();

    final response = await http.delete(deleteProductsUrl);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      _ownerItems.insert(ownerExistingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete this item!');
    }
    existingProduct = null;

  }

}
