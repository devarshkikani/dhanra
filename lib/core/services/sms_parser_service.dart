// sms_parser_service.dart
import 'package:another_telephony/telephony.dart';

class SmsParserService {
  SmsParserService._();
  static final SmsParserService instance = SmsParserService._();

  // Regex patterns
  static final RegExp _senderPattern = RegExp(
    r'^(?:[A-Z]{2}-)?(HDFCBK|ICICIB|AXISBK|KOTAKB|SBIN|PNB|BOB|CANBNK|UNIONB|YESBNK|IDFCBK|'
    r'INDUSB|ALBK|ANDBNK|CBI|IOB|UCOBNK|PSB|SYNDIB|SVCBNK|'
    r'PAYTM|BHIM|UPI|GPAY|G-PAY|PHONEPE|PHNPE|AMZNPY|IMPS|NEFT|RTGS)',
    caseSensitive: false,
  );

  static final RegExp _transactionPattern = RegExp(
    r'(credited|received|credit|deposited|added|debited|sent|withdrawn|paid|deducted|spent|transferred)'
    r'\s*(?:to|in|from|out)?\s*(?:your\s*)?(?:account|a/c|wallet)?\b.*'
    r'(?:Rs\.?|INR)\s*[\d,.]+',
    caseSensitive: false,
  );

  static final RegExp _amountPattern = RegExp(
    r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _datePattern = RegExp(
    r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{1,2}[A-Za-z]{3}\d{2,4})',
    caseSensitive: false,
  );

  static final Map<String, String> _bankMapping = {
    'HDFCBK': 'HDFC Bank',
    'SBIN': 'State Bank of India',
    'ICICIB': 'ICICI Bank',
    'AXISBK': 'Axis Bank',
    'KOTAKB': 'Kotak Mahindra Bank',
    'PNB': 'Punjab National Bank',
    'BOB': 'Bank of Baroda',
    'CANBNK': 'Canara Bank',
    'UNIONB': 'Union Bank of India',
    'YESBNK': 'Yes Bank',
    'IDFCBK': 'IDFC First Bank',
    'INDUSB': 'IndusInd Bank',
    'PAYTM': 'Paytm',
    'BHIM': 'BHIM UPI',
    'UPI': 'UPI',
    'GPAY': 'Google Pay',
    'PHONEPE': 'PhonePe',
    'AMZNPY': 'Amazon Pay',
  };

  static String _getBankName(String sender) {
    final prefixPattern = RegExp(r'^(?:AXL-|VM-|VK-|JM-|BP-|AD-|BX-)(.*)$');
    final match = prefixPattern.firstMatch(sender.toUpperCase());
    final key = match?.group(1) ?? sender.toUpperCase();
    return _bankMapping[key] ?? key;
  }

  static String _getTransactionType(String body) {
    final lowerBody = body.toLowerCase();
    const creditKeywords = [
      'credited',
      'received',
      'credit',
      'deposited',
      'added'
    ];
    const debitKeywords = [
      'debited',
      'sent',
      'withdrawn',
      'paid',
      'deducted',
      'spent',
      'transferred'
    ];

    if (creditKeywords.any(lowerBody.contains)) return 'Credit';
    if (debitKeywords.any(lowerBody.contains)) return 'Debit';
    return 'Unknown';
  }

  List<Map<String, String>> parseTransactionMessages(
      List<Map<String, String>> smsMessages) {
    return smsMessages.where((message) {
      final sender = message['sender']?.toUpperCase() ?? '';
      final body = message['body']?.toLowerCase() ?? '';
      return _senderPattern.hasMatch(sender) &&
          _transactionPattern.hasMatch(body);
    }).map((message) {
      final sender = message['sender']!.toUpperCase();
      final body = message['body']!;

      final amountMatch = _amountPattern.firstMatch(body);
      final dateMatch = _datePattern.firstMatch(body);

      return {
        'amount': amountMatch?.group(1)?.replaceAll(',', '') ?? 'Unknown',
        'date': dateMatch?.group(0) ?? 'Unknown',
        'bank': _getBankName(sender),
        'type': _getTransactionType(body),
        'sender': sender,
        'body': body,
      };
    }).toList();
  }

  List<Map<String, String>> convertSmsMessages(List<SmsMessage> messages) =>
      messages
          .map((m) => {
                'sender': m.address ?? '',
                'body': m.body ?? '',
                'date': m.date?.toString() ?? '',
              })
          .toList();

  Future<List<Map<String, String>>> parseTransactionMessagesBatch(
    List<SmsMessage> messages, {
    int batchSize = 100,
    Function(int processed, int total)? onProgress,
  }) async {
    final results = <Map<String, String>>[];
    for (var i = 0; i < messages.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, messages.length);
      final batch = messages.sublist(i, end);
      final batchResults = parseTransactionMessages(convertSmsMessages(batch));
      results.addAll(batchResults);
      onProgress?.call(end, messages.length);
      await Future.delayed(const Duration(milliseconds: 10));
    }
    return results;
  }

  Future<List<Map<String, String>>>
      parseTransactionMessagesWithMemoryManagement(
    List<SmsMessage> messages, {
    int batchSize = 50,
    Function(int processed, int total, int found)? onProgress,
  }) async {
    final results = <Map<String, String>>[];
    int found = 0;

    for (var i = 0; i < messages.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, messages.length);
      final batch = messages.sublist(i, end);
      final batchResults = parseTransactionMessages(convertSmsMessages(batch));
      results.addAll(batchResults);
      found += batchResults.length;
      onProgress?.call(end, messages.length, found);
      if (i % (batchSize * 5) == 0) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    return results;
  }

  double _getTotalAmount(List<Map<String, String>> messages, String type) =>
      messages
          .where((msg) => msg['type'] == type && msg['amount'] != 'Unknown')
          .map((msg) => double.tryParse(msg['amount']!) ?? 0.0)
          .fold(0.0, (sum, amt) => sum + amt);

  double getTotalCreditedAmount(List<Map<String, String>> messages) =>
      _getTotalAmount(messages, 'Credit');

  double getTotalDebitedAmount(List<Map<String, String>> messages) =>
      _getTotalAmount(messages, 'Debit');

  double getNetAmount(List<Map<String, String>> messages) =>
      getTotalCreditedAmount(messages) - getTotalDebitedAmount(messages);

  Future<List<Map<String, String>>> parseTransactionMessagesFlexible(
    dynamic messages, {
    int batchSize = 50,
    Function(int processed, int total, int found)? onProgress,
  }) async {
    late final List<Map<String, String>> messageMaps;
    final totalMessages = (messages as List).length;

    if (messages is List<SmsMessage>) {
      messageMaps = convertSmsMessages(messages);
    } else if (messages is List<Map<String, String>>) {
      messageMaps = messages;
    } else {
      throw ArgumentError(
          'Messages must be List<SmsMessage> or List<Map<String, String>>');
    }

    final results = <Map<String, String>>[];
    int found = 0;

    for (var i = 0; i < messageMaps.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, messageMaps.length);
      final batch = messageMaps.sublist(i, end);
      final batchResults = parseTransactionMessages(batch);
      results.addAll(batchResults);
      found += batchResults.length;
      onProgress?.call(end, totalMessages, found);
      if (i % (batchSize * 5) == 0) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    return results;
  }
}
