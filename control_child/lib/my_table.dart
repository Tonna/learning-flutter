import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyTable extends MultiChildRenderObjectWidget {
  final List<Widget> _children;

  List<Widget> get children => _children;

  MyTable(List<Widget> children)
      : assert(children != null),
        _children = addAll(children);

  @override
  _MyWidgetElement createElement() {
    return _MyWidgetElement(this);
  }

  @override
  _RenderMyWidget createRenderObject(BuildContext context) {
    return _RenderMyWidget();
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
  _RenderMyWidget() : super(delegate: _MyDelegate());

  @override
  void performLayout() {
    size = Size(200, 200);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.5);

    context.canvas.drawRect(offset & size, paint);
  }
}

class _MyDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    //TODO how to get access to widget and children?

    // TODO: implement performLayout
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    //throw UnimplementedError();
    return true;
  }

  _MyDelegate() : super(relayout: null);
}
