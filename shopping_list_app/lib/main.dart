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
    return MaterialApp(title: 'Flutter Demo', home: ProductWidget());
  }
}

class ProductWidget extends StatefulWidget {
  ProductWidget({Key key}) : super(key: key);

  @override
  _ProductWidgetState createState() => new _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat("d MMM HH:mm");

  _ProductWidgetState() {
    _productNameTextController = TextEditingController();
  }

  _showSnackBar(BuildContext context, String content, {bool error = false}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content:
          Text('${error ? "An unexpected error occured: " : ""}${content}'),
    ));
  }

  _addProduct(BuildContext context, String name) {
    try {
      log("value add");
      DBProvider.db.addNewProduct(name).whenComplete(() => setState(() {}));
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  _addStateChange(
      BuildContext context, ProductState newState, int productId) async {
    try {
      await DBProvider.db
          .addProductStateChange(newState, productId)
          .whenComplete(() => setState(() {}));
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  Future<List<Product>> getAllProducts() async {
    return await DBProvider.db
        .loadListOfProducts()
        .then((value) => sortProducts(value));
  }

  Future<List<Product>> getActive(Future<List<Product>> allProducts) async {
    return (await allProducts)
        .where((element) => element.stateLog.last.state == ProductState.active)
        .toList();
  }

  Future<List<Product>> getNotActive(Future<List<Product>> allProducts) async {
    return (await allProducts)
        .where(
            (element) => element.stateLog.last.state == ProductState.notActive)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    log("build");

    var allProducts = getAllProducts();
    Map<String, FutureBuilder<List<Product>>> tabsWithList = {
      "all": getListViewFutureBuilder(allProducts),
      "to buy": getListViewFutureBuilder(getActive(allProducts)),
      "enough": getListViewFutureBuilder(getNotActive(allProducts))
    };

    return DefaultTabController(
        length: tabsWithList.length,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
              title: new Text("Products list"),
              bottom: TabBar(
                  isScrollable: false,
                  tabs: tabsWithList.keys.map((a) => Text(a)).toList())),
          body: TabBarView(children: [
            for (final t in tabsWithList.values) Container(child: t)
          ]),
          floatingActionButton: new FloatingActionButton(
            onPressed: () => _addProductDialog(context),
            backgroundColor: Colors.pinkAccent,
            child: new Icon(Icons.add),
          ),
        ));
  }

  FutureBuilder<List<Product>> getListViewFutureBuilder(
      Future<List<Product>> selectedProducts) {
    return FutureBuilder<List<Product>>(
        future: selectedProducts,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.requireData.length,
                itemBuilder: (context, index) {
                  var currentProduct = snapshot.requireData[index];
                  var currentProductState = currentProduct.stateLog.last.state;
                  var isActive = currentProductState == ProductState.active;
                  return Container(
                      color: isActive ? Colors.red : Colors.white,
                      child: ListTile(
                        title: Text(currentProduct.name),
                        leading: Text(
                            (snapshot.requireData.indexOf(currentProduct) + 1)
                                .toString()),
                        subtitle: (Text(getPrintableState(
                                currentProduct.stateLog.last.state) +
                            " at " +
                            _dateFormat
                                .format(currentProduct.stateLog.last.at))),
                        trailing: IconButton(
                          icon: Icon(
                              isActive ? Icons.shopping_basket : Icons.looks),
                          onPressed: () {
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
                        ),
                      ));
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  List<Product> sortProducts(List<Product> products) {
    products.sort((a, b) {
      var statusComparison =
          a.stateLog.last.state.index.compareTo(b.stateLog.last.state.index);
      if (statusComparison == 0) {
        return a.name.compareTo(b.name);
      }
      return statusComparison;
    });

    return products;
  }

  void clearFormData() {
    _productNameTextController.clear();
  }

  void _addProductDialog(BuildContext context) async {
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

    await showDialog<Product>(
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
