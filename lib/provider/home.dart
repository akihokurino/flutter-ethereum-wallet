import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ethereum_wallet/infra/datastore.dart';
import 'package:flutter_ethereum_wallet/provider/error.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

final networkUrl = dotenv.env["NETWORK_URL"]!;
final chainId = dotenv.env["CHAIN_ID"]!;

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> init() async {
    try {
      state = state.setShouldShowHUD(true);

      final rawPrivateKey = await DataStore().getPrivateKey();
      final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
      final ethClient = Web3Client(networkUrl, Client());
      final address = credentials.address;
      final balance = await ethClient.getBalance(address);
      await ethClient.dispose();

      state = state.setAddress(address);
      state = state.setBalance(balance);
    } catch (e) {
      return AppError("エラーが発生しました");
    } finally {
      state = state.setShouldShowHUD(false);
    }
  }

  Future<AppError?> refresh() async {
    try {
      final rawPrivateKey = await DataStore().getPrivateKey();
      final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
      final ethClient = Web3Client(networkUrl, Client());
      final address = credentials.address;
      final balance = await ethClient.getBalance(address);
      await ethClient.dispose();

      state = state.setBalance(balance);
    } catch (e) {
      return AppError("エラーが発生しました");
    }
  }

  Future<AppError?> sendTransaction(double eth, String to) async {
    if (eth <= 0.0 || to.isEmpty) {
      return AppError("入力が不正です");
    }

    try {
      state = state.setShouldShowHUD(true);

      final rawPrivateKey = await DataStore().getPrivateKey();
      final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
      final ethClient = Web3Client(networkUrl, Client());
      final address = credentials.address;
      final wei = BigInt.from(eth * 1e+18);
      final hash = await ethClient.sendTransaction(
          credentials,
          Transaction(
              from: address,
              to: EthereumAddress.fromHex(to),
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, wei)),
          chainId: int.parse(chainId));
      await ethClient.dispose();

      debugPrint("create tx: $hash");
    } catch (e) {
      return AppError("エラーが発生しました");
    } finally {
      state = state.setShouldShowHUD(false);
    }
  }
}

class _State {
  final bool shouldShowHUD;
  final EthereumAddress? address;
  final EtherAmount balance;

  _State(
      {required this.shouldShowHUD,
      required this.address,
      required this.balance});

  static _State init() {
    return _State(
        shouldShowHUD: false, address: null, balance: EtherAmount.zero());
  }

  _State setShouldShowHUD(bool should) {
    return _State(shouldShowHUD: should, address: address, balance: balance);
  }

  _State setAddress(EthereumAddress address) {
    return _State(
        shouldShowHUD: shouldShowHUD, address: address, balance: balance);
  }

  _State setBalance(EtherAmount balance) {
    return _State(
        shouldShowHUD: shouldShowHUD, address: address, balance: balance);
  }
}

final homeProvider =
    StateNotifierProvider<_Provider, _State>((_) => _Provider());
