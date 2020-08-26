import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DbWidget(
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: ProductWidget()));
  }
}

class DbWidget extends InheritedWidget {
  Database _database;
  String _databasesPath;

  DbWidget({Key key, @required Widget child})
      : assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  Future<bool> loadDatabasesPath() async {
    _databasesPath = await getDatabasesPath();
    return true;
  }

  Future<bool> openAndInitDatabase() async {
    _database = await openDatabase(
      join(_databasesPath, 'shopping_list.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE `product` ( `id` INTEGER, `name` TEXT NOT NULL, PRIMARY KEY(`id`) )");
        db.execute(
            "CREATE TABLE `product_product_state_change_link` ( `product_id` INTEGER, `product_state_change_id` INTEGER, PRIMARY KEY(`product_id`,`product_state_change_id`))");
        db.execute(
            "CREATE TABLE `product_state_change` ( `id` INTEGER, `new_state` TEXT NOT NULL, `changed_at` TEXT NOT NULL, PRIMARY KEY(`id`) )");

        db.execute(
            "INSERT INTO `product` (id,name) VALUES (1,'sliced cheese')");
        db.execute("INSERT INTO `product` (id,name) VALUES (2,'milk')");
        db.execute(
            "INSERT INTO `product_state_change` (id,new_state,changed_at) VALUES (1,'new','2004-01-01T02:34:56.123Z')");
        db.execute(
            "INSERT INTO `product_product_state_change_link` (product_id,product_state_change_id) VALUES (1,1)");
      },
      version: 1,
    );
    return true;
  }

  static DbWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DbWidget>();
  }
}

class ProductWidget extends StatefulWidget {
  ProductWidget({Key key}) : super(key: key);

  @override
  _ProductWidgetState createState() => new _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Product> _products = new List<Product>();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat("d MMM HH:mm");

  bool _loadedDatabasePath = false;

  _ProductWidgetState() {
    _productNameTextController = TextEditingController();
  }

  _showSnackBar(String content, {bool error = false}) {
    print("snackbar");
    print(content);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content:
          Text('${error ? "An unexpected errro occured: " : ""}${content}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    try {
      var dbWidget = DbWidget.of(context);
      //print(dbWidget);
      dbWidget.loadDatabasesPath().then((b) {
//        setState(() {
//          _loadedDatabasePath = true;
//        });
      }).catchError((error) {
        _showSnackBar(error.toString(), error: true);
      });
    } catch (e) {
      print("WTF?");
      print(e);
      print("end WTF?");

      _showSnackBar(e.toString(), error: true);
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Products list"),
      ),
      body: ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            var currentProduct = _products[index];
            var currentProductState = currentProduct.stateLog.last.state;
            var isActive = currentProductState == ProductState.active;
            return Container(
                color: isActive ? Colors.red : Colors.white,
                child: ListTile(
                  title: Text(currentProduct.name),
                  leading:
                      Text((_products.indexOf(currentProduct) + 1).toString()),
                  subtitle: (Text(
                      getPrintableState(currentProduct.stateLog.last.state) +
                          " at " +
                          _dateFormat.format(currentProduct.stateLog.last.at))),
                  trailing:
                      Icon(isActive ? Icons.shopping_basket : Icons.looks),
                  onTap: () {
                    setState(() {
                      if (isActive) {
                        currentProduct.stateLog.add(new ProductStateChange(
                            ProductState.notActive, DateTime.now()));
                        sortProducts();
                      } else {
                        currentProduct.stateLog.add(new ProductStateChange(
                            ProductState.active, DateTime.now()));
                        sortProducts();
                      }
                    });
                  },
                ));
          }),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _addSomethingDialog(context),
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

  Product createDataObjectFromFormData() {
    var list = new List<ProductStateChange>();
    list.add(new ProductStateChange(ProductState.created, DateTime.now()));
    return new Product(_productNameTextController.text, list);
  }

  void clearFormData() {
    _productNameTextController.clear();
  }

  void _addSomethingDialog(BuildContext context) async {
    Product _newProduct;

    List<Widget> formWidgetList = new List();
    formWidgetList.add(createProductNameWidget());
    formWidgetList
        .add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      //TODO buttons too close now
      RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _products.add(createDataObjectFromFormData());
            sortProducts();
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
      setState(() {});
    }
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

class Product {
  String _name;
  List<ProductStateChange> _stateLog;

  String get name => _name;

  List<ProductStateChange> get stateLog => _stateLog;

  Product(this._name, this._stateLog);
}

enum ProductState {
  //using enum value position for sorting
  //TODO come up with better, less implicit solution
  active,
  created,
  notActive
}

class ProductStateChange {
  final ProductState _state;
  final DateTime _at;

  ProductState get state => _state;

  DateTime get at => _at;

  ProductStateChange(this._state, this._at);

  @override
  String toString() {
    return '$_state, at $_at';
  }
}
