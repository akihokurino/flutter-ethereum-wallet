import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;

  CustomTabBar({
    Key? key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      height: 65.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                  size: 26.0,
                  color: isSelected
                      ? (item.activeColorSecondary ?? Colors.white)
                      : item.inactiveColorPrimary ?? Colors.white),
              child: item.icon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Material(
              type: MaterialType.transparency,
              child: FittedBox(
                  child: Text(
                item.title ?? "",
                style: TextStyle(
                    color: isSelected
                        ? (item.activeColorSecondary ?? Colors.white)
                        : item.inactiveColorPrimary,
                    fontSize: 12.0),
              )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeData.dark().backgroundColor,
        border: Border(
          top: BorderSide(
            color: ThemeData().dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        height: 65.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            int index = items.indexOf(item);
            return Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  onItemSelected(index);
                },
                child: _buildItem(item, selectedIndex == index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
