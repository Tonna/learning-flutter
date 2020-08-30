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

  final DateFormat _dateIsoFormat = DateFormat("yyyy-mm-dd HH:mm:SS.sss");

  Database get database => _database;

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
    log("db opened internal before start");
    _database = await openDatabase(
      join(_databasesPath, 'shopping_list.db'),
      onOpen: (db) {
        db.delete("product");
        db.delete("product_state_change");
        db.delete("product_product_state_change_link");

        db.execute(
            "INSERT INTO `product` (id,name) VALUES (1,'sliced cheese')");
        db.execute("INSERT INTO `product` (id,name) VALUES (2,'milk')");
        db.execute(
            "INSERT INTO `product_state_change` (id,new_state,changed_at) VALUES (1,'new','2004-01-01T02:34:56.123Z')");
        db.execute(
            "INSERT INTO `product_state_change` (id,new_state,changed_at) VALUES (2,'new','2020-04-04T10:00:00.123Z')");
        db.execute(
            "INSERT INTO `product_state_change` (id,new_state,changed_at) VALUES (3,'active','2020-04-04T12:50:00.123Z')");
        db.execute(
            "INSERT INTO `product_product_state_change_link` (product_id,product_state_change_id) VALUES (1,1)");
        db.execute(
            "INSERT INTO `product_product_state_change_link` (product_id,product_state_change_id) VALUES (2,2)");
        db.execute(
            "INSERT INTO `product_product_state_change_link` (product_id,product_state_change_id) VALUES (2,3)");
      },
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE `product` ( `id` INTEGER, `name` TEXT NOT NULL, PRIMARY KEY(`id`) )");
        db.execute(
            "CREATE TABLE `product_product_state_change_link` ( `product_id` INTEGER, `product_state_change_id` INTEGER, PRIMARY KEY(`product_id`,`product_state_change_id`))");
        db.execute(
            "CREATE TABLE `product_state_change` ( `id` INTEGER, `new_state` TEXT NOT NULL, `changed_at` TEXT NOT NULL, PRIMARY KEY(`id`) )");

        db.execute(
            "INSERT INTO `product` (id,name) VALUES (1,'sliced cheese')");
        db.execute(
            "INSERT INTO `product_state_change` (id,new_state,changed_at) VALUES (1,'new','2004-01-01T02:34:56.123Z')");
        db.execute(
            "INSERT INTO `product_product_state_change_link` (product_id,product_state_change_id) VALUES (1,1)");
      },
      version: 1,
    );
    log("db opened internal finish");
    return true;
  }

  Future<List<Product>> loadListOfProducts() async {
    log("loadList start");

    final List<Map<String, dynamic>> products =
        await _database.query("product");
    log(products);

    final List<Map<String, dynamic>> state_change =
        await _database.query("product_state_change");
    log(state_change);

    final List<Map<String, dynamic>> links =
        await _database.query("product_product_state_change_link");
    log(links);

    log("loadList ended");

    List<Map<String, dynamic>> list = await _database.rawQuery(
        "select p.id as product_id, p.name as product_name, c.id as change_state_id, c.new_state as new_state, c.changed_at as state_changed_at"
        " from product p"
        " join product_product_state_change_link l"
        " on p.id == l.product_id"
        " join product_state_change c"
        " on c.id == l.product_state_change_id");
    //TODO add order by and stuff to reduce work
    log(list);

    var listOfStateChanges = Map<int, List<ProductStateChange>>();
    var listOfProducts = Map<int, Product>();

    try {
      list.forEach((element) {
        log(element);
        if (!listOfStateChanges.containsKey(element['product_id'])) {
          listOfStateChanges[element['product_id']] =
              List<ProductStateChange>();
        }
        listOfStateChanges[element['product_id']].add(ProductStateChange(
            element['change_state_id'],
            getStateObject(element['new_state']),
            DateTime.parse(element['state_changed_at'])));
      });
      log(listOfStateChanges);

      list.forEach((element) {
        if (!listOfProducts.containsKey(element['product_id'])) {
          listOfProducts[element['product_id']] = Product(
              element['product_id'],
              element['product_name'],
              listOfStateChanges[element['product_id']]);
        }
      });

      print(listOfProducts);
    } catch (e) {
      log(e);
      throw e;
    }

    return listOfProducts.values.toList();
  }

  Future<Product> addNewProduct(String name) async {
    log(_database);
    log(name);
    //TODO extract specific values, abstract this code
    int productId = await _database
        .rawInsert("insert into product (name) values(?)", [name]);
    var productStateChange =
        await addProductStateChange(ProductState.created, productId);

    return Product(productId, name, [productStateChange]);
  }

  Future<ProductStateChange> addProductStateChange(
      ProductState state, int productId) async {
    log(_database);
    //TODO extract time creation later
    try {
      var when = DateTime.now();
      int stateChangeId = await _database.rawInsert(
          "insert into product_state_change (new_state, changed_at) values(?, ?)",
          [getStateString(state), when.toIso8601String()]);

      await _database.rawInsert(
          "insert into product_product_state_change_link (product_id, product_state_change_id) values(?, ?)",
          [productId, stateChangeId]);
      return ProductStateChange(stateChangeId, state, when);
    } catch (e) {
      log(e);
      throw e;
    }
  }

  static DbWidget of(BuildContext context) {
    var dbWidget = context.dependOnInheritedWidgetOfExactType<DbWidget>();
    log("dbWidget start");

    log(StackTrace.current);
    log("dbWidget " + dbWidget.hashCode.toString());
    log(dbWidget.database);
    log("dbWidget end");
    return dbWidget;
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

  bool _loadedDatabasePath = false;
  bool _openedDatabase = false;
  bool _listLoaded = false;

  _ProductWidgetState() {
    _productNameTextController = TextEditingController();
  }

  _showSnackBar(BuildContext context, String content, {bool error = false}) {
    log("1: $_loadedDatabasePath 2: $_openedDatabase 3: $_listLoaded database is null: ${DbWidget.of(context).database == null}");

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content:
          Text('${error ? "An unexpected error occured: " : ""}${content}'),
    ));
  }

  _loadDatabasesPath(BuildContext context) {
    try {
      var dbWidget = DbWidget.of(context);
      dbWidget.loadDatabasesPath().then((b) {
        setState(() {
          _loadedDatabasePath = b;
        });
      }).catchError((error) {
        _showSnackBar(context, error.toString(), error: true);
      });
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  _openAndInitDatabase(BuildContext context) {
    try {
      DbWidget.of(context).openAndInitDatabase().then((b) {
        setState(() {
          _openedDatabase = b;
        });
      }).catchError((error) {
        _showSnackBar(context, error.toString(), error: true);
      });
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  _loadList(BuildContext context) {
    try {
      DbWidget.of(context).loadListOfProducts().then((list) {
        _products = list;
        _listLoaded = true;
        //_addProduct(context, "test");
        sortProducts();
        setState(() {});
      }).catchError((error) {
        log("loadList catch error");
        _showSnackBar(context, error.toString(), error: true);
      });
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  _addProduct(BuildContext context, String name) {
    try {
      DbWidget.of(context).addNewProduct(name).then((product) {
        _products.add(product);
        sortProducts();
        setState(() {});
      }).catchError((error) {
        _showSnackBar(context, error.toString(), error: true);
      });
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  _addStateChange(BuildContext context, ProductState newState, int productId) {
    try {
      DbWidget.of(context).addProductStateChange(newState, productId).then((state) {
        _products.firstWhere((element) => element.id == productId).stateLog.add(state);
        sortProducts();
        setState(() {});
      }).catchError((error) {
        _showSnackBar(context, error.toString(), error: true);
      });
    } catch (e) {
      _showSnackBar(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    log("build");

    //TODO clean up state mess. use correct way to determine that database is ok to use
    if (!_loadedDatabasePath) {
      _loadDatabasesPath(context);
      log("db path loaded");
    }
    if (_loadedDatabasePath && !_openedDatabase) {
      _openAndInitDatabase(context);
      log("db opened?");
    }
    if (_loadedDatabasePath &&
        _openedDatabase &&
        DbWidget.of(context).database != null &&
        !_listLoaded) {
      _loadList(context);
      log("products loaded from db???");
      log(DbWidget.of(context).hashCode);
    }

    return new Scaffold(
      key: _scaffoldKey,
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
                        _addStateChange(context, ProductState.notActive, currentProduct.id);
                        //currentProduct.stateLog.add(ProductStateChange(
                        //    null, ProductState.notActive, DateTime.now()));
                       // sortProducts();
                      } else {
                        _addStateChange(context, ProductState.active, currentProduct.id);
//                        currentProduct.stateLog.add(ProductStateChange(
//                            null, ProductState.active, DateTime.now()));
                       // sortProducts();
                      }
                    });
                  },
                ));
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
            //_products.add(createDataObjectFromFormData());
            _addProduct(context, _productNameTextController.text);

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

class Product {
  final int _id;
  final String _name;
  final List<ProductStateChange> _stateLog;

  Product(this._id, this._name, this._stateLog);

  int get id => _id;

  String get name => _name;

  List<ProductStateChange> get stateLog => _stateLog;

  Map<String, dynamic> toMap() {
    return {'id': _id, 'name': _name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          _id == other._id &&
          _name == other._name &&
          _stateLog == other._stateLog;

  @override
  int get hashCode => _id.hashCode ^ _name.hashCode ^ _stateLog.hashCode;

  @override
  String toString() {
    return 'Product{_id: $_id, _name: $_name, _stateLog: $_stateLog}';
  }
}

enum ProductState {
  //using enum value position for sorting
  //TODO come up with better, less implicit solution
  active,
  created,
  notActive
}

class ProductStateChange {
  final int _id;
  final ProductState _state;
  final DateTime _at;

  int get id => _id;

  ProductState get state => _state;

  DateTime get at => _at;

  ProductStateChange(this._id, this._state, this._at);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductStateChange &&
          _id == other._id &&
          _state == other._state &&
          _at == other._at;

  @override
  int get hashCode => _id.hashCode ^ _state.hashCode ^ _at.hashCode;

  String toString() {
    return '{$_id, $_state, at $_at}';
  }
}

void log(Object o) {
  print(DateTime.now().toIso8601String() + " " + o.toString());
}

ProductState getStateObject(String state) {
  switch (state) {
    case "new":
      return ProductState.created;
      break;
    case "active":
      return ProductState.active;
      break;
    case "notActive":
      return ProductState.notActive;
      break;
    default:
      throw new Exception("not expected StateChange value $state");
  }
}

String getStateString(ProductState state) {
  switch (state) {
    case ProductState.created:
      return "new";
      break;
    case ProductState.active:
      return "active";
      break;
    case ProductState.notActive:
      return "notActive";
      break;
    default:
      throw new Exception("not expected StateChange value $state");
  }
}
