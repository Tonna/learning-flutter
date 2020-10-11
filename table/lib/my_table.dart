import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:table/render_my_table.dart';

class MyTable extends MultiChildRenderObjectWidget {
  MyTable({Key key, this.children}) : super(key: key, children: children);

  final List<Widget> children;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMyTable(children: children, delegate: MyMultiChildLayoutDelegate());
  }
}

class MyListenable extends Listenable {
  @override
  void addListener(void Function() listener) {
    // TODO: implement addListener
  }

  @override
  void removeListener(void Function() listener) {
    // TODO: implement removeListener
  }

}

class MyMultiChildLayoutDelegate implements MultiChildLayoutDelegate{


  get _relayout => _relayout;

  @override
  Size getSize(BoxConstraints constraints) {
    // TODO: implement getSize
    throw UnimplementedError();
  }

  @override
  bool hasChild(Object childId) {
    // TODO: implement hasChild
    throw UnimplementedError();
  }

  @override
  Size layoutChild(Object childId, BoxConstraints constraints) {
    // TODO: implement layoutChild
    throw UnimplementedError();
  }

  @override
  void performLayout(Size size) {
    // TODO: implement performLayout
  }

  @override
  void positionChild(Object childId, Offset offset) {
    // TODO: implement positionChild
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    return false;
  }

}

