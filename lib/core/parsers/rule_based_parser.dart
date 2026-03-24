import '../models/sms_transaction.dart';
import 'i_sms_parser.dart';
import 'data_extractors.dart';

class ParserConfig {
  final String bankName;
  final List<String> senderPrefixes;
  final List<RegExp> amountPatterns;
  final List<RegExp> accountPatterns;
  final List<RegExp> balancePatterns;
  final List<RegExp> creditPatterns;
  final List<RegExp> debitPatterns;

  ParserConfig({
    required this.bankName,
    required this.senderPrefixes,
    required this.amountPatterns,
    required this.accountPatterns,
    required this.balancePatterns,
    required this.creditPatterns,
    required this.debitPatterns,
  });
}

class RuleBasedParser implements ISmsParser {
  final ParserConfig config;

  RuleBasedParser(this.config);

  @override
  String get id => config.bankName;

  @override
  bool canParse(String sender, String body) {
    final upperSender = sender.toUpperCase();
    return config.senderPrefixes.any((prefix) => 
      upperSender.startsWith(prefix.toUpperCase()) || 
      upperSender.contains('-${prefix.toUpperCase()}')
    );
  }

  @override
  SmsTransaction? parse({
    required String sender,
    required String body,
    DateTime? receivedDate,
  }) {
    double amount = 0.0;
    String accountNumber = 'Unknown';
    String lastFourDigits = 'Unknown';
    double balance = 0.0;
    bool hasBalanceInfo = false;
    String type = 'Unknown';

    // 1. Extract Amount
    for (var pattern in config.amountPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final amtStr = match.group(1)?.replaceAll(',', '') ?? '';
        amount = double.tryParse(amtStr) ?? 0.0;
        break;
      }
    }

    if (amount == 0.0) return null; // Transaction search needs an amount

    // 2. Extract Account Info
    for (var pattern in config.accountPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        accountNumber = match.group(0) ?? 'Unknown';
        // If there is a capture group, use it for lastFourDigits
        if (match.groupCount >= 1) {
          lastFourDigits = match.group(1) ?? 'Unknown';
          // If it's too long, take the last 4
          if (lastFourDigits.length > 4) {
            lastFourDigits = lastFourDigits.substring(lastFourDigits.length - 4);
          }
        }
        break;
      }
    }

    // 3. Extract Balance
    for (var pattern in config.balancePatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final balStr = match.group(1)?.replaceAll(',', '') ?? '';
        balance = double.tryParse(balStr) ?? 0.0;
        hasBalanceInfo = true;
        break;
      }
    }

    // 4. Extract UPI/Merchant Info
    final upiId = DataExtractors.extractUpiId(body);
    final merchantName = DataExtractors.extractMerchantName(body, type: type);
    final upiIdOrSenderName = upiId ?? merchantName ?? 'Unknown';

    // 5. Determine Type (Proximity-based)
    final lowerBody = body.toLowerCase();
    int minDistance = 1000;
    
    // Find amount position to check proximity
    int amountPos = -1;
    for (var pattern in config.amountPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        amountPos = match.start;
        break;
      }
    }

    for (var pattern in config.creditPatterns) {
      final matches = pattern.allMatches(lowerBody);
      for (var m in matches) {
        int dist = (m.start - amountPos).abs();
        if (dist < minDistance) {
          minDistance = dist;
          type = 'Credit';
        }
      }
    }

    for (var pattern in config.debitPatterns) {
      final matches = pattern.allMatches(lowerBody);
      for (var m in matches) {
        int dist = (m.start - amountPos).abs();
        if (dist < minDistance) {
          minDistance = dist;
          type = 'Debit';
        }
      }
    }

    return SmsTransaction(
      id: '${body.hashCode}_$receivedDate',
      amount: amount,
      date: receivedDate,
      bank: config.bankName,
      type: type,
      sender: sender,
      rawBody: body,
      accountNumber: accountNumber,
      lastFourDigits: lastFourDigits,
      balance: balance,
      hasBalanceInfo: hasBalanceInfo,
      upiIdOrSenderName: upiIdOrSenderName,
    );
  }
}
