library snapping_page_scroll;

import 'package:flutter/material.dart';

class SnappingPageScroll extends StatefulWidget {
  SnappingPageScroll({
    super.key,
    required List<Widget> children,
    this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
    this.showPageIndicator = false,
    this.currentPageIndicator,
    this.otherPageIndicator,
    this.controller,
  }) : _childrenDelegate = SliverChildListDelegate(children);

  SnappingPageScroll.builder({
    super.key,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
    this.showPageIndicator = false,
    this.currentPageIndicator,
    this.otherPageIndicator,
    this.controller,
    int? itemCount,
  }) : _childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
        );

  /// Called when the page changes.
  final ValueChanged<int>? onPageChanged;

  /// The axis on which the pages is scrolled along.
  final Axis scrollDirection;

  /// Option to enable / disable page indicators.
  ///
  /// This will only work if the [pageCount] parameter is provided.
  final bool showPageIndicator;

  /// Widget to use as indicator for the page currently on screen.
  final Widget? currentPageIndicator;

  /// Widget to use as indicator for the pages that not on screen.
  final Widget? otherPageIndicator;

  /// Page controller to use if provided.
  final PageController? controller;

  final SliverChildDelegate _childrenDelegate;

  @override
  _SnappingPageScrollState createState() => _SnappingPageScrollState();
}

class _SnappingPageScrollState extends State<SnappingPageScroll> {
  PageController? _pageController;
  int? time;
  late double position;
  int _currentPage = 0;

  @override
  void initState() {
    _pageController = widget.controller ?? PageController();
    super.initState();
  }

  Widget defaultIndicator(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 30, 5, 0),
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Get pointer (finger) position.
      onPointerMove: (PointerMoveEvent pos) {
        // Runs if the time since the last scroll is undefined or over 100 milliseconds.
        if (time == null || DateTime.now().millisecondsSinceEpoch - time! > 100) {
          time = DateTime.now().millisecondsSinceEpoch;
          position = pos.position.dx;

          // The fingers x-coordinate.
        } else {
          ///Calculates scroll velocity.
          final v = (position - pos.position.dx) / (DateTime.now().millisecondsSinceEpoch - time!);

          // If the scroll velocity is to low, the widget will scroll as a PageView widget with
          // pageSnapping turned on.
          if ((v < -2 || v > 2) && !(v.isNaN || v == double.infinity || v == double.negativeInfinity)) {
            // Scrolls to a certain page based on the scroll velocity
            // The velocity coefficient (v * velocity coefficient) can be increased to scroll faster,
            // and thus further before snapping.
            _pageController!.animateToPage(_currentPage + (v * 1.2).round(),
                duration: const Duration(milliseconds: 800), curve: Curves.easeOutCubic);
          }
        }
      },
      child: Stack(
        children: <Widget>[
          PageView.custom(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });

              // onPageChanged will pass the current page to the widget if that parameter is used.
              if (widget.onPageChanged != null) {
                widget.onPageChanged!(page);
              }
            },
            // BouncingScrollPhysics can't be used since that will scroll to far because of the animation.
            physics: const ClampingScrollPhysics(),

            // Scroll direction will default to horizontal unless otherwise is specified.
            scrollDirection: widget.scrollDirection,
            childrenDelegate: widget._childrenDelegate,
          ),
          if (widget._childrenDelegate.estimatedChildCount != null && widget.showPageIndicator)
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Builds one indicator for every page.
                for (int i = 0; i < widget._childrenDelegate.estimatedChildCount!; i++)
                  i == _currentPage
                      ? (widget.currentPageIndicator ?? defaultIndicator(Colors.white))
                      : (widget.otherPageIndicator ?? defaultIndicator(Colors.grey)),
              ],
            ),
        ],
      ),
    );
  }
}
