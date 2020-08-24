import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class Customer {
  int _id;
  String _name;

  Customer(this._id, this._name);

  Customer.empty() : this(0, "");

  int get id => _id;

  String get name => _name;
}

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
            return ListTile(
                title: new ListTile(
              title: Text(_products[index].name),
              subtitle: (Text(_products[index].stateLog.last.toString())),
            ));
          }),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addSomethingDialog,
        backgroundColor: Colors.pinkAccent,
        child: new Icon(Icons.add),
      ),
    );
  }

  Product createDataObjectFromFormData() {
    var list = new List<ProductStateChange>();
    list.add(new ProductStateChange(ProductState.created, DateTime.now()));
    return new Product(_productNameTextController.text, list );
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
}

class Product {
  String _name;
  List<ProductStateChange> _stateLog;

  String get name => _name;

  List<ProductStateChange> get stateLog => _stateLog;

  Product(this._name, this._stateLog);
}

enum ProductState {
  created, active, notActive
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