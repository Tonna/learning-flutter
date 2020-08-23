import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var center = Center(
      child: Text('Hello World'),
    );
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: new HomePage(),
    );
  }
}

class GoodInfo {
  String _name = "";

  GoodInfo(this._name);

  String get name => name;

  @override
  String toString() {
    return 'GoodInfo{_name: $_name}';
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  List<GoodInfo> _goods = new List<GoodInfo>();

  @override
  _HomePageState createState() => new _HomePageState(_goods);
}

class _HomePageState extends State<HomePage> {
  List<GoodInfo> _goods;

  _HomePageState(this._goods);

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
                  child: GoodsWidget(goods: _goods, onSaved: _onSaved))
            ])));
  }

  _onSaved(List<GoodInfo> goods) {
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

class GoodsWidget extends StatefulWidget {
  List<GoodInfo> _goods;
  ValueChanged<List<GoodInfo>> _onSaved;

  GoodsWidget({Key key,
    @required List<GoodInfo> goods,
    @required ValueChanged<List<GoodInfo>> onSaved})
      : super(key: key) {
    this._goods = goods;
    this._onSaved = onSaved;
  }

  @override
  _GoodsWidgetState createState() => new _GoodsWidgetState(_goods);
}

class _GoodsWidgetState extends State<GoodsWidget> {
  List<GoodInfo> _goods;

  _GoodsWidgetState(final List<GoodInfo> goods) {
    _goods = goods;
  }

  @override
  Widget build(BuildContext context) {
    _goods.add(new GoodInfo("a"));
    ListView builder = ListView.builder(
        itemCount: _goods.length,
        itemBuilder: (context, index) {
          var g = _goods[index];
          return ListTile(
              title: Text('${g.name}')
          );
        });

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("AAA"),
        ),
        body: new Center(child: builder)
    );
  }
}

//ListView builder = ListView.builder(
//    itemCount: _nasaOffices.length,
//    itemBuilder: (context, index) {
//      print('invoking itemBuilder for row ${index}');
//      var nasaOffice = _nasaOffices[index];
//      return ListTile(
//          title: Text('${nasaOffice['Name']}'),
//          subtitle: Text('${nasaOffice['Address']}, ${nasaOffice['City']},'
//              '${nasaOffice['State']}, ${nasaOffice['ZIP']},'
//              '${nasaOffice['Country']}'),
//          trailing: Icon(Icons.arrow_right));
//    });
//return new Scaffold(
//appBar: new AppBar(
//title: new Text("Nasa Offices"),
//),
//body: new Center(child: builder));
//}










