import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:table/my_table_painter.dart';

class RenderMyTable extends RenderCustomMultiChildLayoutBox {
  RenderMyTable({this.children, this.delegate})
      : _myTablePainter = MyTablePainter(children: children),
        super(delegate: delegate);

  final MultiChildLayoutDelegate delegate;
  final MyTablePainter _myTablePainter;

  final List<Widget> children;
}
