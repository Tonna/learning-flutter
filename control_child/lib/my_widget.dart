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

  Element _child;

  @override
  MyWidget get widget => super.widget as MyWidget;

  @override
  _RenderMyWidget get renderObject => super.renderObject as _RenderMyWidget;

// @override
// void mount(Element parent, dynamic newSlot) {
//   super.mount(parent, newSlot);
//   _child = updateChild(_child, widget.child, null);
//}
}

class _RenderMyWidget extends RenderCustomSingleChildLayoutBox {
  _RenderMyWidget() : super(delegate: _MySingeChildLayoutDelegate(100, true));

  @override
  void performLayout() {
    var childSize = delegate.getSize(this.constraints);

    child.layout(
        BoxConstraints.tightFor(
            width: childSize.width, height: childSize.height),
        parentUsesSize: true);
    //child.performLayout();

    size =
        constraints.constrain(Size(childSize.width * 3, childSize.height * 3));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = const Color(0xFF33CC33)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.5);
    context.canvas.drawRect(offset & size, paint);

    if (child != null) {
      final BoxParentData childParentData = child.parentData as BoxParentData;

      var childOffset = Offset(offset.dx + 10.0, offset.dy + 70.0);
      context.canvas.drawRect(
          childOffset &
              child.semanticBounds.size,
          paint);

      context.paintChild(child, childParentData.offset + childOffset);
    }
  }
}

//copypaste from _ModalBottomSheetLayout
class _MySingeChildLayoutDelegate extends SingleChildLayoutDelegate {
  _MySingeChildLayoutDelegate(this.progress, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: isScrollControlled
          ? constraints.maxHeight
          : constraints.maxHeight * 9.0 / 16.0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_MySingeChildLayoutDelegate oldDelegate) {
    return true;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // TODO: implement getSize
    return Size(100, 40);
  }
}
