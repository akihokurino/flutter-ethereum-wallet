import 'package:flutter_ethereum_wallet/infra/datastore.dart';
import 'package:flutter_ethereum_wallet/infra/etherscan/client.dart';
import 'package:flutter_ethereum_wallet/infra/etherscan/transaction.dart';
import 'package:flutter_ethereum_wallet/provider/error.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web3dart/web3dart.dart';

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> init() async {
    try {
      state = state.setShouldShowHUD(true);

      final rawPrivateKey = await DataStore().getPrivateKey();
      final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
      final address = credentials.address;
      final transactions =
          await EtherScanClient().getTransactionList(address, 1, 10000);

      state = state.setAddress(address);
      state = state.setTransactions(transactions);
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
      final address = credentials.address;
      final transactions =
          await EtherScanClient().getTransactionList(address, 1, 10000);

      state = state.setTransactions(transactions);
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
      required this.address,
      required this.transactions});

  static _State init() {
    return _State(shouldShowHUD: false, address: null, transactions: []);
  }

  _State setShouldShowHUD(bool should) {
    return _State(
        shouldShowHUD: should, address: address, transactions: transactions);
  }

  _State setAddress(EthereumAddress address) {
    return _State(
        shouldShowHUD: shouldShowHUD,
        address: address,
        transactions: transactions);
  }

  _State setTransactions(List<Tx> transactions) {
    return _State(
        shouldShowHUD: shouldShowHUD,
        address: address,
        transactions: transactions);
  }
}

final historyProvider =
    StateNotifierProvider<_Provider, _State>((_) => _Provider());
