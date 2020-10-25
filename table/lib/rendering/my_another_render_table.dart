import 'package:flutter/widgets.dart';

class MyAnotherRenderTable extends RenderBox {
  int _columns;
  int _rows;
  List<RenderBox> _children;

  MyAnotherRenderTable({int columns, int rows, List<RenderBox> children})
      : _columns = columns,
        _rows = rows,
        _children = children;

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final int rows = this._rows;
    final int columns = this._columns;
    size = Size(constraints.biggest.width, 30.0 * rows);
  }

  void setFlatChildren(List<RenderBox> cells) {
    assert(cells != null);

    _children = cells.toList();
  }


}
