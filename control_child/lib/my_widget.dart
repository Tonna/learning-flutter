import 'package:flutter/widgets.dart';

class MyWidget extends RenderObjectWidget {
  final Widget _child;

  MyWidget(Widget child)
      : assert(child != null),
        _child = child;

  @override
  MyWidgetElement createElement() {
    return MyWidgetElement(this);
  }

  @override
  _RenderMyWidget createRenderObject(BuildContext context) {
    return _RenderMyWidget();
  }
}

class MyWidgetElement extends RenderObjectElement {
  MyWidgetElement(MyWidget widget) : super(widget);

  @override
  MyWidget get widget => super.widget as MyWidget;

  @override
  _RenderMyWidget get renderObject => super.renderObject as _RenderMyWidget;

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
  }
}

class _RenderMyWidget extends RenderBox {
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

// @override
// void performResize() {
//   // TODO: implement performResize
// }
//
// @override
// // TODO: implement semanticBounds
// Rect get semanticBounds => throw UnimplementedError();

}
