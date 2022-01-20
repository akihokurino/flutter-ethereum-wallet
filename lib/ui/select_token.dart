import 'package:flutter/material.dart';
import 'package:flutter_ethereum_wallet/component/menu_link.dart';
import 'package:flutter_ethereum_wallet/ui/erc20/custom_token.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SelectTokenPage extends HookConsumerWidget {
  const SelectTokenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenListView = Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: [
          MenuLink(
              text: "CustomToken",
              onClick: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CustomTokenPage.withKey(),
                  ),
                );
              })
        ],
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text("トークン"),
          centerTitle: true,
        ),
      ),
      body: ListView(
        children: [tokenListView],
      ),
    );
  }
}
