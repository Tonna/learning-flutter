import 'package:flutter/widgets.dart';

class MyWidget extends RenderObjectWidget{

  @override
  MyWidgetElement createElement() {
    return MyWidgetElement(this);
  }

  @override
  RenderMyWidget createRenderObject(BuildContext context) {
    return RenderMyWidget();
  }

}

class MyWidgetElement extends RenderObjectElement{
  MyWidgetElement(MyWidget widget) : super(widget);

  @override
  MyWidget get widget => super.widget as MyWidget;

  @override
  RenderMyWidget get renderObject => super.renderObject as RenderMyWidget;

  @override
  void mount(Element parent, dynamic newSlot){
    super.mount(parent, newSlot);
  }
}

class RenderMyWidget extends RenderBox{
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
    size = constraints.constrain(Size(100,100));
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