import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ethereum_wallet/infra/datastore.dart';
import 'package:flutter_ethereum_wallet/provider/error.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:web3dart/contracts/erc20.dart';
import 'package:web3dart/web3dart.dart';

final _networkUrl = dotenv.env["NETWORK_URL"]!;
final customTokenAddress =
    EthereumAddress.fromHex("0x803c6922F39792Bd17DE55Db7eFcd7b4a206ebA4");

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> init() async {
    try {
      state = state.setShouldShowHUD(true);

      final rawPrivateKey = await DataStore().getPrivateKey();
      final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
      final ethClient = Web3Client(_networkUrl, Client());
      final address = credentials.address;
      final token = Erc20(address: customTokenAddress, client: ethClient);
      final balance = await token.balanceOf(address);
      await ethClient.dispose();

      state = state.setAddress(address);
      state = state.setBalance(balance.toInt());
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
      final ethClient = Web3Client(_networkUrl, Client());
      final address = credentials.address;
      final token = Erc20(address: customTokenAddress, client: ethClient);
      final balance = await token.balanceOf(address);
      await ethClient.dispose();

      state = state.setBalance(balance.toInt());
    } catch (e) {
      return AppError("エラーが発生しました");
    }
  }

  Future<AppError?> sendToken(int value, String to) async {
    if (value <= 0 || to.isEmpty) {
      return AppError("入力が不正です");
    }

    try {
      state = state.setShouldShowHUD(true);

      final rawPrivateKey = await DataStore().getPrivateKey();
      final credentials = EthPrivateKey.fromInt(BigInt.parse(rawPrivateKey));
      final ethClient = Web3Client(_networkUrl, Client());
      final address = credentials.address;
      final token = Erc20(address: customTokenAddress, client: ethClient);
      final hash = await token.transfer(
          EthereumAddress.fromHex(to), BigInt.from(value),
          credentials: credentials,
          transaction: Transaction(
              from: address,
              maxGas: 5500000,
              gasPrice:
                  EtherAmount.fromUnitAndValue(EtherUnit.wei, 35000000000)));
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
  final int balance;

  _State(
      {required this.shouldShowHUD,
      required this.address,
      required this.balance});

  static _State init() {
    return _State(shouldShowHUD: false, address: null, balance: 0);
  }

  _State setShouldShowHUD(bool should) {
    return _State(shouldShowHUD: should, address: address, balance: balance);
  }

  _State setAddress(EthereumAddress address) {
    return _State(
        shouldShowHUD: shouldShowHUD, address: address, balance: balance);
  }

  _State setBalance(int balance) {
    return _State(
        shouldShowHUD: shouldShowHUD, address: address, balance: balance);
  }
}

final customTokenProvider =
    StateNotifierProvider<_Provider, _State>((_) => _Provider());
