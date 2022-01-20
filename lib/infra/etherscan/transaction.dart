import 'package:flutter_ethereum_wallet/provider/custom_token.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class TxList {
  final List<Tx> items;

  TxList({
    required this.items,
  });

  factory TxList.fromJson(Map<String, dynamic>? parsedJson) {
    final List<dynamic> itemsFromJson = parsedJson?["result"] ?? [];
    final items = itemsFromJson.map((item) => Tx.fromJson(item)).toList();
    return TxList(items: items);
  }
}

class Tx {
  final String blockNumber;
  final String blockHash;
  final int timestamp;
  final String hash;
  final String from;
  final String to;
  final String value;
  final String gas;
  final String gasPrice;
  final String gasUsed;
  final String isError;

  Tx({
    required this.blockNumber,
    required this.blockHash,
    required this.timestamp,
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gas,
    required this.gasPrice,
    required this.gasUsed,
    required this.isError,
  });

  factory Tx.fromJson(Map<String, dynamic>? parsedJson) {
    return Tx(
        blockNumber: parsedJson?["blockNumber"],
        blockHash: parsedJson?["blockHash"],
        timestamp: int.parse(parsedJson?["timeStamp"]),
        hash: parsedJson?["hash"],
        from: parsedJson?["from"],
        to: parsedJson?["to"],
        value: parsedJson?["value"],
        gas: parsedJson?["gas"],
        gasPrice: parsedJson?["gasPrice"],
        gasUsed: parsedJson?["gasUsed"],
        isError: parsedJson?["isError"]);
  }

  String valueEth() {
    return EtherAmount.fromUnitAndValue(EtherUnit.wei, value)
        .getValueInUnit(EtherUnit.ether)
        .toStringAsFixed(3);
  }

  String displayDate() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String time = DateFormat("yyyy/MM/dd HH:mm").format(date).toString();
    return time;
  }

  bool error() {
    return isError == "1";
  }

  bool isMine(EthereumAddress? address) {
    return EthereumAddress.fromHex(from).hex == address?.hex;
  }

  bool isSendToContract() {
    return EthereumAddress.fromHex(to).hex == customTokenAddress.hex;
  }
}
