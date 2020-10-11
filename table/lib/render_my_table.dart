
import 'package:flutter/cupertino.dart';
import 'package:table/my_table_painter.dart';

class RenderMyTable extends RenderBox {
  RenderMyTable(this.children)
  : _myTablePainter = MyTablePainter(children: children);

  final MyTablePainter _myTablePainter;

  final List<Widget> children;
}