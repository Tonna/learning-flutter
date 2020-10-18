// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:table/rendering/my_table.dart';
import 'package:table/rendering/my_table_border.dart';

import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/debug.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/image.dart';

export 'package:flutter/rendering.dart' show
FixedColumnWidth,
FlexColumnWidth,
FractionColumnWidth,
IntrinsicColumnWidth,
MaxColumnWidth,
MinColumnWidth,
TableBorder,
TableCellVerticalAlignment,
TableColumnWidth;

/// A horizontal group of cells in a [Table].
///
/// Every row in a table must have the same number of children.
///
/// The alignment of individual cells in a row can be controlled using a
/// [TableCell].
@immutable
class MyTableRow {
  /// Creates a row in a [Table].
  const MyTableRow({ this.key, this.decoration, this.children });

  /// An identifier for the row.
  final LocalKey key;

  /// A decoration to paint behind this row.
  ///
  /// Row decorations fill the horizontal and vertical extent of each row in
  /// the table, unlike decorations for individual cells, which might not fill
  /// either.
  final Decoration decoration;

  /// The widgets that comprise the cells in this row.
  ///
  /// Children may be wrapped in [TableCell] widgets to provide per-cell
  /// configuration to the [Table], but children are not required to be wrapped
  /// in [TableCell] widgets.
  final List<Widget> children;

  @override
  String toString() {
    final StringBuffer result = StringBuffer();
    result.write('TableRow(');
    if (key != null)
      result.write('$key, ');
    if (decoration != null)
      result.write('$decoration, ');
    if (children == null) {
      result.write('child list is null');
    } else if (children.isEmpty) {
      result.write('no children');
    } else {
      result.write('$children');
    }
    result.write(')');
    return result.toString();
  }
}

class _MyTableElementRow {
  const _MyTableElementRow({ this.key, this.children });
  final LocalKey key;
  final List<Element> children;
}

/// A widget that uses the table layout algorithm for its children.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=_lbE0wsVZSw}
///
/// If you only have one row, the [Row] widget is more appropriate. If you only
/// have one column, the [SliverList] or [Column] widgets will be more
/// appropriate.
///
/// Rows size vertically based on their contents. To control the individual
/// column widths, use the [columnWidths] property to specify a
/// [TableColumnWidth] for each column. If [columnWidths] is null, or there is a
/// null entry for a given column in [columnWidths], the table uses the
/// [defaultColumnWidth] instead.
///
/// By default, [defaultColumnWidth] is a [FlexColumnWidth]. This
/// [TableColumnWidth] divides up the remaining space in the horizontal axis to
/// determine the column width. If wrapping a [Table] in a horizontal
/// [ScrollView], choose a different [TableColumnWidth], such as
/// [FixedColumnWidth].
///
/// For more details about the table layout algorithm, see [RenderTable].
/// To control the alignment of children, see [TableCell].
///
/// See also:
///
///  * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
class MyTable extends RenderObjectWidget {
  /// Creates a table.
  ///
  /// The [children], [defaultColumnWidth], and [defaultVerticalAlignment]
  /// arguments must not be null.
  MyTable({
    Key key,
    this.children = const <MyTableRow>[],
    this.columnWidths,
    this.defaultColumnWidth = const MyFlexColumnWidth(1.0),
    this.textDirection,
    this.border,
    this.defaultVerticalAlignment = MyTableCellVerticalAlignment.top,
    this.textBaseline = TextBaseline.alphabetic,
  }) : assert(children != null),
        assert(defaultColumnWidth != null),
        assert(defaultVerticalAlignment != null),
        assert(() {
          if (children.any((MyTableRow row) => row.children == null)) {
            throw FlutterError(
                'One of the rows of the table had null children.\n'
                    'The children property of TableRow must not be null.'
            );
          }
          return true;
        }()),
        assert(() {
          if (children.any((MyTableRow row) => row.children.any((Widget cell) => cell == null))) {
            throw FlutterError(
                'One of the children of one of the rows of the table was null.\n'
                    'The children of a TableRow must not be null.'
            );
          }
          return true;
        }()),
        assert(() {
          if (children.any((MyTableRow row1) => row1.key != null && children.any((MyTableRow row2) => row1 != row2 && row1.key == row2.key))) {
            throw FlutterError(
                'Two or more TableRow children of this Table had the same key.\n'
                    'All the keyed TableRow children of a Table must have different Keys.'
            );
          }
          return true;
        }()),
        assert(() {
          if (children.isNotEmpty) {
            final int cellCount = children.first.children.length;
            if (children.any((MyTableRow row) => row.children.length != cellCount)) {
              throw FlutterError(
                  'Table contains irregular row lengths.\n'
                      'Every TableRow in a Table must have the same number of children, so that every cell is filled. '
                      'Otherwise, the table will contain holes.'
              );
            }
          }
          return true;
        }()),
        _rowDecorations = children.any((MyTableRow row) => row.decoration != null)
            ? children.map<Decoration>((MyTableRow row) => row.decoration).toList(growable: false)
            : null,
        super(key: key) {
    assert(() {
      final List<Widget> flatChildren = children.expand<Widget>((MyTableRow row) => row.children).toList(growable: false);
      if (debugChildrenHaveDuplicateKeys(this, flatChildren)) {
        throw FlutterError(
            'Two or more cells in this Table contain widgets with the same key.\n'
                'Every widget child of every TableRow in a Table must have different keys. The cells of a Table are '
                'flattened out for processing, so separate cells cannot have duplicate keys even if they are in '
                'different rows.'
        );
      }
      return true;
    }());
  }

  /// The rows of the table.
  ///
  /// Every row in a table must have the same number of children, and all the
  /// children must be non-null.
  final List<MyTableRow> children;

  /// How the horizontal extents of the columns of this table should be determined.
  ///
  /// If the [Map] has a null entry for a given column, the table uses the
  /// [defaultColumnWidth] instead. By default, that uses flex sizing to
  /// distribute free space equally among the columns.
  ///
  /// The [FixedColumnWidth] class can be used to specify a specific width in
  /// pixels. That is the cheapest way to size a table's columns.
  ///
  /// The layout performance of the table depends critically on which column
  /// sizing algorithms are used here. In particular, [IntrinsicColumnWidth] is
  /// quite expensive because it needs to measure each cell in the column to
  /// determine the intrinsic size of the column.
  ///
  /// The keys of this map (column indexes) are zero-based.
  ///
  /// If this is set to null, then an empty map is assumed.
  final Map<int, MyTableColumnWidth>/*?*/ columnWidths;

  /// How to determine with widths of columns that don't have an explicit sizing
  /// algorithm.
  ///
  /// Specifically, the [defaultColumnWidth] is used for column `i` if
  /// `columnWidths[i]` is null. Defaults to [FlexColumnWidth], which will
  /// divide the remaining horizontal space up evenly between columns of the
  /// same type [TableColumnWidth].
  ///
  /// A [Table] in a horizontal [ScrollView] must use a [FixedColumnWidth], or
  /// an [IntrinsicColumnWidth] as the horizontal space is infinite.
  final MyTableColumnWidth defaultColumnWidth;

  /// The direction in which the columns are ordered.
  ///
  /// Defaults to the ambient [Directionality].
  final TextDirection textDirection;

  /// The style to use when painting the boundary and interior divisions of the table.
  final MyTableBorder border;

  /// How cells that do not explicitly specify a vertical alignment are aligned vertically.
  ///
  /// Cells may specify a vertical alignment by wrapping their contents in a
  /// [TableCell] widget.
  final MyTableCellVerticalAlignment defaultVerticalAlignment;

  /// The text baseline to use when aligning rows using [TableCellVerticalAlignment.baseline].
  ///
  /// Defaults to [TextBaseline.alphabetic].
  final TextBaseline textBaseline;

  final List<Decoration> _rowDecorations;

  @override
  _MyTableElement createElement() => _MyTableElement(this);

  @override
  MyRenderTable createRenderObject(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    return MyRenderTable(
      columns: children.isNotEmpty ? children[0].children.length : 0,
      rows: children.length,
      columnWidths: columnWidths,
      defaultColumnWidth: defaultColumnWidth,
      textDirection: textDirection ?? Directionality.of(context),
      border: border,
      rowDecorations: _rowDecorations,
      configuration: createLocalImageConfiguration(context),
      defaultVerticalAlignment: defaultVerticalAlignment,
      textBaseline: textBaseline,
    );
  }

  @override
  void updateRenderObject(BuildContext context, MyRenderTable renderObject) {
    assert(debugCheckHasDirectionality(context));
    assert(renderObject.columns == (children.isNotEmpty ? children[0].children.length : 0));
    assert(renderObject.rows == children.length);
    renderObject
      ..columnWidths = columnWidths
      ..defaultColumnWidth = defaultColumnWidth
      ..textDirection = textDirection ?? Directionality.of(context)
      ..border = border
      ..rowDecorations = _rowDecorations
      ..configuration = createLocalImageConfiguration(context)
      ..defaultVerticalAlignment = defaultVerticalAlignment
      ..textBaseline = textBaseline;
  }
}

class _MyTableElement extends RenderObjectElement {
  _MyTableElement(MyTable widget) : super(widget);

  @override
  MyTable get widget => super.widget as MyTable;

  @override
  MyRenderTable get renderObject => super.renderObject as MyRenderTable;

  // This class ignores the child's slot entirely.
  // Instead of doing incremental updates to the child list, it replaces the entire list each frame.

  List<_MyTableElementRow> _children = const<_MyTableElementRow>[];

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _children = widget.children.map<_MyTableElementRow>((MyTableRow row) {
      return _MyTableElementRow(
        key: row.key,
        children: row.children.map<Element>((Widget child) {
          assert(child != null);
          return inflateWidget(child, null);
        }).toList(growable: false),
      );
    }).toList(growable: false);
    _updateRenderObjectChildren();
  }

  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element> slot) {
    renderObject.setupParentData(child);
  }

  @override
  void moveRenderObjectChild(RenderObject child, IndexedSlot<Element> oldSlot, IndexedSlot<Element> newSlot) {
  }

  @override
  void removeRenderObjectChild(RenderObject child, IndexedSlot<Element> slot) {
    final TableCellParentData childParentData = child.parentData as TableCellParentData;
    renderObject.setChild(childParentData.x, childParentData.y, null);
  }

  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void update(MyTable newWidget) {
    final Map<LocalKey, List<Element>> oldKeyedRows = <LocalKey, List<Element>>{};
    for (final _MyTableElementRow row in _children) {
      if (row.key != null) {
        oldKeyedRows[row.key] = row.children;
      }
    }
    final Iterator<_MyTableElementRow> oldUnkeyedRows = _children.where((_MyTableElementRow row) => row.key == null).iterator;
    final List<_MyTableElementRow> newChildren = <_MyTableElementRow>[];
    final Set<List<Element>> taken = <List<Element>>{};
    for (final MyTableRow row in newWidget.children) {
      List<Element> oldChildren;
      if (row.key != null && oldKeyedRows.containsKey(row.key)) {
        oldChildren = oldKeyedRows[row.key];
        taken.add(oldChildren);
      } else if (row.key == null && oldUnkeyedRows.moveNext()) {
        oldChildren = oldUnkeyedRows.current.children;
      } else {
        oldChildren = const <Element>[];
      }
      newChildren.add(_MyTableElementRow(
        key: row.key,
        children: updateChildren(oldChildren, row.children, forgottenChildren: _forgottenChildren),
      ));
    }
    while (oldUnkeyedRows.moveNext())
      updateChildren(oldUnkeyedRows.current.children, const <Widget>[], forgottenChildren: _forgottenChildren);
    for (final List<Element> oldChildren in oldKeyedRows.values.where((List<Element> list) => !taken.contains(list)))
      updateChildren(oldChildren, const <Widget>[], forgottenChildren: _forgottenChildren);

    _children = newChildren;
    _updateRenderObjectChildren();
    _forgottenChildren.clear();
    super.update(newWidget);
    assert(widget == newWidget);
  }

  void _updateRenderObjectChildren() {
    assert(renderObject != null);
    renderObject.setFlatChildren(
      _children.isNotEmpty ? _children[0].children.length : 0,
      _children.expand<RenderBox>((_MyTableElementRow row) {
        return row.children.map<RenderBox>((Element child) {
          final RenderBox box = child.renderObject as RenderBox;
          return box;
        });
      }).toList(),
    );
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children.expand<Element>((_MyTableElementRow row) => row.children)) {
      if (!_forgottenChildren.contains(child))
        visitor(child);
    }
  }

  @override
  bool forgetChild(Element child) {
    _forgottenChildren.add(child);
    super.forgetChild(child);
    return true;
  }
}

/// A widget that controls how a child of a [Table] is aligned.
///
/// A [TableCell] widget must be a descendant of a [Table], and the path from
/// the [TableCell] widget to its enclosing [Table] must contain only
/// [TableRow]s, [StatelessWidget]s, or [StatefulWidget]s (not
/// other kinds of widgets, like [RenderObjectWidget]s).
class MyTableCell extends ParentDataWidget<MyTableCellParentData> {
  /// Creates a widget that controls how a child of a [Table] is aligned.
  const MyTableCell({
    Key key,
    this.verticalAlignment,
    @required Widget child,
  }) : super(key: key, child: child);

  /// How this cell is aligned vertically.
  final MyTableCellVerticalAlignment verticalAlignment;

  @override
  void applyParentData(RenderObject renderObject) {
    final MyTableCellParentData parentData = renderObject.parentData as MyTableCellParentData;
    if (parentData.verticalAlignment != verticalAlignment) {
      parentData.verticalAlignment = verticalAlignment;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject)
        targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MyTable;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<MyTableCellVerticalAlignment>('verticalAlignment', verticalAlignment));
  }
}
