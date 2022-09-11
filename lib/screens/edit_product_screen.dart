import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  Product _product = Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  Map<String, String> _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  bool _isInit = false;

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) { // coming from edit
        final productId = ModalRoute.of(context)?.settings.arguments as String;
        _product = Provider.of<ProductsProvider>(context, listen: false)
            .findProductById(productId);
        _initValues = {
          'title': _product.title,
          'price': _product.price.toString(),
          'description': _product.description,
          'imageUrl': ''
        };
        _imageUrlController.text = _product.imageUrl;
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if(!_imageFocusNode.hasFocus) {
      if (
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https'))
          || (!_imageUrlController.text.endsWith('.png') &&
              ! _imageUrlController.text.endsWith('.svg') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))
      ) {
        return;
      }
      setState(() {});
    }
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      _formKey.currentState?.save();
      if (_product.id.isNotEmpty) { // editing
        Provider.of<ProductsProvider>(context, listen: false).updateProduct(_product.id, _product);
      } else { // new product
        Provider.of<ProductsProvider>(context, listen: false).addProduct(_product);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('edit product'),
        actions: [
          IconButton(
              onPressed: _submitForm,
              icon: const Icon(Icons.save)
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _initValues['title'],
                  decoration: const InputDecoration(
                      labelText: 'Title'
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _product = Product(
                        id: _product.id,
                        title: value ?? _product.title,
                        description: _product.description,
                        price: _product.price,
                        imageUrl: _product.imageUrl,
                        isFavorite: _product.isFavorite
                    );
                  },
                ),
                TextFormField(
                  initialValue: _initValues['price'],
                  decoration: const InputDecoration(
                      labelText: 'Price'
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter a number greater than 0.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _product = Product(
                        id: _product.id,
                        title: _product.title,
                        description: _product.description,
                        price: double.parse(value ?? _product.price.toString()),
                        imageUrl: _product.imageUrl,
                        isFavorite: _product.isFavorite
                    );
                  },
                ),
                TextFormField(
                  initialValue: _initValues['description'],
                  decoration: const InputDecoration(
                      labelText: 'Description'
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descriptionFocusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description.';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _product = Product(
                        id: _product.id,
                        title: _product.title,
                        description: value ?? _product.description,
                        price: _product.price,
                        imageUrl: _product.imageUrl,
                        isFavorite: _product.isFavorite
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 10
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey
                        )
                      ),
                      child: _imageUrlController.text.isEmpty ? const Text('Enter a Url') : FittedBox(
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Image URL'
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        focusNode: _imageFocusNode,
                        controller: _imageUrlController,
                        onEditingComplete: _submitForm,
                        onFieldSubmitted: (_) {
                          _submitForm();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an image URL.';
                          }
                          if (!value.startsWith('http') && !value.startsWith('https')) {
                            return 'Please enter a valid URL.';
                          }
                          if(!value.endsWith('.png') && ! value.endsWith('.svg') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) {
                            return 'Please enter a valid image URL.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                              id: _product.id,
                              title: _product.title,
                              description: _product.description,
                              price: _product.price,
                              imageUrl: value ?? _product.imageUrl,
                              isFavorite: _product.isFavorite
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
