import 'package:flutter/widgets.dart';
import 'package:table/rendering/my_another_render_table.dart';

class MyAnotherTable extends RenderObjectWidget {
  final int columns;

  final int rows;

  //todo replace with Cell object
  final List<Widget> cells;

  MyAnotherTable({
    Key key,
    this.columns,
    this.rows,
    this.cells,
  });

  @override
  _MyAnotherTableElement createElement() => _MyAnotherTableElement(this);

  @override
  MyAnotherRenderTable createRenderObject(BuildContext context) {
    return MyAnotherRenderTable(columns: columns, rows: rows);
  }
}

class _MyAnotherTableElementCell {
  const _MyAnotherTableElementCell({this.key, this.element});

  final LocalKey key;
  final Element element;
}

class _MyAnotherTableElement extends RenderObjectElement {
  _MyAnotherTableElement(RenderObjectWidget widget) : super(widget);

  List<_MyAnotherTableElementCell> _children =
      const <_MyAnotherTableElementCell>[];

  @override
  MyAnotherRenderTable get renderObject =>
      super.renderObject as MyAnotherRenderTable;

  @override
  void update(MyAnotherTable newWidget) {
    final List<_MyAnotherTableElementCell> newChildren =
        <_MyAnotherTableElementCell>[];
    for (final Widget cell in newWidget.cells) {
      newChildren.add(_MyAnotherTableElementCell(
          //todo wat are those keys?
          key: cell.key,
          //what is this updateChild method?
          element: updateChild(null, cell, null)));
    }
  }

  void _updateRenderObjectChildren() {
    assert(renderObject != null);
    renderObject.setFlatChildren(
        _children.map<RenderBox>((_MyAnotherTableElementCell elementCell) {
      final RenderBox box = elementCell.element.renderObject as RenderBox;
      return box;
    }));
  }
}
