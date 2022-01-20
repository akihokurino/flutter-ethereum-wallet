import 'package:flutter/material.dart';
import 'package:flutter_ethereum_wallet/component/dialog.dart';
import 'package:flutter_ethereum_wallet/infra/etherscan/transaction.dart';
import 'package:flutter_ethereum_wallet/provider/history.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hud/flutter_hud.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    final action = ref.read(historyProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Future.wait([action.init()]).then((err) {
          final errors = err.where((element) => element != null).toList();
          if (errors.isNotEmpty) {
            AppDialog().showErrorAlert(context, errors.first!);
            return;
          }
        });
      });

      return () {};
    }, const []);

    final historyListView = Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: state.transactions.map((tx) {
          if (tx.isMine(state.address)) {
            return outHistory(context, tx);
          } else {
            return inHistory(context, tx);
          }
        }).toList(),
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text("履歴"),
          centerTitle: true,
        ),
      ),
      body: WidgetHUD(
          builder: (context) => RefreshIndicator(
              child: ListView(
                children: [historyListView],
              ),
              onRefresh: () async {
                final err = await action.refresh();
                if (err != null) {
                  AppDialog().showErrorAlert(context, err);
                  return;
                }
              }),
          showHUD: state.shouldShowHUD),
    );
  }

  Widget inHistory(BuildContext context, Tx transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(right: 10),
          child: const Center(child: Icon(Icons.arrow_forward_sharp)),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 60,
          child: Card(
            color: transaction.error()
                ? Colors.red
                : const Color.fromRGBO(12, 248, 208, 0.5),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text("トランザクションハッシュ:\n${transaction.hash}"),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text("送り元: \n${transaction.from}"),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text("総額: ${transaction.valueEth()} Ether"),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    child: Text("日付: ${transaction.displayDate()}"),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget outHistory(BuildContext context, Tx transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 60,
          child: Card(
            color: transaction.error()
                ? Colors.red
                : const Color.fromRGBO(219, 154, 4, 0.8352941176470589),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text("トランザクションハッシュ: \n${transaction.hash}"),
                  ),
                  !transaction.isSendToContract()
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text("送り先: \n${transaction.to}"),
                        )
                      : Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: const Text("コントラクト呼び出し"),
                        ),
                  !transaction.isSendToContract()
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text("総額: ${transaction.valueEth()} Ether"),
                        )
                      : Container(),
                  Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    child: Text("日付: ${transaction.displayDate()}"),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(left: 10),
          child: const Center(child: Icon(Icons.arrow_forward_sharp)),
        ),
      ],
    );
  }
}
