import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hud/flutter_hud.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) {});

      return () {};
    }, const []);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text("履歴"),
          centerTitle: true,
        ),
      ),
      body: WidgetHUD(
          builder: (context) => ListView(
                children: [],
              ),
          showHUD: true),
    );
  }
}
