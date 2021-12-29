library snapping_page_scroll;

import 'package:flutter/material.dart';

class SnappingPageScroll extends StatefulWidget {
  const SnappingPageScroll({
    Key? key,
    required this.children,
    this.onPageChanged,
    @Deprecated('Use controller instead') this.initialPage = 0,
    this.scrollDirection = Axis.horizontal,
    this.showPageIndicator = false,
    this.currentPageIndicator,
    this.otherPageIndicator,
    @Deprecated('Use controller instead') this.viewportFraction = 1,
    this.controller,
  }) : super(key: key);

  /// The pages that the widget will scroll between and snap to.
  final List<Widget> children;

  /// Called when the page changes.
  final ValueChanged<int>? onPageChanged;

  /// Index of the page that is shown initially.
  final int initialPage;

  /// The axis on which the pages is scrolled along.
  final Axis scrollDirection;

  /// Option to enable / disable page indicators.
  final bool showPageIndicator;

  /// Widget to use as indicator for the page currently on screen.
  final Widget? currentPageIndicator;

  /// Widget to use as indicator for the pages that not on screen.
  final Widget? otherPageIndicator;

  /// With of page, where 1 is 100% of the screen.
  final double viewportFraction;

  /// Page controller to use if provided.
  final PageController? controller;

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
    _pageController = widget.controller ??
        PageController(
          viewportFraction: widget.viewportFraction,
          initialPage: widget.initialPage,
        );
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
        if (time == null ||
            DateTime.now().millisecondsSinceEpoch - time! > 100) {
          time = DateTime.now().millisecondsSinceEpoch;
          position = pos.position.dx;

          // The fingers x-coordinate.
        } else {
          ///Calculates scroll velocity.
          final v = (position - pos.position.dx) /
              (DateTime.now().millisecondsSinceEpoch - time!);

          // If the scroll velocity is to low, the widget will scroll as a PageView widget with
          // pageSnapping turned on.
          if ((v < -2 || v > 2) &&
              !(v == double.nan ||
                  v == double.infinity ||
                  v == double.negativeInfinity)) {
            // Scrolls to a certain page based on the scroll velocity
            // The velocity coefficient (v * velocity coefficient) can be increased to scroll faster,
            // and thus further before snapping.
            _pageController!.animateToPage(_currentPage + (v * 1.2).round(),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic);
          }
        }
      },
      child: ScrollConfiguration(
        behavior: CustomScroll(),
        child: Stack(
          children: <Widget>[
            PageView(
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
              children: widget.children,
            ),
            Visibility(
              visible: widget.showPageIndicator,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Builds one indicator for every page.
                  for (int i = 0; i < widget.children.length; i++)
                    i == _currentPage
                        ? (widget.currentPageIndicator ??
                            defaultIndicator(Colors.white))
                        : (widget.otherPageIndicator ??
                            defaultIndicator(Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom scroll behaivior to remove scroll glow.
class CustomScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
