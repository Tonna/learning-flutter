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
  List<String> _products = new List<String>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("ZZZ"),
      ),
      body: ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return ListTile(title: new ListTile(title: Text(_products[index])));
          }),
      floatingActionButton: new FloatingActionButton(
          onPressed: _addSomething,
          backgroundColor: Colors.red,
          child: new Icon(Icons.portable_wifi_off),
      ),
    );
  }

  void _addSomething() {
    _products.add("something");
    setState(() {

    });
  }
}
