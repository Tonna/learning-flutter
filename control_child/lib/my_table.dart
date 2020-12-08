import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyTableCell {
  int layoutId;
  bool dummy = false;
  final int gridOffsetX;
  final int gridOffsetY;
  final int gridSizeX;
  final int gridSizeY;

  MyTableCell(
      {this.gridOffsetX,
      this.gridOffsetY,
      this.gridSizeX,
      this.gridSizeY});
}

class MyTable extends MultiChildRenderObjectWidget {
  final List<Widget> _children;
  final List<MyTableCell> _layout;
  final int _sizeX;
  final int _sizeY;

  List<Widget> get children => _children;

  //TODO do I create N dummy widgets to fill empty layout ? or I use single dummy one?

  //TODO pass layout structure
  //TODO do check passed children and layout?
  //TODO fill empty cells on a grid with an empty widgets
  MyTable(
      {List<Widget> children, List<MyTableCell> layout, int sizeX, int sizeY})
      : assert(children != null),
        assert(children.length == layout.length),
        _layout = addAllB(layout, sizeX, sizeY),
        _children = addAllA(children, layout, sizeX, sizeY),
        _sizeX = sizeX,
        _sizeY = sizeY;

  @override
  _MyWidgetElement createElement() {
    return _MyWidgetElement(this);
  }

  @override
  _RenderMyWidget createRenderObject(BuildContext context) {
    return _RenderMyWidget(
        delegate: _MyDelegate(
            children: _children,
            layout: _layout,
            sizeX: _sizeX,
            sizeY: _sizeY));
  }
}

addAllA(List<Widget> children, List<MyTableCell> layout, int sizeX, int sizeY) {
  List<Widget> out = [];
  for (int i = 0; i < children.length; i++) {
    out.add(LayoutId(id: i, child: children[i]));
  }

  var layoutsCells = addAllB(layout, sizeX, sizeY);
  int numberOfDummies = layoutsCells.where((element) => element.dummy).length;

  for (int i = out.length; i < numberOfDummies; i++) {
    out.add(LayoutId(id: i, child: SizedBox.shrink()));
  }

  return out;
}

List<MyTableCell> addAllB(List<MyTableCell> children, int sizeX, int sizeY) {
  List<MyTableCell> out = [];

  //fixme dirty approach but keep for now
  for (int i = 0; i < children.length; i++) {
    out.add(children[i]);
    children[i].layoutId = i;
    children[i].dummy = false;

  }

  List<MyTableCell> dummies = [];
  for (int i = 0; i < sizeX; i++) {
    for (int k = 0; k < sizeY; k++) {
      var dummy = MyTableCell(
          gridOffsetX: i,
          gridOffsetY: k,
          gridSizeX: 1,
          gridSizeY: 1);
      dummy.dummy = true;
      dummies.add(dummy);
    }
  }

  for (MyTableCell realCell in children) {
    for (int i = realCell.gridOffsetX;
        i < realCell.gridOffsetX + realCell.gridSizeX;
        i++) {
      for (int k = realCell.gridOffsetY;
          k < realCell.gridOffsetY + realCell.gridOffsetY;
          k++) {
        dummies.removeAt(i + (i * k));
      }
    }
  }

  int dummyIdCount = children.length;
  for (MyTableCell dummy in dummies) {
    dummy.layoutId = dummyIdCount++;
    out.add(dummy);
  }

  return out;
}

class _MyWidgetElement extends MultiChildRenderObjectElement {
  _MyWidgetElement(MyTable widget) : super(widget);
}

class _RenderMyWidget extends RenderCustomMultiChildLayoutBox {
  _RenderMyWidget({MultiChildLayoutDelegate delegate})
      : super(delegate: delegate);

  @override
  void performLayout() {
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.5);

    final Paint paintBlack = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.5);

    //TODO where should I get children to paint?

    //super.paint(context, offset);

    //this is defaultPaint method code
    var child = firstChild;
    while (child != null) {
      MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
      context.canvas
          .drawRect((childParentData.offset + offset) & child.size, paintBlack);
      child = childParentData.nextSibling;
    }

    context.canvas.drawRect(offset & size, paint);
  }
}

class _MyDelegate extends MultiChildLayoutDelegate {
  final List<Widget> _children;
  final List<MyTableCell> _layout;
  final int _sizeX;
  final int _sizeY;
  double _stepX;
  double _stepY;

  @override
  void performLayout(Size size) {
    _stepX = size.width / _sizeX;
    _stepY = size.height / _sizeY;

    //TODO how to get access to widget and children?
    //TODO WHy _idToChild list is empty?
    for (int i = 0; i < _children.length; i++) {
      print("id=$i");

      layoutChild(
          i,
          BoxConstraints.tightForFinite(
              width: _stepX * _layout[i].gridSizeX,
              height: _stepY * _layout[i].gridSizeY));
      positionChild(
          i,
          Offset(_layout[i].gridOffsetX * _stepX,
              _layout[i].gridOffsetY * _stepY));
    }

    // TODO: implement performLayout
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    //throw UnimplementedError();
    return true;
  }

  _MyDelegate(
      {@required List<Widget> children,
      List<MyTableCell> layout,
      int sizeX,
      int sizeY})
      : assert(children != null),
        _children = children,
        _layout = layout,
        _sizeX = sizeX,
        _sizeY = sizeY,
        super(relayout: null);
}
