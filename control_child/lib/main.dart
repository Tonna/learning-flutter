import 'package:flutter/material.dart';

import 'my_table.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Opacity(
                  opacity: 1.0,
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.display1,
                  )),
              Container(
                width: 200,
                  height: 200,
                  child: MyTable(children: [
                    Text("hellow world!"),
                    Text("hello again!")
                  ], layout: [
                    MyTableCell(
                        gridOffsetX: 0,
                        gridOffsetY: 0,
                        gridSizeX: 1,
                        gridSizeY: 1),
                    MyTableCell(
                        gridOffsetX: 3,
                        gridOffsetY: 1,
                        gridSizeX: 3,
                        gridSizeY: 2)
                  ], sizeX: 8, sizeY: 8)),
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.ac_unit),
      ),
    );
  }
}
