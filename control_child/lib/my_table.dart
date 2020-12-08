import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyTable extends MultiChildRenderObjectWidget {
  final List<Widget> _children;

  List<Widget> get children => _children;

  MyTable({List<Widget> children})
      : assert(children != null),
        _children = addAll(children);

  @override
  _MyWidgetElement createElement() {
    return _MyWidgetElement(this);
  }

  @override
  _RenderMyWidget createRenderObject(BuildContext context) {
    return _RenderMyWidget(delegate: _MyDelegate(childCount: _children.length));
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
  _RenderMyWidget({MultiChildLayoutDelegate delegate}) : super(delegate: delegate);

  @override
  Size getSize(BoxConstraints constraints){
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
      MultiChildLayoutParentData childParentData = child.parentData as MultiChildLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
      context.canvas.drawRect((childParentData.offset + offset) & child.size, paint);
      child = childParentData.nextSibling;
    }

  }
}

class _MyDelegate extends MultiChildLayoutDelegate {
  final int _childCount;
  final double _step = 50.0;
  @override
  void performLayout(Size size) {
    //TODO how to get access to widget and children?
    //TODO WHy _idToChild list is empty?
    for (int i = 0; i < _childCount; i++) {
      print("id=$i");

      layoutChild(i, BoxConstraints.tightForFinite(width:_step, height: _step));
      positionChild(i, Offset(i * _step, i * _step));
    }

    // TODO: implement performLayout
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    //throw UnimplementedError();
    return true;
  }




  _MyDelegate({@required int childCount})
      : _childCount = childCount,
        super(relayout: null);
}
