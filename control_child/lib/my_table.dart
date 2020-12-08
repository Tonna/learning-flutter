import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyTableCell {
  int layoutId;
  final int gridOffsetX;
  final int gridOffsetY;
  final int gridSizeX;
  final int gridSizeY;

  MyTableCell(
      {this.gridOffsetX, this.gridOffsetY, this.gridSizeX, this.gridSizeY});
}

class MyTable extends MultiChildRenderObjectWidget {
  final List<Widget> _children;
  final List<MyTableCell> _layout;
  final int _sizeX;
  final int _sizeY;

  List<Widget> get children => _children;

  //TODO pass layout structure
  //TODO do check passed children and layout?
  //TODO fill empty cells on a grid with an empty widgets
  //TODO do I create N dummy widgets to fill empty layout ? or I use single dummy one?

  MyTable(
      {List<Widget> children, List<MyTableCell> layout, int sizeX, int sizeY})
      : assert(children != null),
        assert(children.length == layout.length),
        _children = addAllA(children),
        _layout = addAllB(layout),
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

addAllA(List<Widget> children) {
  List<Widget> out = [];
  for (int i = 0; i < children.length; i++) {
    out.add(LayoutId(id: i, child: children[i]));
  }
  return out;
}

addAllB(List<MyTableCell> children) {
  //fixme dirty approach but keep for now
  for (int i = 0; i < children.length; i++) {
    children[i].layoutId = i;
  }
  return children;
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
