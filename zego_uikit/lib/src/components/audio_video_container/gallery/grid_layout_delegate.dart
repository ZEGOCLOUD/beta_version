// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/cupertino.dart';

/// two layout mode:
/// 1. auto fill mode:
/// 2. sized mode:
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  List<GridLayoutSizedItem> sizedItems = []; //
  List<LayoutId> autoFillItems = []; //  should be init pos in time

  int columnCount;
  final Size layoutPadding;
  final Size itemPadding;
  final GridLayoutAlignment lastRowAlignment;

  List<Offset> itemsPosition = [];

  /// all items will auto fill up, layout will the SAME height as the screen
  /// so make sure you have wrap CustomMultiChildLayout with Container with height
  ///
  /// |I|
  ///  or
  /// |I I|
  /// |I I|
  ///  or
  /// |I I I|
  /// |I I I|
  /// |I I  |
  ///
  /// example:
  ///
  ///  final items = List.generate(5, (index) {
  ///    return LayoutId(
  ///      id: index,
  ///      child: Container(color: Colors.red[100 * (index % 8 + 1)]),
  ///    );
  ///  });
  ///
  ///  return SingleChildScrollView(
  ///    child: SizedBox(
  ///      //  you must wrap CustomMultiChildLayout with Container with height
  ///      height: MediaQuery.of(context).size.height,
  ///      child: CustomMultiChildLayout(
  ///        delegate: GridLayoutDelegate.autoFill(
  ///          normalItems: items,
  ///          columnCount: 3,
  ///          lastRowAlignment: GridLayoutAlignment.center,
  ///        ),
  ///      children: items,
  ///      ),
  ///    ),
  ///  );
  GridLayoutDelegate.autoFill({
    required this.autoFillItems,
    required this.columnCount,
    this.layoutPadding = const Size(2.0, 2.0),
    this.itemPadding = const Size(2.0, 2.0),
    this.lastRowAlignment = GridLayoutAlignment.start,
  }) : assert(columnCount > 0) {
    if (autoFillItems.length < columnCount) {
      columnCount = autoFillItems.length;
    }
  }

  /// all items will auto layout according to the specified width and height, and will EXCEED the screen height
  ///
  ///  I I I
  ///  I I I
  /// |I I I|
  /// |I I I|
  /// |I I I|
  ///  I I I
  ///  I I I
  ///
  /// example:
  ///
  ///  var columnCount = 3;
  ///  var screenSize = MediaQuery.of(context).size;
  ///
  ///  final items = List.generate(20, (index) {
  ///    var width = screenSize.width / columnCount - 2.0;
  ///    var height = 120.0;
  ///    return GridLayoutSizedItem(
  ///      width: width,
  ///      height: height,
  ///      id: index,
  ///      child: Container(
  ///        width: width,
  ///        height: height,
  ///        color: Colors.red[100 * (index % 8 + 1)],
  ///      ),
  ///    );
  ///  });
  ///
  ///  return SingleChildScrollView(
  ///    child: CustomMultiChildLayout(
  ///      delegate: GridLayoutDelegate.sized(
  ///        sizedItems: items,
  ///        columnCount: columnCount,
  ///        lastRowAlignment: GridLayoutAlignment.center,
  ///      ),
  ///      children: items,
  ///    ),
  ///  );
  GridLayoutDelegate.sized({
    required this.sizedItems,
    required this.columnCount,
    this.layoutPadding = const Size(2.0, 2.0),
    this.itemPadding = const Size(2.0, 2.0),
    this.lastRowAlignment = GridLayoutAlignment.start,
  }) : assert(columnCount > 0);

  @override
  Size getSize(BoxConstraints constraints) {
    double height = _initItemsPosition(constraints);
    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout(Size size) {
    for (var itemIndex = 0; itemIndex < sizedItems.length;) {
      var item = sizedItems.elementAt(itemIndex);
      var itemPos = itemsPosition.elementAt(itemIndex);
      layoutChild(item.id, BoxConstraints.tight(Size(item.width, item.height)));
      positionChild(item.id, itemPos);

      itemIndex++;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }

  /// return layout height
  double _initItemsPosition(BoxConstraints constraints) {
    convertSizedItemByAutoFill(constraints);

    itemsPosition.clear();

    double dx = layoutPadding.width;
    double dy = layoutPadding.height;
    double currentRowMaxItemHeight = 0.0;
    for (var itemIndex = 0; itemIndex < sizedItems.length;) {
      for (var columnIndex = 0; columnIndex < columnCount; columnIndex++) {
        var item = sizedItems.elementAt(itemIndex);

        itemsPosition.add(Offset(dx, dy));

        dx += item.width + itemPadding.width;
        currentRowMaxItemHeight =
            math.max(currentRowMaxItemHeight, item.height);

        itemIndex++;
        if (itemIndex == sizedItems.length) {
          break;
        }
      }

      var leftItemCount = sizedItems.length - itemIndex;
      if (leftItemCount < columnCount) {
        //  last row
        var itemsWidth = 0.0;
        sizedItems
            .getRange(itemIndex, sizedItems.length)
            .map((e) => e.width)
            .toList()
            .forEach((double itemWidth) {
          itemsWidth += itemWidth;
        });
        itemsWidth = leftItemCount * itemPadding.width + itemsWidth;
        switch (lastRowAlignment) {
          case GridLayoutAlignment.start:
            dx = layoutPadding.width;
            break;
          case GridLayoutAlignment.center:
            dx = (constraints.maxWidth - itemsWidth) / 2.0;
            break;
          case GridLayoutAlignment.end:
            dx = constraints.maxWidth - itemsWidth;
            break;
        }
      } else {
        //  new row
        dx = layoutPadding.width;
      }
      dy += currentRowMaxItemHeight + itemPadding.height;
    }

    return dy;
  }

  void convertSizedItemByAutoFill(BoxConstraints constraints) {
    if (autoFillItems.isEmpty) {
      return;
    }

    var itemWidth = (constraints.maxWidth -
            (columnCount - 1) * itemPadding.width -
            layoutPadding.width) /
        columnCount;
    var rowCount = (autoFillItems.length / columnCount).ceil();
    var itemHeight = (constraints.maxHeight -
            (rowCount - 1) * itemPadding.height -
            layoutPadding.height) /
        rowCount;

    sizedItems.clear();
    for (var item in autoFillItems) {
      sizedItems.add(
        GridLayoutSizedItem(
          id: item.id,
          child: item.child,
          width: itemWidth,
          height: itemHeight,
        ),
      );
    }
  }
}

class GridLayoutSizedItem extends LayoutId {
  final double width;
  final double height;

  GridLayoutSizedItem({
    Key? key,
    required Object id,
    required Widget child,
    required this.width,
    required this.height,
  })  : assert(width > 0),
        assert(height > 0),
        super(key: key, child: child, id: id);
}

enum GridLayoutAlignment {
  /// I I I I
  /// I I I I
  /// I I
  start,

  /// I I I I
  /// I I I I
  ///   I I
  center,

  /// I I I I
  /// I I I I
  ///     I I
  end,
}
