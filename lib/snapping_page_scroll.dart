library snapping_page_scroll;

import 'package:flutter/material.dart';

class SnappingPageScroll extends StatefulWidget {

  ///The pages that the widget will scroll between and snap to.
  final List<Widget> children;

  ///Called when the page changes.
  final ValueChanged<int> onPageChanged;

  ///Index of the page that is shown initially.
  final int initialPage;

  ///The axis on which the pages is scrolled along.
  final Axis scrollDirection;

  SnappingPageScroll({
    Key key,
    @required this.children,
    this.onPageChanged,
    this.initialPage,
    this.scrollDirection
  }) : super(key: key);

  @override
  _SnappingPageScrollState createState() => _SnappingPageScrollState();
}

class _SnappingPageScrollState extends State<SnappingPageScroll> {
  PageController _pageController;
  int time;
  double position;
  int _currentPage = 0;

  @override
  void initState() {
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: widget.initialPage ?? 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      ///Get pointer (finger) position.
      onPointerMove: (pos) {
        ///Runs if the time since the last scroll is undefined or over 100 milliseconds.
        if (time == null || DateTime.now().millisecondsSinceEpoch - time > 100) {
          time = DateTime.now().millisecondsSinceEpoch;
          position = pos.position.dx; ///The fingers x-coordinate.
        } else {
          ///Calculates scroll velocity.
          double v = (position - pos.position.dx) / (DateTime.now().millisecondsSinceEpoch - time);
          ///If the scroll velocity is to low, the widget will scroll as a PageView widget with
          ///pageSnapping turned on.
          if (v < -2 || v > 2) {
            ///Scrolls to a certain page based on the scroll velocity
            //The velocity coefficient (v * velocity coefficient) can be increased to scroll faster,
            //and thus further before snapping.
            _pageController.animateToPage(_currentPage + (v * 1.2).round(),
                duration: Duration(milliseconds: 800), curve: Curves.easeOutCubic);
          }
        }
      },
      child: ScrollConfiguration(
        behavior: CustomScroll(),
        child: PageView(
          controller: _pageController,
          onPageChanged: widget.onPageChanged,
          //BouncingScrollPhysics can't be used since that will scroll to far because of the animation
          physics: ClampingScrollPhysics(),
          ///Scroll direction will default to horizontal unless otherwise is specified
          scrollDirection: widget.scrollDirection ?? Axis.horizontal,
          children: widget.children,
        ),
      ),
    );
  }
}

///Used to remove scroll glow
class CustomScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
