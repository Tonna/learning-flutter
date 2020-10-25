import 'package:flutter/widgets.dart';

class MyAnotherTable extends RenderObjectWidget{
  final int width;

  final int height;

  //todo replace with Cell object
  final List<Widget> cells;


  MyAnotherTable({
    Key key,
    this.width,
    this.height,
    this.cells,
});

  @override
  RenderObjectElement createElement() {
    // TODO: implement createElement
    throw UnimplementedError();
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    throw UnimplementedError();
  }
}