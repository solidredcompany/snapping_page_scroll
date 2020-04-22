import 'package:flutter/material.dart';
import 'package:snapping_page_scroll/snapping_page_scroll.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  Widget customCard(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
      child: Card(
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(),
        body: SnappingPageScroll(
          viewportFraction: 0.75,
          children: <Widget>[
            customCard('Card 1'),
            customCard('Card 2'),
            customCard('Card 3'),
            customCard('Card 4'),
            customCard('Card 5'),
            customCard('Card 6'),
          ],
        ),
      ),
    );
  }
}
