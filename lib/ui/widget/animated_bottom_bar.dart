import 'package:flutter/material.dart';

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem> barItems;
  final Function onBarTap;
  final BarStyle barStyle;
  final int currentIndex;

  const AnimatedBottomBar(
      {Key? key,
      required this.barItems,
      required this.onBarTap,
      required this.barStyle,
      required this.currentIndex})
      : super(key: key);
  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildBarItems(),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> _barItems = [];
    for (int i = 0; i < widget.barItems.length; i++) {
      BarItem item = widget.barItems[i];
      bool isSelected = widget.currentIndex == i;
      if (i == 2) {
        _barItems.add(const SizedBox(
          width: 10.0,
        ));
      }
      _barItems.add(SizedBox(
        height: 50,
        child: Stack(
          children: [
            Center(
              child: IconButton(
                  tooltip: item.text,
                  icon: Icon(
                    item.icon,
                    size: isSelected ? 33 : 30,
                    color: isSelected ? item.color : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedBarIndex = i;
                      widget.onBarTap(selectedBarIndex);
                    });
                  }),
            ),
          ],
        ),
      ));
    }
    return _barItems;
  }
}

class BarStyle {
  final double fontSize, iconSize;
  final FontWeight fontWeight;
  BarStyle(
      {this.fontSize = 14.0,
      this.iconSize = 22,
      this.fontWeight = FontWeight.w600});
}

class BarItem {
  String text;
  IconData icon;
  Color color;

  BarItem({
    required this.text,
    required this.icon,
    required this.color,
  });
}
