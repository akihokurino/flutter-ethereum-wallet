import 'package:flutter_ethereum_wallet/infra/etherscan/client.dart';
import 'package:flutter_ethereum_wallet/infra/etherscan/transaction.dart';
import 'package:flutter_ethereum_wallet/main.dart';
import 'package:flutter_ethereum_wallet/provider/error.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPrivateKey = prefs.getString(walletPrivateKey) ?? "";
    final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));

    final address = credentials.address;
    state = state.setAddress(address);

    try {
      state = state.setShouldShowHUD(true);
      final transactions =
          await EtherScanClient().getTransactionList(address, 1, 10000);
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = state.setTransaction(transactions);
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

    final address = credentials.address;

    try {
      final transactions =
          await EtherScanClient().getTransactionList(address, 1, 10000);
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = state.setTransaction(transactions);
    } catch (e) {
      return AppError("エラーが発生しました");
    }
  }
}

class _State {
  final bool shouldShowHUD;
  final EthereumAddress? address;
  final List<Tx> transactions;

  _State(
      {required this.shouldShowHUD,
      required this.transactions,
      required this.address});

  static _State init() {
    return _State(shouldShowHUD: false, transactions: [], address: null);
  }

  _State setShouldShowHUD(bool should) {
    return _State(
        shouldShowHUD: should, transactions: transactions, address: address);
  }

  _State setTransaction(List<Tx> transactions) {
    return _State(
        shouldShowHUD: shouldShowHUD,
        transactions: transactions,
        address: address);
  }

  _State setAddress(EthereumAddress address) {
    return _State(
        shouldShowHUD: shouldShowHUD,
        transactions: transactions,
        address: address);
  }
}

final historyProvider =
    StateNotifierProvider<_Provider, _State>((_) => _Provider());
