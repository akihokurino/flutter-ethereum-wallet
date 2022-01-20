import 'package:flutter/material.dart';

class MenuLink extends StatelessWidget {
  final String text;
  final VoidCallback onClick;

  MenuLink({required this.text, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ThemeData.dark().dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: ThemeData.dark().backgroundColor,
        child: InkWell(
          onTap: () {
            onClick();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(text,
                            style: ThemeData.dark().textTheme.bodyText1),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 15,
                    color: ThemeData.dark().textTheme.bodyText1!.color)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
