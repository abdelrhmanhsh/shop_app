import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';

import '../providers/auth.dart';

enum AuthMode {
  signup,
  login
}

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'MyShop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();

}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300)
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(
        CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeIn
        )
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0)
    ).animate(
        CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeIn
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error occurred'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay')
            )
          ],
        )
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).login(_authData['email'] as String, _authData['password'] as String);
      } else {
        await Provider.of<Auth>(context, listen: false).signup(_authData['email'] as String, _authData['password'] as String);
      }
    } on HttpException catch (error) {

      String errorMsg = 'Authentication failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMsg = 'Email address already exits.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMsg = 'You need to provide a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMsg = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMsg = 'Could not find user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMsg = 'Wrong password.';
      }

      _showErrorDialog(errorMsg);

    } catch (error) {
      String errorMsg = 'Error while authentication, try again later!';
      _showErrorDialog(errorMsg);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _animationController?.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _animationController?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.signup ? 370 : 310,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.signup ? 370 : 310),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _authData['email'] = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _authData['password'] = value;
                    }
                  },
                ),
                if (_authMode == AuthMode.signup)
                  FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signup,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.signup
                            ? (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match!';
                          }
                        }
                        : null,
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        primary: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      ),
                      child: Text(
                        _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.headline6?.color
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    child: TextButton(
                      onPressed: _switchAuthMode,
                      child: Text(
                        '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
