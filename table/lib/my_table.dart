import 'package:flutter/cupertino.dart';
import 'package:table/render_my_table.dart';

class MyTable extends MultiChildRenderObjectWidget {
  MyTable({Key key, this.children}) : super(key: key, children: children);

  final List<Widget> children;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMyTable(children);
  }
}
