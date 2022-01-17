import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ethereum_wallet/main.dart';
import 'package:flutter_ethereum_wallet/provider/error.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

final networkUrl = dotenv.env["NETWORK_URL"]!;
final chainId = dotenv.env["CHAIN_ID"]!;

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPrivateKey = prefs.getString(walletPrivateKey) ?? "";
    final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
    final ethClient = Web3Client(networkUrl, Client());

    final address = credentials.address;
    state = state.setAddress(address);

    try {
      state = state.setShouldShowHUD(true);
      final balance = await ethClient.getBalance(address);
      state = state.setBalance(balance);
    } catch (e) {
      return AppError("エラーが発生しました");
    } finally {
      state = state.setShouldShowHUD(false);
    }
  }

  Future<AppError?> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPrivateKey = prefs.getString(walletPrivateKey) ?? "";
    final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
    final ethClient = Web3Client(networkUrl, Client());

    final address = credentials.address;

    try {
      final balance = await ethClient.getBalance(address);
      state = state.setBalance(balance);
    } catch (e) {
      return AppError("エラーが発生しました");
    }
  }

  Future<AppError?> sendTransaction(double eth, String to) async {
    if (eth <= 0.0 || to.isEmpty) {
      return AppError("入力が不正です");
    }

    final prefs = await SharedPreferences.getInstance();
    final rawPrivateKey = prefs.getString(walletPrivateKey) ?? "";
    final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
    final ethClient = Web3Client(networkUrl, Client());
    final wei = BigInt.from(eth * 1e+18);

    try {
      state = state.setShouldShowHUD(true);
      final hash = await ethClient.sendTransaction(
          credentials,
          Transaction(
              to: EthereumAddress.fromHex(to),
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, wei),
              gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 100),
              maxGas: 21000),
          chainId: int.parse(chainId));
      debugPrint(hash);
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
      required this.balance,
      required this.address});

  static _State init() {
    return _State(
        shouldShowHUD: false, balance: EtherAmount.zero(), address: null);
  }

  _State setShouldShowHUD(bool should) {
    return _State(shouldShowHUD: should, balance: balance, address: address);
  }

  _State setBalance(EtherAmount balance) {
    return _State(
        shouldShowHUD: shouldShowHUD, balance: balance, address: address);
  }

  _State setAddress(EthereumAddress address) {
    return _State(
        shouldShowHUD: shouldShowHUD, balance: balance, address: address);
  }
}

final homeProvider =
    StateNotifierProvider<_Provider, _State>((_) => _Provider());
