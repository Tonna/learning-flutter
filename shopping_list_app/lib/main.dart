import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new ProductWidget(),
    );
  }
}

class ProductWidget extends StatefulWidget {
  ProductWidget({Key key}) : super(key: key);

  @override
  _ProductWidgetState createState() => new _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  List<Product> _products = new List<Product>();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat("d MMM HH:mm");

  _ProductWidgetState() {
    _productNameTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: _addSomethingDialog,
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

  void _addSomethingDialog() async {
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
    setState(() {});
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
        return "we have enough";
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
