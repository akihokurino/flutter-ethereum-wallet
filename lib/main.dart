import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ethereum_wallet/infra/datastore.dart';
import 'package:flutter_ethereum_wallet/ui/root.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("ja_JP");
  await dotenv.load(fileName: ".env");
  await _initWallet();

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

Future<void> _initWallet() async {
  final rawPrivateKey = await DataStore().getPrivateKey();
  final EthPrivateKey credentials;
  if (rawPrivateKey.isEmpty) {
    credentials = EthPrivateKey.createRandom(Random.secure());
    await DataStore().savePrivateKey(credentials.privateKeyInt.toString());
  } else {
    credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
  }
  debugPrint("secret: ${bytesToHex(credentials.privateKey)}");
}
