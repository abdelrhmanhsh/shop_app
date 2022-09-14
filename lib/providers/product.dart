import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/utils/constants.dart';

import '../models/http_exception.dart';
import '../utils/private_constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {

    bool? favState = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final favProductsUrl = Uri.parse('${PrivateConstants.mainUrl}${Constants.userFavoritesEndPoint}/$userId/$id.json?auth=$authToken');

    final response = await http.put(
        favProductsUrl,
        body: json.encode({
          'isFavorite': !favState,
        })
    );

    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Could not add item to favorites!');
    }

    favState = null;

  }

}
