import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyWidget extends SingleChildRenderObjectWidget {
  final Widget _child;

  Widget get child => _child;

  MyWidget(Widget child)
      : assert(child != null),
        _child = child;

  @override
  _MyWidgetElement createElement() {
    return _MyWidgetElement(this);
  }

  @override
  _RenderMyWidget createRenderObject(BuildContext context) {
    return _RenderMyWidget();
  }
}

class _MyWidgetElement extends SingleChildRenderObjectElement {
  _MyWidgetElement(MyWidget widget) : super(widget);
}

class _RenderMyWidget extends RenderShiftedBox {
  _RenderMyWidget() : super(null);

  @override
  void performLayout() {
    var maxSize = Size(
        constraints.biggest.width - 10,
        constraints.biggest.height == double.infinity
            ? 500
            : constraints.biggest.height - 10);

    var childSize =
        Size(maxSize.width / rand(3, 5), maxSize.height / rand(3, 5));
    child.layout(
        BoxConstraints.tightFor(
            width: childSize.width, height: childSize.height),
        parentUsesSize: true);

    size = constraints.constrain(
        Size(childSize.width * rand(2, 2), childSize.height * rand(2, 2)));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.5);

    context.canvas.drawRect(offset & size, paint);

    if (child != null) {
      final BoxParentData childParentData = child.parentData as BoxParentData;

      var childOffset = Offset(
          offset.dx + rand(0, size.width.toInt() - child.size.width.toInt()),
          offset.dy + rand(0, size.height.toInt() - child.size.height.toInt()));

      context.canvas.drawRect(childOffset & child.semanticBounds.size, paint);

      context.paintChild(child, childParentData.offset + childOffset);
    }
  }

  int rand(int startFrom, int maxAdd) {
    return startFrom + Random().nextInt(maxAdd);
  }
}
