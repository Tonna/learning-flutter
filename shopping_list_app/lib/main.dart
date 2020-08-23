import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}

class ProductInfo {
  String _name = "";

  ProductInfo(this._name);

  ProductInfo.empty();

  String get name => name;

  @override
  String toString() {
    return 'ProductInfo{_name: $_name}';
  }
}

class HomePage extends StatefulWidget {
  List<ProductInfo> _products = new List<ProductInfo>();

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState(_products);
}

class _HomePageState extends State<HomePage> {
  List<ProductInfo> _products;

  _HomePageState(List<ProductInfo> _products) {
    this._products = _products;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Shopping List"),
        ),
        body: new Center(
            child: new ListView(children: [
          Padding(
              padding: EdgeInsets.all(20.0),
              child: ProductWidget(products: _products, onSaved: _onSaved))
        ])));
  }

  _onSaved(List<ProductInfo> products) {
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("A"),
              content: Text("B"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("B"),
                )
              ]);
        });
  }
}

class ProductWidget extends StatefulWidget {
  List<ProductInfo> _products;
  ValueChanged<List<ProductInfo>> _onSaved;

  ProductWidget(
      {Key key,
      @required List<ProductInfo> products,
      @required ValueChanged<List<ProductInfo>> onSaved})
      : super(key: key) {
    this._products = products;
    this._onSaved = onSaved;
  }

  @override
  _ProductWidgetState createState() => new _ProductWidgetState(_products);
}

class _ProductWidgetState extends State<ProductWidget> {
  List<ProductInfo> _products;

  _ProductWidgetState(final List<ProductInfo> products) {
    _products = products;
  }

  @override
  Widget build(BuildContext context) {
    _products.add(new ProductInfo("a"));
    ListView builder = ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          var g = _products[index];
          return ListTile(title: Text('${g.name}'));
        });

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Nasa Offices"),
        ),
        body: new Center(child: builder));

  }
}
