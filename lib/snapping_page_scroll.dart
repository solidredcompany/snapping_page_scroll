library snapping_page_scroll;

import 'package:flutter/material.dart';

class SnappingPageScroll extends StatefulWidget {
  final List<Widget> children;
  final ValueChanged<int> onPageChanged;
  final int initialPage;
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
      onPointerMove: (pos) {
        //Hämta pekarposition (fingerposition)
        //Om tid sedan senaste scrollning är odefinerad eller över 100 millisekunder
        if (time == null || DateTime.now().millisecondsSinceEpoch - time > 100) {
          time = DateTime.now().millisecondsSinceEpoch;
          position = pos.position.dx; //x-position
        } else {
          //Beräkna hastighet
          double v = (position - pos.position.dx) / (DateTime.now().millisecondsSinceEpoch - time);
          if (v < -2 || v > 2) {
            //Kör inte om hastigheten är för låg
            //Scrolla till sida baserat på hastighet (öka hastighetskoefficient för att scrolla längre)
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
          physics: ClampingScrollPhysics(),
          //BouncingScrollPhysics scrollar för långt
          scrollDirection: widget.scrollDirection ?? Axis.horizontal,
          children: widget.children,
        ),
      ),
    );
  }
}

class CustomScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
