import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_app/database.dart';
import 'package:shopping_list_app/log.dart';
import 'package:shopping_list_app/model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ProductWidget());
  }
}

class ProductWidget extends StatefulWidget {
  ProductWidget({Key key}) : super(key: key);

  @override
  _ProductWidgetState createState() => new _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Product> _products = List<Product>();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat("d MMM HH:mm");
  final DateFormat _dateIsoFormat = DateFormat("yyyy-mm-dd HH:mm:SS.sss");

  _ProductWidgetState() {
    _productNameTextController = TextEditingController();
  }

  _showSnackBar(BuildContext context, String content, {bool error = false}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content:
          Text('${error ? "An unexpected error occured: " : ""}${content}'),
    ));
  }

  _addProduct(BuildContext context, String name) async {
    try {
      DBProvider.db.addNewProduct(name);
      //  _products = await DBProvider.db.loadListOfProducts();
      //  sortProducts();
      //setState(() {});
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  _addStateChange(
      BuildContext context, ProductState newState, int productId) async {
    try {
      DBProvider.db.addProductStateChange(newState, productId);
      // _products = await DBProvider.db.loadListOfProducts();

//      sortProducts();
      // setState(() {});
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  Future<List<Product>> getCurrentClients() async {
    _products = await DBProvider.db.loadListOfProducts();
    sortProducts();
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    log("build");

    getCurrentClients();

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Products list"),
      ),
      body: FutureBuilder<List<Product>>(
          future: getCurrentClients(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    var currentProduct = _products[index];
                    var currentProductState =
                        currentProduct.stateLog.last.state;
                    var isActive = currentProductState == ProductState.active;
                    return Container(
                        color: isActive ? Colors.red : Colors.white,
                        child: ListTile(
                          title: Text(currentProduct.name),
                          leading: Text((_products.indexOf(currentProduct) + 1)
                              .toString()),
                          subtitle: (Text(getPrintableState(
                                  currentProduct.stateLog.last.state) +
                              " at " +
                              _dateFormat
                                  .format(currentProduct.stateLog.last.at))),
                          trailing: Icon(
                              isActive ? Icons.shopping_basket : Icons.looks),
                          onTap: () {
                            setState(() {
                              if (isActive) {
                                _addStateChange(context, ProductState.notActive,
                                    currentProduct.id);
                              } else {
                                _addStateChange(context, ProductState.active,
                                    currentProduct.id);
                              }
                            });
                          },
                        ));
                  });
            } else {
              return Text("that sucks");
            }
          }),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _addProductDialog(context),
        backgroundColor: Colors.pinkAccent,
        child: new Icon(Icons.add),
      ),
    );
  }

  void sortProducts() {
    _products.sort((a, b) {
      var statusComparison =
          a.stateLog.last.state.index.compareTo(b.stateLog.last.state.index);
      if (statusComparison == 0) {
        return a.name.compareTo(b.name);
      }
      return statusComparison;
    });
  }

//  Product createDataObjectFromFormData() {
//    var list = new List<ProductStateChange>();
//    list.add(
//        new ProductStateChange(null, ProductState.created, DateTime.now()));
//    return new Product(null, _productNameTextController.text, list);
//  }

  void clearFormData() {
    _productNameTextController.clear();
  }

  void _addProductDialog(BuildContext context) async {
    Product _newProduct;

    List<Widget> formWidgetList = new List();
    formWidgetList.add(createProductNameWidget());
    formWidgetList
        .add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      //TODO buttons too close now
      RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _addProduct(context, _productNameTextController.text);
            setState(() => {});
            clearFormData();
            Navigator.pop(context);
          }
        },
        child: new Text('Save'),
      ),
      RaisedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: new Text('Close'),
      )
    ]));

    _newProduct = await showDialog<Product>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const Text("Enter product name"),
              children: [
                Form(
                  key: _formKey,
                  child: Column(children: formWidgetList),
                )
              ]);
        });

    if (_newProduct != null) {
      _products.add(_newProduct);
    }
    setState(() => {});
  }

  TextFormField createProductNameWidget() {
    return new TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter product name.';
        }
      },
      decoration: InputDecoration(
          icon: const Icon(Icons.short_text),
          hintText: 'Product name',
          labelText: 'Enter product name'),
      onSaved: (String value) {},
      controller: _productNameTextController,
      autofocus: true,
    );
  }

  TextEditingController _productNameTextController;

  String getPrintableState(ProductState state) {
    switch (state) {
      case ProductState.created:
        return "new";
        break;
      case ProductState.active:
        return "to buy";
        break;
      case ProductState.notActive:
        return "enough";
        break;
      default:
        return "unknown state";
    }
  }
}
