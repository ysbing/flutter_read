import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import '../flutter_read.dart';
import 'read_page_position.dart';

class ReadPageController with ReadScrollController {
  @override
  final int initialPage;
  @override
  final EdgeCallback? onEdgeCallback;
  final List<ReadPagePosition> _positions = <ReadPagePosition>[];
  final void Function(ReadPagePosition position)? onAttachCallback;
  final void Function(ReadPagePosition position)? onDetachCallback;
  bool _isAnimateScrolling = false;

  ReadPageController({
    this.initialPage = 0,
    this.onEdgeCallback,
    this.onAttachCallback,
    this.onDetachCallback,
  });

  @override
  ReadPagePosition get position {
    assert(_positions.isNotEmpty,
        'ScrollController not attached to any scroll views.');
    assert(_positions.length == 1,
        'ScrollController attached to multiple scroll views.');
    return _positions.single;
  }

  @override
  double? get page {
    return position.page;
  }

  @override
  bool get hasClients => _positions.isNotEmpty;

  void attach(ReadPagePosition position) {
    _positions.add(position);
    onAttachCallback?.call(position);
  }

  void detach(ReadPagePosition position) {
    _positions.remove(position);
    onDetachCallback?.call(position);
  }

  bool isSafeScrolling() {
    return position.isScrollingNotifier.value && _isAnimateScrolling;
  }

  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    if (position.cachedPage != null) {
      position.cachedPage = page.toDouble();
      return Future<void>.value();
    }
    _isAnimateScrolling = true;
    return position
        .animateTo(
          position.getPixelsFromPage(page.toDouble()),
          duration: duration,
          curve: curve,
        )
        .then((value) => _isAnimateScrolling = false);
  }

  @override
  void jumpToPage(int page) {
    if (position.cachedPage != null) {
      position.cachedPage = page.toDouble();
      return;
    }
    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }
}

class ReadListController extends ScrollController with ReadScrollController {
  @override
  final int initialPage;
  @override
  final EdgeCallback? onEdgeCallback;
  final void Function(ReadPagePosition position)? onAttachCallback;
  final void Function(ReadPagePosition position)? onDetachCallback;

  bool _isAnimateScrolling = false;
  double? cachedPage;

  ReadListController({
    this.initialPage = 0,
    this.onEdgeCallback,
    this.onAttachCallback,
    this.onDetachCallback,
  });

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return ReadPagePosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      onEdgeCallback: onEdgeCallback,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    onAttachCallback?.call(position as ReadPagePosition);
  }

  @override
  void detach(ScrollPosition position) {
    super.detach(position);
    onDetachCallback?.call(position as ReadPagePosition);
  }

  @override
  ReadPagePosition get position {
    return super.position as ReadPagePosition;
  }

  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    _isAnimateScrolling = true;
    return animateTo(
      page.toDouble() * position.viewportDimension,
      duration: duration,
      curve: curve,
    ).then((value) => _isAnimateScrolling = false);
  }

  @override
  void jumpToPage(int page) {
    jumpTo(page.toDouble() * position.viewportDimension);
  }

  @override
  double? get page {
    return !position.hasPixels || !position.hasContentDimensions
        ? null
        : cachedPage ??
            _getPageFromPixels(
                position.pixels
                    .clamp(position.minScrollExtent, position.maxScrollExtent),
                position.viewportDimension);
  }

  double _getPageFromPixels(double pixels, double viewportDimension) {
    assert(viewportDimension > 0.0);
    final double actual = math.max(0.0, pixels - 0) / viewportDimension;
    final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }
}

abstract class ReadScrollController {
  factory ReadScrollController.create({
    required ScrollType scrollType,
    int initialPage = 0,
    void Function(ReadPagePosition position)? onAttachCallback,
    void Function(ReadPagePosition position)? onDetachCallback,
    EdgeCallback? onEdgeCallback,
  }) {
    if (scrollType == ScrollType.vertical) {
      return ReadListController(
        initialPage: initialPage,
        onAttachCallback: onAttachCallback,
        onDetachCallback: onDetachCallback,
        onEdgeCallback: onEdgeCallback,
      );
    } else {
      return ReadPageController(
        initialPage: initialPage,
        onAttachCallback: onAttachCallback,
        onDetachCallback: onDetachCallback,
      );
    }
  }

  int get initialPage;

  EdgeCallback? get onEdgeCallback;

  double? get page;

  bool get hasClients;

  ReadPagePosition get position;

  void jumpToPage(int page);

  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  });
}

// Avoid excessive inertia
// 避免惯性过度
class ReadScrollPhysics extends PageScrollPhysics {
  const ReadScrollPhysics({super.parent});

  static final SpringDescription _kDefaultSpring =
      SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 60.0,
    ratio: 1.3,
  );

  @override
  ReadScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ReadScrollPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  SpringDescription get spring => _kDefaultSpring;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return _SpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = position.pixels / position.viewportDimension;
    bool isLeft = false, isRight = false;
    ScrollDirection userScrollDirection = ScrollDirection.idle;
    if (position is ReadPagePosition) {
      userScrollDirection = position.userScrollDirection;
      isLeft = position.isLeft;
      isRight = position.isRight;
    }
    if (velocity < -tolerance.velocity &&
        (userScrollDirection != ScrollDirection.reverse || !isLeft)) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity &&
        (userScrollDirection != ScrollDirection.forward)) {
      page += 0.5;
      if (isRight) {
        page -= 1e-7;
      }
    }
    return page.roundToDouble() * position.viewportDimension;
  }
}

class _SpringSimulation extends Simulation {
  _SpringSimulation(
    SpringDescription spring,
    double start,
    double end,
    double velocity, {
    super.tolerance,
  })  : _endPosition = end,
        _solution = _CriticalSolution(spring, start - end, velocity);

  final double _endPosition;
  final _CriticalSolution _solution;

  @override
  double x(double time) =>
      isDone(time) ? _endPosition : _endPosition + _solution.x(time);

  @override
  double dx(double time) => _solution.dx(time);

  @override
  bool isDone(double time) {
    return nearZero(_solution.x(time), tolerance.distance) &&
        nearZero(_solution.dx(time), tolerance.velocity);
  }
}

class _CriticalSolution {
  factory _CriticalSolution(
    SpringDescription spring,
    double distance,
    double velocity,
  ) {
    final double r = -spring.damping / (2.0 * spring.mass);
    final double c1 = distance;
    final double c2 = velocity / (r * distance);
    return _CriticalSolution.withArgs(r, c1, c2);
  }

  _CriticalSolution.withArgs(double r, double c1, double c2)
      : _r = r,
        _c1 = c1,
        _c2 = c2;

  final double _r, _c1, _c2;

  double x(double time) {
    return (_c1 + _c2 * time) * math.pow(math.e, _r * time);
  }

  double dx(double time) {
    final double power = math.pow(math.e, _r * time) as double;
    return _r * (_c1 + _c2 * time) * power + _c2 * power;
  }
}
