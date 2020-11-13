import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MyWidget extends RenderObjectWidget {
  final Widget _child;

  MyWidget(Widget child)
      : assert(child != null),
        _child = child;

  @override
  _MyWidgetElement createElement() {
    return _MyWidgetElement(this);
  }

  @override
  _RenderMyWidget createRenderObject(BuildContext context) {
    return _RenderMyWidget(_child.createElement().renderObject);
  }
}

class _MyWidgetElement extends RenderObjectElement {
  _MyWidgetElement(MyWidget widget) : super(widget);

  @override
  MyWidget get widget => super.widget as MyWidget;

  @override
  _RenderMyWidget get renderObject => super.renderObject as _RenderMyWidget;

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
  }
}

class _RenderMyWidget extends RenderShiftedBox {
  _RenderMyWidget(RenderBox child) : super(child);

  // @override
  // void debugAssertDoesMeetConstraints() {
  //   // TODO: implement debugAssertDoesMeetConstraints
  // }

  // @override
  // // TODO: implement paintBounds
  // Rect get paintBounds => throw UnimplementedError();

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    size = constraints.constrain(Size(100, 100));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child.parentData as BoxParentData;
      context.paintChild(child, childParentData.offset + offset);
    }
  }

// @override
// void performResize() {
//   // TODO: implement performResize
// }
//
// @override
// // TODO: implement semanticBounds
// Rect get semanticBounds => throw UnimplementedError();

}
