import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'read_compat.dart';
import 'read_controller.dart';
import 'read_page_position.dart';
import 'read_scroll_controller.dart';

class ReadPageView extends StatefulWidget {
  final ReadPageController? pageController;
  final NullableIndexedWidgetBuilder itemBuilder;
  final ScrollType scrollType;
  final VoidCallback? onScrollCallback;
  final IndexCallback? onPageIndexChanged;
  final GestureTapCallback? onVerticalDrag;

  const ReadPageView({
    super.key,
    this.pageController,
    required this.itemBuilder,
    required this.scrollType,
    this.onScrollCallback,
    this.onPageIndexChanged,
    this.onVerticalDrag,
  });

  @override
  State<StatefulWidget> createState() => _ReadPageViewState();
}

class _ReadPageViewState extends State<ReadPageView>
    with TickerProviderStateMixin
    implements ScrollContext {
  final ScrollPhysics physics = const ReadScrollPhysics();
  Map<Type, GestureRecognizerFactory> _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};
  final GlobalKey<RawGestureDetectorState> _gestureDetectorKey =
      GlobalKey<RawGestureDetectorState>();

  ReadPagePosition get position => _position!;
  ReadPagePosition? _position;
  bool _isVerticalDrag = false;
  bool _firstVerticalDrag = true;

  @override
  void didChangeDependencies() {
    if (ReadCompat().isDartVersionAtLeast300()) {
      dynamic mediaQueryData = MediaQuery.maybeOf(context);
      _devicePixelRatio = mediaQueryData?.devicePixelRatio ?? 1;
    } else {
      _devicePixelRatio = 1;
    }
    _updatePosition();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ReadPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePosition();
  }

  @override
  void dispose() {
    widget.pageController?.detach(position);
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Viewport(
      cacheExtent: 0.0,
      cacheExtentStyle: CacheExtentStyle.viewport,
      axisDirection: AxisDirection.right,
      offset: position,
      slivers: <Widget>[
        _FillViewportRenderObjectWidget(
          scrollType: widget.scrollType,
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return widget.itemBuilder(context, index);
            },
          ),
        ),
      ],
    );
    current = RawGestureDetector(
      key: _gestureDetectorKey,
      gestures: _gestureRecognizers,
      behavior: HitTestBehavior.opaque,
      child: current,
    );
    if (widget.pageController != null) {
      current = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            int currentIndex = widget.pageController!.page?.round() ??
                widget.pageController!.initialPage;
            widget.onPageIndexChanged?.call(currentIndex, pre: true);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (!position.isScrollingNotifier.value) {
                widget.onPageIndexChanged?.call(currentIndex);
              }
            });
          } else if (notification is ScrollStartNotification) {
            if (notification.dragDetails != null) {
              widget.onScrollCallback?.call();
            }
          }
          return false;
        },
        child: current,
      );
    }
    return current;
  }

  void _updatePosition() {
    if (_position != null) {
      widget.pageController?.detach(_position!);
    }
    _position = ReadPagePosition(
      physics: physics,
      context: this,
      initialPage: widget.pageController?.initialPage ?? 0,
      oldPosition: _position,
      onEdgeCallback: widget.pageController?.onEdgeCallback,
    );
    widget.pageController?.attach(position);
  }

  // TOUCH HANDLERS
  // 触摸事件处理
  Drag? _drag;
  ScrollHoldController? _hold;
  Offset _startPosition = Offset.zero;

  void _handleDragDown(DragDownDetails details) {
    if (!(widget.pageController?.isSafeScrolling() ?? false)) {
      _hold = position.hold(_disposeHold);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _isVerticalDrag = false;
    _firstVerticalDrag = true;
    _startPosition = details.globalPosition;
    if (!(widget.pageController?.isSafeScrolling() ?? false)) {
      _drag = position.drag(details, _disposeDrag);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    // 如果拖动活动结束并调用 _disposeDrag，则 _drag 可能为 null。
    assert(_hold == null || _drag == null);
    if (_firstVerticalDrag && widget.onVerticalDrag != null) {
      _firstVerticalDrag = false;
      Offset diff = details.globalPosition - _startPosition;
      final dx = diff.dx;
      final dy = diff.dy;
      if (dy < 0 && dy.abs() >= dx.abs() * 2.5) {
        _isVerticalDrag = true;
      }
    }
    if (!_isVerticalDrag) {
      _drag?.update(details);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isVerticalDrag) {
      widget.onVerticalDrag?.call();
    } else {
      // _drag might be null if the drag activity ended and called _disposeDrag.
      // 如果拖动活动结束并调用 _disposeDrag，则 _drag 可能为 null。
      assert(_hold == null || _drag == null);
      _drag?.end(details);
      assert(_drag == null);
    }
  }

  void _handleDragCancel() {
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    // 如果拖动开始，则 _hold 可能为 null。
    // 如果拖动活动结束并调用 _disposeDrag，则 _drag 可能为 null。
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }

  @override
  AxisDirection get axisDirection => AxisDirection.right;

  @override
  BuildContext? get notificationContext => _gestureDetectorKey.currentContext;

  @override
  void saveOffset(double offset) {}

  @override
  void setCanDrag(bool value) {
    _gestureRecognizers = <Type, GestureRecognizerFactory>{
      _SingleTouchHorizontalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
              _SingleTouchHorizontalDragGestureRecognizer>(
        () => _SingleTouchHorizontalDragGestureRecognizer(
            supportedDevices: <PointerDeviceKind>{
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
        (_SingleTouchHorizontalDragGestureRecognizer instance) {
          instance
            ..onDown = _handleDragDown
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd
            ..onCancel = _handleDragCancel;
        },
      )
    };
    _gestureDetectorKey.currentState
        ?.replaceGestureRecognizers(_gestureRecognizers);
  }

  @override
  void setIgnorePointer(bool value) {}

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {
    _gestureDetectorKey.currentState?.replaceSemanticsActions(actions);
  }

  @override
  BuildContext get storageContext => context;

  @override
  TickerProvider get vsync => this;

  double get devicePixelRatio => _devicePixelRatio;
  late double _devicePixelRatio;
}

// Single finger swipe
// 单指滑动
class _SingleTouchHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  _SingleTouchHorizontalDragGestureRecognizer({super.supportedDevices});

  bool _hasActivePointer = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!_hasActivePointer) {
      _hasActivePointer = true;
      super.addAllowedPointer(event);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _hasActivePointer = false;
    super.didStopTrackingLastPointer(pointer);
  }
}

// Overlay swipe
// 覆盖滑动
class _FillViewportRenderObjectWidget extends SliverMultiBoxAdaptorWidget {
  final ScrollType scrollType;

  const _FillViewportRenderObjectWidget({
    required this.scrollType,
    required super.delegate,
  });

  @override
  RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    if (scrollType == ScrollType.smooth) {
      return RenderSliverFillViewport(childManager: element);
    } else {
      return _ReadRenderSliverFillViewport(childManager: element);
    }
  }
}

class _ReadRenderSliverFillViewport extends RenderSliverFixedExtentBoxAdaptor {
  _ReadRenderSliverFillViewport({
    required super.childManager,
  });

  @override
  double get itemExtent => constraints.viewportMainAxisExtent;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) {
      return;
    }
    const Offset mainAxisUnit = Offset(1.0, 0.0);
    const Offset crossAxisUnit = Offset(0.0, 1.0);
    final Offset originOffset = offset;
    void draw(RenderBox child) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (child != firstChild) {
        childOffset = Offset.zero;
      }
      if (mainAxisDelta < constraints.remainingPaintExtent &&
          mainAxisDelta + paintExtentOf(child) > 0) {
        context.paintChild(child, childOffset);
      }
    }

    RenderBox child = firstChild!;
    RenderBox? next = childAfter(child);
    if (next != null) {
      draw(next);
    }
    draw(child);
  }
}
