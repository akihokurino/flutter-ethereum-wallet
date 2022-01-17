import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_ethereum_wallet/infra/etherscan/transaction.dart';
import 'package:flutter_ethereum_wallet/provider/error.dart';
import 'package:web3dart/credentials.dart';

class EtherScanClient {
  static final EtherScanClient _singleton = EtherScanClient._internal();

  factory EtherScanClient() {
    return _singleton;
  }

  EtherScanClient._internal();

  final baseUrl = dotenv.env["ETHERSCAN_API_URL"]!;
  final apiKey = dotenv.env["ETHERSCAN_API_KEY"]!;
  final dio = Dio();

  Future<List<Tx>> getTransactionList(
      EthereumAddress address, int page, int limit) async {
    final url =
        "$baseUrl/api?module=account&action=txlist&address=${address.toString()}&startblock=0&endblock=99999999&page=$page&offset=$limit&sort=desc&apikey=$apiKey";

    try {
      final response = await dio.get(url);
      final listTransaction = TxList.fromJson(response.data);
      return listTransaction.items;
    } on SocketException {
      throw AppError("オフラインです\nネットワークに接続してください");
    } on FormatException {
      throw AppError("エラーが発生しました");
    } on DioError catch (_) {
      throw AppError("エラーが発生しました");
    } catch (e) {
      rethrow;
    }
  }
}
