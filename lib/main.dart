import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ethereum_wallet/component/button.dart';
import 'package:flutter_ethereum_wallet/component/dialog.dart';
import 'package:flutter_ethereum_wallet/component/text_field.dart';
import 'package:flutter_ethereum_wallet/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hud/flutter_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/web3dart.dart';

const walletPrivateKey = "wallet-private-key";
const walletTransactionHashKey = "wallet-transaction-hash-key";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final rawPrivateKey = prefs.getString(walletPrivateKey) ?? "";
  if (rawPrivateKey.isEmpty) {
    final credentials = EthPrivateKey.createRandom(Random.secure());
    prefs.setString(walletPrivateKey, credentials.privateKeyInt.toString());
  }

  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: RootPage.init(),
    builder: (context, child) {
      return MediaQuery(
        child: child!,
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      );
    },
  );

  runApp(
    ProviderScope(
      child: app,
    ),
  );
}

class RootPage extends HookConsumerWidget {
  static Widget init() {
    return RootPage(key: GlobalObjectKey(const Uuid().v4()));
  }

  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    final action = ref.read(provider.notifier);

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
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        },
      ),
    );

    final balanceView = Container(
      width: double.infinity,
      height: 100.0,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Card(
        color: ThemeData().navigationBarTheme.backgroundColor,
        child: Center(
          child: Text(
            "${state.balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(3)} ETH",
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );

    final createTransactionView = Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 20),
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
              label: "送金額（ETH）",
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
              label: "送金先",
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
          title: const Text("ETHウォレット"),
          centerTitle: true,
        ),
      ),
      body: WidgetHUD(
          builder: (context) => ListView(
                children: [addressView, balanceView, createTransactionView],
              ),
          showHUD: state.shouldShowHUD),
    );
  }
}
