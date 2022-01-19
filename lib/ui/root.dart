import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ethereum_wallet/component/tabbar.dart';
import 'package:flutter_ethereum_wallet/ui/history.dart';
import 'package:flutter_ethereum_wallet/ui/home.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:uuid/uuid.dart';

class RootPage extends HookWidget {
  static Widget init() {
    return RootPage(
      key: Key(const Uuid().v4()),
    );
  }

  RootPage({Key? key}) : super(key: key);

  late final PersistentTabController _tabController;
  final List<GlobalKey<NavigatorState>> globalKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabIndex = useState(0);

    useEffect(() {
      _tabController = PersistentTabController(initialIndex: 0);
      return () {};
    }, const []);

    _tabController.index = tabIndex.value;

    return PersistentTabView.custom(
      context,
      controller: _tabController,
      screens: [
        HomePage(key: globalKeys[0]),
        HistoryPage(key: globalKeys[1]),
      ],
      itemCount: globalKeys.length,
      customWidget: CustomTabBar(
        items: [
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            title: "ホーム",
            activeColorPrimary: ThemeData().primaryColor,
            inactiveColorPrimary: CupertinoColors.systemGrey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.history),
            title: "履歴",
            activeColorPrimary: ThemeData().primaryColor,
            inactiveColorPrimary: CupertinoColors.systemGrey,
          ),
        ],
        selectedIndex: _tabController.index,
        onItemSelected: (index) {
          if (_tabController.index == index) {
            Navigator.popUntil(globalKeys[index].currentContext!,
                (Route<dynamic> route) => route.isFirst);
            return;
          }

          tabIndex.value = index;
        },
      ),
      confineInSafeArea: true,
      backgroundColor: ThemeData.dark().backgroundColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      screenTransitionAnimation:
          const ScreenTransitionAnimation(animateTabTransition: false),
    );
  }
}
