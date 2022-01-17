import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ethereum_wallet/ui/root.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

const walletPrivateKey = "wallet-private-key";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final prefs = await SharedPreferences.getInstance();
  final rawPrivateKey = prefs.getString(walletPrivateKey) ?? "";
  if (rawPrivateKey.isEmpty) {
    final credentials = EthPrivateKey.createRandom(Random.secure());
    prefs.setString(walletPrivateKey, credentials.privateKeyInt.toString());
  }
}
