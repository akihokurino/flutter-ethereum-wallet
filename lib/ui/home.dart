import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ethereum_wallet/component/button.dart';
import 'package:flutter_ethereum_wallet/component/dialog.dart';
import 'package:flutter_ethereum_wallet/component/text_field.dart';
import 'package:flutter_ethereum_wallet/provider/home.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hud/flutter_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final action = ref.read(homeProvider.notifier);

    final sendEth = useState(0.0);
    final sendAddress = useState("");

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

    final addressView = Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: InkWell(
        child: Text(
          "アドレス: \n${state.address?.hex ?? ""}",
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () async {
          if (state.address == null || state.address!.hex.isEmpty) {
            return;
          }

          final data = ClipboardData(text: state.address!.hex);
          await Clipboard.setData(data);

          Fluttertoast.showToast(
              msg: "コピーしました",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: ThemeData().primaryColor,
              textColor: Colors.white,
              fontSize: 16.0);
        },
      ),
    );

    final balanceView = Container(
      width: double.infinity,
      height: 100.0,
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Card(
        color: Colors.green,
        child: Center(
          child: Text(
            "${state.balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(3)} Ether",
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );

    final createTransactionView = Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 40, 10, 20),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.zero,
            child: const Text(
              "取引作成",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            margin: EdgeInsets.zero,
            child: TextFieldView(
              label: "取引額（Ether）",
              value: sendEth.value.toString(),
              inputType: TextInputType.number,
              onChange: (val) {
                sendEth.value = double.parse(val);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.zero,
            child: TextFieldView(
              label: "宛先",
              value: sendAddress.value,
              inputType: TextInputType.emailAddress,
              onChange: (val) {
                sendAddress.value = val;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: ContainedButton(
                text: "送信",
                textColor: Colors.white,
                backgroundColor: Colors.blue,
                onClick: () async {
                  final err = await action.sendTransaction(
                      sendEth.value, sendAddress.value);
                  if (err != null) {
                    AppDialog().showErrorAlert(context, err);
                    return;
                  }

                  sendEth.value = 0.0;
                  sendAddress.value = "";
                }),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text("ホーム"),
          centerTitle: true,
        ),
      ),
      body: WidgetHUD(
          builder: (context) => RefreshIndicator(
                child: ListView(
                  children: [addressView, balanceView, createTransactionView],
                ),
                onRefresh: () async {
                  final err = await action.refresh();
                  if (err != null) {
                    AppDialog().showErrorAlert(context, err);
                    return;
                  }
                },
              ),
          showHUD: state.shouldShowHUD),
    );
  }
}
