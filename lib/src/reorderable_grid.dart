import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef ValidateCombinationCallback = bool Function(int draggingIndex, int targetIndex);
typedef CombinationCallback = void Function(int draggedIndex, int targetIndex);

/// {@template reorderable_grid_view.reorderable_grid}
/// A scrolling container that allows the user to interactively reorder the
/// grid items.
///
/// This widget is similar to one created by [GridView.builder], and uses
/// an [IndexedWidgetBuilder] to create each item.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child such as a drag handle) with a drag listener that will recognize
/// the start of an item drag and then start the reorder by calling
/// [CombinableReorderableGridState.startItemDragReorder]. This is most easily achieved
/// by wrapping each child in a [CombinableReorderableGridDragStartListener] or a
/// [CombinableReorderableGridDelayedDragStartListener]. These will take care of recognizing
/// the start of a drag gesture and call the grid state's
/// [CombinableReorderableGridState.startItemDragReorder] method.
///
/// This widget's [CombinableReorderableGridState] can be used to manually start an item
/// reorder, or cancel a current drag. To refer to the
/// [CombinableReorderableGridState] either provide a [GlobalKey] or use the static
/// [CombinableReorderableGrid.of] method from an item's build method.
///
/// See also:
///
///  * [SliverCombinableReorderableGrid], a sliver grid that allows the user to reorder
///    its items.
/// {@endtemplate}
class CombinableReorderableGrid extends StatefulWidget {
  /// {@macro reorderable_grid_view.reorderable_grid}
  /// The [itemCount] must be greater than or equal to zero.
  const CombinableReorderableGrid({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    required this.gridDelegate,
    this.proxyDecorator,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScroll,
    this.canCombine,
    this.onCombine,
  })  : assert(itemCount >= 0),
        super(key: key);

  /// Called, as needed, to build grid item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [IndexedWidgetBuilder] index parameter indicates the item's
  /// position in the grid. The value of the index parameter will be between
  /// zero and one less than [itemCount]. All items in the grid must have a
  /// unique [Key], and should have some kind of listener to start the drag
  /// (usually a [CombinableReorderableGridDragStartListener] or
  /// [CombinableReorderableGridDelayedDragStartListener]).
  final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final int itemCount;

  /// {@macro flutter.widgets.reorderable_list.onReorder}
  final ReorderCallback onReorder;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// {@macro flutter.widgets.reorderable_list.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  final SliverGridDelegate gridDelegate;

  /// Overrides if autoscrolling is enabled. Defaults to false if `physics` is
  /// [NeverScrollableScrollPhysics]
  final bool? autoScroll;

  /// Validates if two specific indexes can be combined.
  /// When two items can be combined, the [onReorder] callback won't be called, instead [onCombine] will be.
  final ValidateCombinationCallback? canCombine;

  /// Callback when two items that [canCombine] allows are combined.
  final CombinationCallback? onCombine;

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [CombinableReorderableGrid] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [CombinableReorderableGrid] surrounds the given context, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [CombinableReorderableGrid] ancestor is found.
  static CombinableReorderableGridState of(BuildContext context) {
    final CombinableReorderableGridState? result = context.findAncestorStateOfType<CombinableReorderableGridState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('CombinableReorderableGrid.of() called with a context that does not contain a CombinableReorderableGrid.'),
          ErrorDescription(
            'No CombinableReorderableGrid ancestor could be found starting from the context that was passed to CombinableReorderableGrid.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the CombinableReorderableGrid. Please see the CombinableReorderableGrid documentation for examples '
            'of how to refer to an CombinableReorderableGridState object:\n'
            '  https://api.flutter.dev/flutter/widgets/CombinableReorderableGridState-class.html',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [CombinableReorderableGrid] item widgets that insert
  /// or remove items in response to user input.
  ///
  /// If no [CombinableReorderableGrid] surrounds the context given, then this function will
  /// return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [CombinableReorderableGrid] ancestor
  ///    is found.
  static CombinableReorderableGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<CombinableReorderableGridState>();
  }

  @override
  CombinableReorderableGridState createState() => CombinableReorderableGridState();
}

/// The state for a grid that allows the user to interactively reorder
/// the grid items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [CombinableReorderableGrid]'s state with a global key:
///
/// ```dart
/// GlobalKey<CombinableReorderableGridState> gridKey = GlobalKey<CombinableReorderableGridState>();
/// ...
/// CombinableReorderableGrid(key: gridKey, ...);
/// ...
/// gridKey.currentState.cancelReorder();
/// ```
class CombinableReorderableGridState extends State<CombinableReorderableGrid> {
  final GlobalKey<SliverCombinableReorderableGridState> _sliverCombinableReorderableGridKey = GlobalKey();

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a cancelled drag.
  /// The grid will take ownership of the returned recognizer and will dispose
  /// it when it is no longer needed.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [CombinableReorderableGridDragStartListener] or [CombinableReorderableGridDelayedDragStartListener]
  /// which call this for the application.
  void startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    _sliverCombinableReorderableGridKey.currentState!.startItemDragReorder(index: index, event: event, recognizer: recognizer);
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item grid
  /// occur so that any item drags will not get confused by
  /// changes to the underlying grid.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    _sliverCombinableReorderableGridKey.currentState!.cancelReorder();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverCombinableReorderableGrid(
            key: _sliverCombinableReorderableGridKey,
            gridDelegate: widget.gridDelegate,
            itemBuilder: widget.itemBuilder,
            itemCount: widget.itemCount,
            onReorder: widget.onReorder,
            proxyDecorator: widget.proxyDecorator,
            reverse: widget.reverse,
            autoScroll: widget.autoScroll ?? widget.physics is! NeverScrollableScrollPhysics,
            scrollDirection: widget.scrollDirection,
            canCombine: widget.canCombine,
            onCombine: widget.onCombine,
          ),
        ),
      ],
    );
  }
}

/// A sliver grid that allows the user to interactively reorder the grid items.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child) with a drag listener that will recognize the start of an item drag
/// and then start the reorder by calling
/// [SliverCombinableReorderableGridState.startItemDragReorder]. This is most easily
/// achieved by wrapping each child in a [CombinableReorderableGridDragStartListener] or
/// a [CombinableReorderableGridDelayedDragStartListener]. These will take care of
/// recognizing the start of a drag gesture and call the grid state's start
/// item drag method.
///
/// This widget's [SliverCombinableReorderableGridState] can be used to manually start an item
/// reorder, or cancel a current drag that's already underway. To refer to the
/// [SliverCombinableReorderableGridState] either provide a [GlobalKey] or use the static
/// [SliverCombinableReorderableGrid.of] method from an item's build method.
///
/// See also:
///
///  * [CombinableReorderableGrid], a regular widget grid that allows the user to reorder
///    its items.
class SliverCombinableReorderableGrid extends StatefulWidget {
  /// Creates a sliver grid that allows the user to interactively reorder its
  /// items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const SliverCombinableReorderableGrid({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    required this.gridDelegate,
    this.canCombine,
    this.onCombine,
    this.reverse = false,
    this.proxyDecorator,
    this.autoScroll = true,
    this.scrollDirection = Axis.vertical,
    this.onDragCompleted,
    this.onDragStart,
  })  : assert(itemCount >= 0),
        super(key: key);

  /// {@macro flutter.widgets.reorderable_list.itemBuilder}
  final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final int itemCount;

  /// {@macro flutter.widgets.reorderable_list.onReorder}
  final ReorderCallback onReorder;

  final VoidCallback? onDragStart;
  final VoidCallback? onDragCompleted;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  final SliverGridDelegate gridDelegate;

  /// If auto scrolling is enabled. Should be disabled if associated scroll
  /// physics are [NeverScrollableScrollPhysics]
  final bool autoScroll;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// Validates if two specific indexes can be combined.
  /// When two items can be combined, the [onReorder] callback won't be called, instead [onCombine] will be.
  final ValidateCombinationCallback? canCombine;

  /// Callback when two items that [canCombine] allows are combined.
  final CombinationCallback? onCombine;

  @override
  SliverCombinableReorderableGridState createState() => SliverCombinableReorderableGridState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverCombinableReorderableGrid] item widgets to
  /// start or cancel an item drag operation.
  ///
  /// If no [SliverCombinableReorderableGrid] surrounds the context given, this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverCombinableReorderableGrid] ancestor is found.
  static SliverCombinableReorderableGridState of(BuildContext context) {
    final SliverCombinableReorderableGridState? result = context.findAncestorStateOfType<SliverCombinableReorderableGridState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverCombinableReorderableGrid.of() called with a context that does not contain a SliverCombinableReorderableGrid.',
          ),
          ErrorDescription(
            'No SliverCombinableReorderableGrid ancestor could be found starting from the context that was passed to SliverCombinableReorderableGrid.of().',
          ),
          ErrorHint('This can happen when the context provided is from the same StatefulWidget that '
              'built the SliverCombinableReorderableGrid. Please see the SliverCombinableReorderableGrid documentation for examples'),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverCombinableReorderableGrid] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [SliverCombinableReorderableGrid] surrounds the context given, this function
  /// will return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [SliverCombinableReorderableGrid]
  ///    ancestor is found.
  static SliverCombinableReorderableGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SliverCombinableReorderableGridState>();
  }
}

/// The state for a sliver grid that allows the user to interactively reorder
/// the grid items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [SliverCombinableReorderableGrid]'s state with a global key:
///
/// ```dart
/// GlobalKey<SliverCombinableReorderableGridState> gridKey = GlobalKey<SliverCombinableReorderableGridState>();
/// ...
/// SliverCombinableReorderableGrid(key: gridKey, ...);
/// ...
/// gridKey.currentState.cancelReorder();
/// ```
///
/// [CombinableReorderableGridDragStartListener] and [CombinableReorderableGridDelayedDragStartListener]
/// refer to their [SliverCombinableReorderableGrid] with the static
/// [SliverCombinableReorderableGrid.of] method.
class SliverCombinableReorderableGridState extends State<SliverCombinableReorderableGrid> with TickerProviderStateMixin {
  // Map of index -> child state used manage where the dragging item will need
  // to be inserted.
  final Map<int, _ReorderableItemState> _items = <int, _ReorderableItemState>{};

  OverlayEntry? _overlayEntry;
  int? _dragIndex;
  _DragInfo? _dragInfo;
  int? _insertIndex;
  Offset? _finalDropPosition;
  MultiDragGestureRecognizer? _recognizer;
  bool _autoScrolling = false;

  int? _indexCombine;

  int? get indexCombine => _indexCombine;

  bool get isLogging => false;

  void _log(String s) {
    if (isLogging) {
      debugPrint(s);
      log(s);
    }
  }

  @override
  void didUpdateWidget(covariant SliverCombinableReorderableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log('SliverCombinableReorderableGridState.didUpdateWidget');
    if (widget.itemCount != oldWidget.itemCount) {
      cancelReorder();
    }
  }

  @override
  void dispose() {
    _log('SliverCombinableReorderableGridState.dispose');
    _dragInfo?.dispose();
    super.dispose();
  }

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a cancelled drag.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [CombinableReorderableGridDragStartListener] or [CombinableReorderableGridDelayedDragStartListener]
  /// which call this method when they detect the gesture that triggers a drag
  /// start.
  void startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    _log('SliverCombinableReorderableGridState.startItemDragReorder');
    assert(0 <= index && index < widget.itemCount);
    setState(() {
      if (_dragInfo != null) {
        cancelReorder();
      }
      if (_items.containsKey(index)) {
        _dragIndex = index;
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
      } else {
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item grid
  /// occur so that any item drags will not get confused by
  /// changes to the underlying grid.
  ///
  /// If a drag operation is in progress, this will immediately reset
  /// the grid to back to its pre-drag state.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    _log('SliverCombinableReorderableGridState.cancelReorder');
    _dragReset();
  }

  void _registerItem(_ReorderableItemState item) {
    // _log('SliverCombinableReorderableGridState.registerItem');
    _items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unregisterItem(int index, _ReorderableItemState item) {
    _log('SliverCombinableReorderableGridState.unregisterItem');
    final _ReorderableItemState? currentItem = _items[index];
    if (currentItem == item) {
      _items.remove(index);
    }
  }

  Drag? _dragStart(Offset position) {
    _log('SliverCombinableReorderableGridState.dragStart');
    assert(_dragInfo == null);
    widget.onDragStart?.call();

    final _ReorderableItemState item = _items[_dragIndex!]!;
    item.dragging = true;
    item.rebuild();

    _insertIndex = item.index;

    _dragInfo = _DragInfo(
      item: item,
      initialPosition: position,
      onUpdate: _dragUpdate,
      onCancel: _dragCancel,
      onEnd: _dragEnd,
      onDropCompleted: _dropCompleted,
      proxyDecorator: widget.proxyDecorator,
      tickerProvider: this,
    );
    _dragInfo!.startDrag();

    final OverlayState overlay = Overlay.of(context);
    assert(_overlayEntry == null);
    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    overlay.insert(_overlayEntry!);

    for (final _ReorderableItemState childItem in _items.values) {
      if (childItem == item || !childItem.mounted) continue;
      childItem.updateForGap(_insertIndex!, false);
    }
    return _dragInfo;
  }

  void _dragUpdate(_DragInfo item, Offset position, Offset delta) {
    _log('SliverCombinableReorderableGridState.dragUpdate');
    setState(() {
      _overlayEntry?.markNeedsBuild();
      _dragUpdateItems();
      _autoScrollIfNecessary();
    });
  }

  void _dragCancel(_DragInfo item) {
    _log('SliverCombinableReorderableGridState.dragCancel');
    _dragReset();
    widget.onDragCompleted?.call();
  }

  void _dragEnd(_DragInfo item) {
    _log('SliverCombinableReorderableGridState.dragEnd');
    setState(() => _finalDropPosition = _itemOffsetAt(_insertIndex!));
    widget.onDragCompleted?.call();
  }

  void _dropCompleted() {
    _log('SliverCombinableReorderableGridState.dropCompleted');
    final int fromIndex = _dragIndex!;
    final int toIndex = _insertIndex!;
    if (fromIndex != toIndex) {
      widget.onReorder.call(fromIndex, toIndex);
    } else if (indexCombine != null && fromIndex != indexCombine) {
      widget.onCombine?.call(fromIndex, indexCombine!);
    }
    _dragReset();
  }

  void _dragReset() {
    _log('SliverCombinableReorderableGridState.dragReset');
    setState(() {
      if (_dragInfo != null) {
        if (_dragIndex != null && _items.containsKey(_dragIndex)) {
          final _ReorderableItemState dragItem = _items[_dragIndex!]!;
          dragItem._dragging = false;
          dragItem.rebuild();
          _dragIndex = null;
        }
        _dragInfo?.dispose();
        _dragInfo = null;
        _resetItemGap();
        _recognizer?.dispose();
        _recognizer = null;
        _overlayEntry?.remove();
        _overlayEntry = null;
        _finalDropPosition = null;
        _indexCombine = null;
      }
    });
  }

  void _resetItemGap() {
    _log('SliverCombinableReorderableGridState.resetItemGap');
    for (final _ReorderableItemState item in _items.values) {
      item.resetGap();
    }
  }

  void _dragUpdateItems() {
    _log('SliverCombinableReorderableGridState.dragUpdateItems');
    assert(_dragInfo != null);

    int newIndex = _insertIndex!;

    final dragCenter = _dragInfo!.itemSize.center(_dragInfo!.dragPosition - _dragInfo!.dragOffset);

    for (final _ReorderableItemState item in _items.values) {
      if (!item.mounted) continue;

      final Rect geometry = item.targetGeometryNonOffset();

      if (geometry.contains(dragCenter)) {
        final distance = (dragCenter - geometry.center).distance;
        final factor = item.size.width / 4;

        if (distance < factor && (widget.canCombine?.call(_dragIndex!, item.index) ?? false)) {
          _indexCombine = item.index;
          newIndex = _dragIndex!;
          break;
        }

        final distanceLeftSide = (dragCenter - geometry.topLeft).distance;
        final distanceRightSide = (dragCenter - geometry.topRight).distance;
        final subtractIndex = distanceLeftSide < distanceRightSide ? 1 : 0;

        _indexCombine = null;
        newIndex = item.index - subtractIndex;
        break;
      }
    }

    if (newIndex == _insertIndex) return;
    _insertIndex = newIndex;

    for (final _ReorderableItemState item in _items.values) {
      item.updateForGap(_insertIndex!, true);
    }
  }

  Future<void> _autoScrollIfNecessary() async {
    _log('SliverCombinableReorderableGridState.autoScrollIfNecessary');
    if (_autoScrolling || _dragInfo == null || _dragInfo!.scrollable == null || widget.autoScroll == false) {
      return;
    }

    final position = _dragInfo!.scrollable!.position;
    double? newOffset;

    const duration = Duration(milliseconds: 14);
    const step = 1.0;
    const overDragMax = 20.0;
    const overDragCoef = 10;

    final isVertical = widget.scrollDirection == Axis.vertical;
    final isReversed = widget.reverse;

    /// get the scroll window position on the screen
    final scrollRenderBox = _dragInfo!.scrollable!.context.findRenderObject()! as RenderBox;
    final Offset scrollPosition = scrollRenderBox.localToGlobal(Offset.zero);

    /// calculate the start and end position for the scroll window
    double scrollWindowStart = isVertical ? scrollPosition.dy : scrollPosition.dx;
    double scrollWindowEnd = scrollWindowStart + (isVertical ? scrollRenderBox.size.height : scrollRenderBox.size.width);

    /// get the proxy (dragged) object's position on the screen
    final proxyObjectPosition = _dragInfo!.dragPosition - _dragInfo!.dragOffset;

    /// calculate the start and end position for the proxy object
    double proxyObjectStart = isVertical ? proxyObjectPosition.dy : proxyObjectPosition.dx;
    double proxyObjectEnd = proxyObjectStart + (isVertical ? _dragInfo!.itemSize.height : _dragInfo!.itemSize.width);

    if (!isReversed) {
      /// if start of proxy object is before scroll window
      if (proxyObjectStart < scrollWindowStart && position.pixels > position.minScrollExtent) {
        final overDrag = max(scrollWindowStart - proxyObjectStart, overDragMax);
        newOffset = max(position.minScrollExtent, position.pixels - step * overDrag / overDragCoef);
      }

      /// if end of proxy object is after scroll window
      else if (proxyObjectEnd > scrollWindowEnd && position.pixels < position.maxScrollExtent) {
        final overDrag = max(proxyObjectEnd - scrollWindowEnd, overDragMax);
        newOffset = min(position.maxScrollExtent, position.pixels + step * overDrag / overDragCoef);
      }
    } else {
      /// if start of proxy object is before scroll window
      if (proxyObjectStart < scrollWindowStart && position.pixels < position.maxScrollExtent) {
        final overDrag = max(scrollWindowStart - proxyObjectStart, overDragMax);
        newOffset = max(position.minScrollExtent, position.pixels + step * overDrag / overDragCoef);
      }

      /// if end of proxy object is after scroll window
      else if (proxyObjectEnd > scrollWindowEnd && position.pixels > position.minScrollExtent) {
        final overDrag = max(proxyObjectEnd - scrollWindowEnd, overDragMax);
        newOffset = min(position.maxScrollExtent, position.pixels - step * overDrag / overDragCoef);
      }
    }

    if (newOffset != null && (newOffset - position.pixels).abs() >= 1.0) {
      _autoScrolling = true;
      await position.animateTo(
        newOffset,
        duration: duration,
        curve: Curves.linear,
      );
      _autoScrolling = false;
      if (_dragInfo != null) {
        _dragUpdateItems();
        _autoScrollIfNecessary();
      }
    }
  }

  Offset _calculateNextDragOffset(int index) {
    int minPos = min(_dragIndex!, _insertIndex!);
    int maxPos = max(_dragIndex!, _insertIndex!);

    if (index < minPos || index > maxPos) return Offset.zero;

    final int direction = _insertIndex! > _dragIndex! ? -1 : 1;
    return _itemOffsetAt(index + direction) - _itemOffsetAt(index);
  }

  Offset _itemOffsetAt(int index) {
    final box = _items[index]?.context.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;

    return box.localToGlobal(Offset.zero);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (_dragInfo != null && index >= widget.itemCount) {
      return SizedBox.fromSize(size: _dragInfo!.itemSize);
    }

    final Widget child = widget.itemBuilder(context, index);
    assert(child.key != null, 'All grid items must have a key');

    final OverlayState overlay = Overlay.of(context);
    return _ReorderableItem(
      key: _ReorderableItemGlobalKey(child.key!, index, this),
      index: index,
      capturedThemes: InheritedTheme.capture(from: context, to: overlay.context),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    final SliverChildBuilderDelegate childrenDelegate = SliverChildBuilderDelegate(
      _itemBuilder,
      childCount: widget.itemCount,
    );
    return SliverGrid(
      delegate: childrenDelegate,
      gridDelegate: widget.gridDelegate,
    );
  }
}

class _ReorderableItem extends StatefulWidget {
  const _ReorderableItem({
    required Key key,
    required this.index,
    required this.child,
    required this.capturedThemes,
  }) : super(key: key);

  final int index;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _ReorderableItemState createState() => _ReorderableItemState();
}

class _ReorderableItemState extends State<_ReorderableItem> {
  late SliverCombinableReorderableGridState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  Key get key => widget.key!;
  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  @override
  void initState() {
    _listState = SliverCombinableReorderableGrid.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimation?.dispose();
    _listState._unregisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ReorderableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unregisterItem(oldWidget.index, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      return const SizedBox.shrink();
    }
    _listState._registerItem(this);
    return Transform(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _listState._unregisterItem(index, this);
    super.deactivate();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      final double animValue = Curves.easeInOut.transform(_offsetAnimation!.value);
      return Offset.lerp(_startOffset, _targetOffset, animValue)!;
    }
    return _targetOffset;
  }

  void updateForGap(int gapIndex, bool animate) {
    if (!mounted) return;

    final Offset newTargetOffset = _listState._calculateNextDragOffset(index);

    if (newTargetOffset == _targetOffset) return;
    _targetOffset = newTargetOffset;

    if (animate) {
      if (_offsetAnimation == null) {
        _offsetAnimation = AnimationController(
          vsync: _listState,
          duration: const Duration(milliseconds: 250),
        )
          ..addListener(rebuild)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _startOffset = _targetOffset;
              _offsetAnimation!.dispose();
              _offsetAnimation = null;
            }
          })
          ..forward();
      } else {
        _startOffset = offset;
        _offsetAnimation!.forward(from: 0.0);
      }
    } else {
      if (_offsetAnimation != null) {
        _offsetAnimation!.dispose();
        _offsetAnimation = null;
      }
      _startOffset = _targetOffset;
    }
    rebuild();
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  Rect targetGeometryNonOffset() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero);
    return itemPosition & itemRenderBox.size;
  }

  Size get size {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    return itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a reorderable grid.
///
/// See also:
///
///  * [CombinableReorderableGridDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [CombinableReorderableGrid], a widget grid that allows the user to reorder
///    its items.
///  * [SliverCombinableReorderableGrid], a sliver grid that allows the user to reorder
///    its items.
///  * [CombinableReorderableGridView], a material design grid that allows the user to
///    reorder its items.
class CombinableReorderableGridDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a grid item like a drag
  /// handle.
  const CombinableReorderableGridDragStartListener({
    Key? key,
    required this.child,
    required this.index,
    this.affinity,
    this.enabled = true,
  }) : super(key: key);

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a reorderable grid.
  final Widget child;

  /// The index of the associated item that will be dragged in the grid.
  final int index;

  /// Whether the [child] item can be dragged and moved in the grid.
  ///
  /// If true, the item can be moved to another location in the grid when the
  /// user taps on the child. If false, tapping on the child will be ignored.
  final bool enabled;

  /// Controls how this widget competes with other gestures to initiate a drag.
  ///
  /// If affinity is null, this widget initiates a drag as soon as it recognizes
  /// a tap down gesture, regardless of any directionality. If affinity is
  /// horizontal (or vertical), then this widget will compete with other
  /// horizontal (or vertical, respectively) gestures.
  ///
  /// For example, if this widget is placed in a vertically scrolling region and
  /// has horizontal affinity, pointer motion in the vertical direction will
  /// result in a scroll and pointer motion in the horizontal direction will
  /// result in a drag. Conversely, if the widget has a null or vertical
  /// affinity, pointer motion in any direction will result in a drag rather
  /// than in a scroll because the draggable widget, being the more specific
  /// widget, will out-compete the [Scrollable] for vertical gestures.
  ///
  /// For the directions this widget can be dragged in after the drag event
  /// starts, see [Draggable.axis].
  final Axis? affinity;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled ? (PointerDownEvent event) => _startDragging(context, event) : null,
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a reordering
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer createRecognizer() {
    switch (affinity) {
      case Axis.horizontal:
        return HorizontalMultiDragGestureRecognizer();
      case Axis.vertical:
        return VerticalMultiDragGestureRecognizer();
      case null:
        return ImmediateMultiDragGestureRecognizer();
    }
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final SliverCombinableReorderableGridState? list = SliverCombinableReorderableGrid.maybeOf(context);
    list?.startItemDragReorder(
      index: index,
      event: event,
      recognizer: createRecognizer(),
    );
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the reorderable grid.
///
/// See also:
///
///  * [CombinableReorderableGridDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [CombinableReorderableGrid], a widget grid that allows the user to reorder
///    its items.
///  * [SliverCombinableReorderableGrid], a sliver grid that allows the user to reorder
///    its items.
///  * [CombinableReorderableGridView], a material design grid that allows the user to
///    reorder its items.
class CombinableReorderableGridDelayedDragStartListener extends CombinableReorderableGridDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire grid item in a reorderable
  /// grid.
  const CombinableReorderableGridDelayedDragStartListener({
    Key? key,
    required Widget child,
    required int index,
    bool enabled = true,
    this.delay = kLongPressTimeout,
  }) : super(key: key, child: child, index: index, enabled: enabled);

  final Duration delay;

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this, delay: delay);
  }
}

typedef _DragItemUpdate = void Function(_DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

class _DragInfo extends Drag {
  _DragInfo({
    required _ReorderableItemState item,
    Offset initialPosition = Offset.zero,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    required this.tickerProvider,
  }) {
    final RenderBox itemRenderBox = item.context.findRenderObject()! as RenderBox;
    listState = item._listState;
    index = item.index;
    child = item.widget.child;
    capturedThemes = item.widget.capturedThemes;
    dragPosition = initialPosition;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
    itemSize = item.context.size!;
    scrollable = Scrollable.of(item.context);
  }

  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onEnd;
  final _DragItemCallback? onCancel;
  final VoidCallback? onDropCompleted;
  final ReorderItemProxyDecorator? proxyDecorator;
  final TickerProvider tickerProvider;

  late SliverCombinableReorderableGridState listState;
  late int index;
  late Widget child;
  late Offset dragPosition;
  late Offset dragOffset;
  late Size itemSize;
  late CapturedThemes capturedThemes;
  ScrollableState? scrollable;
  AnimationController? _proxyAnimation;

  void dispose() {
    _proxyAnimation?.dispose();
  }

  void startDrag() {
    _proxyAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 250),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _dropCompleted();
        }
      })
      ..forward();
  }

  @override
  void update(DragUpdateDetails details) {
    dragPosition += details.delta;
    onUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    _proxyAnimation!.reverse();
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onCancel?.call(this);
  }

  void _dropCompleted() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onDropCompleted?.call();
  }

  Widget createProxy(BuildContext context) {
    return capturedThemes.wrap(
      _DragItemProxy(
        listState: listState,
        index: index,
        size: itemSize,
        animation: _proxyAnimation!,
        position: dragPosition - dragOffset - _overlayOrigin(context),
        proxyDecorator: proxyDecorator,
        child: child,
      ),
    );
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay = Overlay.of(context);
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    Key? key,
    required this.listState,
    required this.index,
    required this.child,
    required this.position,
    required this.size,
    required this.animation,
    required this.proxyDecorator,
  }) : super(key: key);

  final SliverCombinableReorderableGridState listState;
  final int index;
  final Widget child;
  final Offset position;
  final Size size;
  final AnimationController animation;
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget proxyChild = proxyDecorator?.call(child, index, animation.view) ?? child;
    final Offset overlayOrigin = _overlayOrigin(context);

    return MediaQuery(
      // Remove the top padding so that any nested grid views in the item
      // won't pick up the scaffold's padding in the overlay.
      data: MediaQuery.of(context).removePadding(removeTop: true),
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          Offset effectivePosition = position;
          final Offset? dropPosition = listState._finalDropPosition;
          if (dropPosition != null) {
            effectivePosition = Offset.lerp(dropPosition - overlayOrigin, effectivePosition, Curves.easeOut.transform(animation.value))!;
          }
          return Positioned(
            left: effectivePosition.dx,
            top: effectivePosition.dy,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          );
        },
        child: proxyChild,
      ),
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableItemGlobalKey extends GlobalObjectKey {
  const _ReorderableItemGlobalKey(this.subKey, this.index, this.state) : super(subKey);

  final Key subKey;
  final int index;
  final SliverCombinableReorderableGridState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _ReorderableItemGlobalKey && other.subKey == subKey && other.index == index && other.state == state;
  }

  @override
  int get hashCode => Object.hash(subKey, index, state);
}

extension RectExt on Rect {
  double get area => height * width;
}
