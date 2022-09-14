import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

import '../utils/constants.dart';
import '../utils/private_constants.dart';

class Auth with ChangeNotifier {

  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null) {
      if ( _expiryDate!.isAfter(DateTime.now()) && _token != null) {
        return _token!;
      }
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String endPoint) async {

    final authUrl = Uri.parse('${Constants.authUrl}$endPoint${PrivateConstants.apiKey}');

    try {

      final response = await http.post(
          authUrl,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          })
      );

      final responseData = json.decode(response.body);
      // status code 200 with error
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String()
      });
      prefs.setString('userPrefs', userData);

    } catch (error) {
      rethrow;
    }

  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, Constants.signupEndPoint);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, Constants.loginEndPoint);
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userPrefs');

  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    if (timeToExpiry != null) {
      _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
  }

  Future<bool> canAutoLogin() async {

    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userPrefs')) {
      return false;
    }

    if (prefs.getString('userPrefs') != null) {

      final userData = json.decode(prefs.getString('userPrefs')!) as Map<String, dynamic>;
      final expiryDate = DateTime.parse(userData['expiryDate']);

      // token expired
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }

      _token = userData['token'] as String;
      _userId = userData['userId'] as String;
      _expiryDate = expiryDate;

      notifyListeners();
      _autoLogout();
    }

    return true;
  }

}