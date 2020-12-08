import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyTableCell {
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

  MyTable(
      {List<Widget> children, List<MyTableCell> layout, int sizeX, int sizeY})
      : assert(children != null),
        _children = addAll(children),
        _layout = layout,
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

addAll(List<Widget> children) {
  List<Widget> out = [];
  for (int i = 0; i < children.length; i++) {
    out.add(LayoutId(id: i, child: children[i]));
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
  Size getSize(BoxConstraints constraints) {
    return Size(300, 300);
  }

  @override
  void performLayout() {
    size = Size(200, 200);
    super.performLayout();
//    delegate.performLayout(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.5);

    context.canvas.drawRect(offset & size, paint);

    //TODO where should I get children to paint?

    //super.paint(context, offset);

    //this is defaultPaint method code
    var child = firstChild;
    while (child != null) {
      MultiChildLayoutParentData childParentData =
      child.parentData as MultiChildLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
      context.canvas
          .drawRect((childParentData.offset + offset) & child.size, paint);
      child = childParentData.nextSibling;
    }
  }
}

class _MyDelegate extends MultiChildLayoutDelegate {
  final List<Widget> _children;
  final List<MyTableCell> _layout;
  final int _sizeX;
  final int _sizeY;
  final double _stepX = 50.0;
  final double _stepY = 50.0;

  @override
  void performLayout(Size size) {
    //TODO how to get access to widget and children?
    //TODO WHy _idToChild list is empty?
    for (int i = 0; i < _children.length; i++) {
      print("id=$i");

      layoutChild(
          i, BoxConstraints.tightForFinite(width: _stepX, height: _stepY));
      positionChild(i, Offset(i * _stepX, i * _stepY));
    }

    // TODO: implement performLayout
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    //throw UnimplementedError();
    return true;
  }

  _MyDelegate({@required List<Widget> children,
    List<MyTableCell> layout,
    int sizeX,
    int sizeY})
      :
        assert(children != null),
        _children = children,
        _layout = layout,
        _sizeX = sizeX,
        _sizeY = sizeY,
        super(relayout: null);
}
