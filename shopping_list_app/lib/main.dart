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
  final _formKey = GlobalKey<FormState>();

  _ProductWidgetState() {
    _fnameTextController = TextEditingController();
  }

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
        onPressed: _addSomethingDialog,
        backgroundColor: Colors.red,
        child: new Icon(Icons.portable_wifi_off),
      ),
    );
  }

  String createDataObjectFromFormData() {
    return _fnameTextController.text;
  }

  void clearFormData() {
    _fnameTextController.clear();
  }

  void _addSomethingDialog() async {
    String _newProduct;

    List<Widget> formWidgetList = new List();
    formWidgetList.add(createFNameWidget());
    formWidgetList.add(RaisedButton(
      onPressed: () {
        if (_formKey.currentState.validate()) {
          _products.add(createDataObjectFromFormData());
          clearFormData();
          Navigator.pop(context);
        }
      },
      child: new Text('Save'),

    ));

    formWidgetList.add(RaisedButton(
      onPressed: () {
          Navigator.pop(context);
      },
      child: new Text('Close'),

    ));

    _newProduct = await showDialog<String>(
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

  TextFormField createFNameWidget() {
    return new TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter product name.';
        }
      },
      decoration: InputDecoration(
          icon: const Icon(Icons.person),
          hintText: 'Product name',
          labelText: 'Enter product name'),
      onSaved: (String value) {},
      controller: _fnameTextController,
      autofocus: true,
    );
  }

  TextEditingController _fnameTextController;
}
