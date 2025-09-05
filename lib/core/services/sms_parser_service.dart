// sms_parser_service.dart
import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:intl/intl.dart';

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
    r'((Rs\.?|INR)\s*[\d,]+(?:\.\d{1,2})?\s*(credited|received|deposited|added|debited|sent|withdrawn|paid|deducted|spent|transferred))|'
    r'((credited|received|deposited|added|debited|sent|withdrawn|paid|deducted|spent|transferred)\s*(?:to|in|from|out)?\s*(?:your\s*)?(?:account|a/c|wallet)?\b.*(Rs\.?|INR)\s*[\d,.]+)',
    caseSensitive: false,
  );
  static final RegExp _amountPattern = RegExp(
    r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // static final RegExp _datePattern = RegExp(
  //   r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{1,2}[A-Za-z]{3}\d{2,4})',
  //   caseSensitive: false,
  // );

  // Account number patterns for different banks - focusing on receiver account
  static final RegExp _receiverAccountPattern = RegExp(
    r'(?:a/c|account|acc)\s*(?:no|number|#)?\s*[:\-]?\s*(?:XX)?(\d{4,19})',
    caseSensitive: false,
  );
  static final RegExp _balancePattern = RegExp(
    r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _lastFourDigitsPattern = RegExp(
    r'(?:card|account|a/c)\s*(?:ending|no|number|#)?\s*(?:with|in|on)?\s*(?:last|ending)?\s*(?:digits|numbers)?\s*[:\-]?\s*(?:XX)?(\d{4})',
    caseSensitive: false,
  );

  // Pattern to find receiver account in transaction messages
  static final RegExp _receiverAccountInBodyPattern = RegExp(
    r'(?:credited|received|credit|deposited|added|debited|sent|withdrawn|paid|deducted|spent|transferred)'
    r'\s*(?:to|in|from|out)?\s*(?:your\s*)?(?:account|a/c|wallet)?\s*(?:no|number|#)?\s*[:\-]?\s*(\d{4,19})',
    caseSensitive: false,
  );

  // Pattern to find "your account" references
  static final RegExp _yourAccountPattern = RegExp(
    r'(?:your\s+)?(?:account|a/c|acc)\s*(?:no|number|#)?\s*[:\-]?\s*(\d{4,19})',
    caseSensitive: false,
  );

  // Pattern to find account numbers in bank-specific formats
  static final RegExp _bankAccountPattern = RegExp(
    r'(?:AC|A/C|Account)\s*([A-Z0-9]{4,19})',
    caseSensitive: false,
  );

  // Pattern to find account numbers after bank names
  static final RegExp _bankNameAccountPattern = RegExp(
    r'(?:Bank|BK)\s+(?:AC|A/C|Account)?\s*([A-Z0-9]{4,19})',
    caseSensitive: false,
  );

  // Pattern to identify balance SMS messages
  static final RegExp _balanceSmsPattern = RegExp(
    r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*[\d,.]+',
    caseSensitive: false,
  );

  static String _extractUpiIdOrSenderName(String body) {
    final upiRegex = RegExp(r'[\w.\-]+@[\w]+');
    final nameRegex =
        RegExp(r'(?:(?:to|from)\s+)([A-Za-z.\s]+)', caseSensitive: false);

    final upiMatch = upiRegex.firstMatch(body);
    if (upiMatch != null) return upiMatch.group(0)!;

    final nameMatch = nameRegex.firstMatch(body);
    if (nameMatch != null) return nameMatch.group(1)!.trim();

    return 'Unknown';
  }

  static String _extractReceiverAccountNumber(String body) {
    // First try to find bank-specific account formats (like "AC X4034")
    final bankAccountMatch = _bankAccountPattern.firstMatch(body);
    if (bankAccountMatch != null) {
      return bankAccountMatch.group(1) ?? '';
    }

    // Try to find account numbers after bank names
    final bankNameAccountMatch = _bankNameAccountPattern.firstMatch(body);
    if (bankNameAccountMatch != null) {
      return bankNameAccountMatch.group(1) ?? '';
    }

    // Try to find receiver account in transaction context
    final receiverMatch = _receiverAccountInBodyPattern.firstMatch(body);
    if (receiverMatch != null) {
      return receiverMatch.group(1) ?? '';
    }

    // Try to find "your account" references
    final yourAccountMatch = _yourAccountPattern.firstMatch(body);
    if (yourAccountMatch != null) {
      return yourAccountMatch.group(1) ?? '';
    }

    // Try general account number pattern
    final accountMatch = _receiverAccountPattern.firstMatch(body);
    if (accountMatch != null) {
      return accountMatch.group(1) ?? '';
    }

    // Try to find any sequence of 4-19 alphanumeric characters that might be an account number
    // but prioritize those that appear after transaction keywords or bank references
    final alphanumericPattern = RegExp(r'\b([A-Z0-9]{4,19})\b');
    final alphanumericMatches = alphanumericPattern.allMatches(body);

    for (final match in alphanumericMatches) {
      final accountCode = match.group(1) ?? '';
      final beforeText = body.substring(0, match.start).toLowerCase();

      // Check if this appears after transaction-related keywords or bank references
      if (beforeText.contains('credited') ||
          beforeText.contains('debited') ||
          beforeText.contains('account') ||
          beforeText.contains('a/c') ||
          beforeText.contains('your') ||
          beforeText.contains('bank') ||
          beforeText.contains('ac ')) {
        return accountCode;
      }
    }

    return '';
  }

  static String _extractLastFourDigits(String body) {
    final lastFourMatch = _lastFourDigitsPattern.firstMatch(body);
    if (lastFourMatch != null) {
      return lastFourMatch.group(1) ?? '';
    }

    // Try to extract from receiver account number if available
    final accountNumber = _extractReceiverAccountNumber(body);
    if (accountNumber.length >= 4) {
      return accountNumber.substring(accountNumber.length - 4);
    }

    return '';
  }

  static double _extractBalance(String body) {
    final balanceMatch = _balancePattern.firstMatch(body);
    if (balanceMatch != null) {
      final balanceStr = balanceMatch.group(1)?.replaceAll(',', '') ?? '';
      return double.tryParse(balanceStr) ?? 0.0;
    }
    return 0.0;
  }

  static String _getCategoryByUpiOrSender(String type, String upiOrName) {
    final key = upiOrName.toLowerCase();

    for (final keyword in CategoryKeyWord.upiKeywordCategoryMapping.keys) {
      if (key.contains(keyword)) {
        return CategoryKeyWord.upiKeywordCategoryMapping[keyword]!;
      }
    }

    return 'Miscellaneous';
  }

  static final Map<String, String> _bankMapping = {
    'HDFCBK': 'HDFC Bank',
    'SBIN': 'State Bank of India',
    'ICICIB': 'ICICI Bank',
    'AXISBK': 'Axis Bank',
    'AXIS': 'Axis Bank',
    'AXISB': 'Axis Bank',
    'KOTAKB': 'Kotak Mahindra Bank',
    'KOTAK': 'Kotak Mahindra Bank',
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
    'SBIINB': 'State Bank of India',
    'PNBSMS': 'Punjab National Bank',
    'IDFCFB': 'IDFC First Bank',
    'BOIIND': 'Bank of India',
    'UNIONS': 'Union Bank',
    'FEDBNK': 'Federal Bank',
    'MAHABK': 'Bank of Maharashtra',
    'CBSSBI': 'SBI CBS',
    'BARBNK': 'Bank of Baroda',
    'UJJIVN': 'Ujjivan Bank',
    'PAYTMB': 'Paytm Payments Bank',
    'AIRTEL': 'Airtel Payments Bank',
    'NSDL': 'NSDL Payments Bank',
    'FINSER': 'Bajaj Finserv',
    'KARBAN': 'Karnataka Bank',
    'DCBBNK': 'DCB Bank',
    'SURYOD': 'Suryoday Bank',
    'RBLBNK': 'RBL Bank',
    'AUFINS': 'AU Small Finance Bank',
    'FINO': 'Fino Payments Bank',
    'CASHP': 'Cashfree',
    'JIOBNK': 'Jio Payments Bank',
    'NBINBK': 'NBFC',
  };

  static String _getBankName(String sender) {
    final upperSender = sender.toUpperCase();
    final bankCodeMatch =
        RegExp(r'^[A-Z]{2,3}-([A-Z]+)-?[A-Z]?$').firstMatch(upperSender);
    final bankCode = bankCodeMatch?.group(1) ?? upperSender;
    return _bankMapping[bankCode] ?? bankCode;
  }

  // Helper method to extract bank name from SMS body as well
  static String _extractBankFromBody(String body) {
    final lowerBody = body.toLowerCase();

    // Check for bank names in the SMS body
    for (final entry in _bankMapping.entries) {
      final bankCode = entry.key.toLowerCase();
      final bankName = entry.value.toLowerCase();

      if (lowerBody.contains(bankCode) || lowerBody.contains(bankName)) {
        return entry.value;
      }
    }

    // Additional checks for common bank name variations
    if (lowerBody.contains('axis')) {
      return 'Axis Bank';
    }
    if (lowerBody.contains('hdfc')) {
      return 'HDFC Bank';
    }
    if (lowerBody.contains('icici')) {
      return 'ICICI Bank';
    }
    if (lowerBody.contains('kotak')) {
      return 'Kotak Mahindra Bank';
    }
    if (lowerBody.contains('sbi') || lowerBody.contains('state bank')) {
      return 'State Bank of India';
    }
    if (lowerBody.contains('pnb') || lowerBody.contains('punjab national')) {
      return 'Punjab National Bank';
    }
    if (lowerBody.contains('bob') || lowerBody.contains('bank of baroda')) {
      return 'Bank of Baroda';
    }

    return '';
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

    // Contextual fallback
    if (lowerBody.contains('from')) return 'Credit';
    if (lowerBody.contains('to')) return 'Debit';

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
      final String date = message['date'] ?? "";

      final amountMatch = _amountPattern.firstMatch(body);
      // final dateMatch = _datePattern.firstMatch(body);
      final parseDate = date.isEmpty
          ? null
          : DateTime.fromMillisecondsSinceEpoch(int.parse(date));

      final type = _getTransactionType(body);
      final upiIdOrName = _extractUpiIdOrSenderName(body);
      final category = _getCategoryByUpiOrSender(type, upiIdOrName);
      final accountNumber = _extractReceiverAccountNumber(body);
      final lastFourDigits = _extractLastFourDigits(body);
      final balance = _extractBalance(body);

      // Try to get bank name from body first, then fallback to sender
      String bankName = _extractBankFromBody(body);
      if (bankName.isEmpty) {
        bankName = _getBankName(sender);
      }

      // Create a unique ID for the transaction
      final transactionId = '${body.hashCode}_$parseDate';

      return {
        'id': transactionId,
        'amount': amountMatch?.group(1)?.replaceAll(',', '') ?? 'Unknown',
        'date': date.isEmpty ? 'Unknown' : date,
        'bank': bankName,
        'type': type,
        'sender': sender,
        'body': body,
        'upiIdOrSenderName': upiIdOrName,
        'category': category,
        'accountNumber': accountNumber,
        'lastFourDigits': lastFourDigits,
        'balance': balance.toString(),
      };
    }).toList();
  }

  // New method to generate account summaries
  List<Map<String, dynamic>> generateAccountSummaries(
      List<Map<String, dynamic>> messages) {
    final Map<String, Map<String, dynamic>> accountMap = {};

    for (final message in messages) {
      final bank = message['bank'] ?? 'Unknown Bank';
      String accountNumber = message['accountNumber'] ?? '';
      String lastFourDigits = message['lastFourDigits'] ?? '';
      final amount = double.tryParse(message['amount'] ?? '0') ?? 0.0;
      final type = message['type'] ?? 'Unknown';
      final balance = double.tryParse(message['balance'] ?? '0') ?? 0.0;
      final body = message['body'] ?? '';

      // Check if this is a balance SMS
      final isBalanceSms = _balanceSmsPattern.hasMatch(body.toLowerCase());

      // Create a unique key for each account - prioritize account number if available
      String accountKey;
      if (accountNumber.isNotEmpty) {
        // Use account number as primary key
        accountKey = accountNumber
            .replaceAll("X", '')
            .replaceAll('x', ''); // use normalized digits
      } else if (lastFourDigits.isNotEmpty) {
        // Use bank + last four digits as fallback
        accountKey = '$bank-$lastFourDigits';
      } else {
        // Use bank name as final fallback
        accountKey = bank;
      }

      // Normalize the account key to handle variations
      accountKey = accountKey.toUpperCase().trim();

      if (!accountMap.containsKey(accountKey)) {
        accountMap[accountKey] = {
          'bank': bank,
          'accountNumber': accountNumber,
          'lastFourDigits': lastFourDigits,
          'totalCredits': 0.0,
          'totalDebits': 0.0,
          'currentBalance': 0.0,
          'transactionCount': 0,
          'lastTransactionDate': '',
          'lastTransactionAmount': 0.0,
          'hasBalanceSms': false,
        };
      }

      final account = accountMap[accountKey]!;

      // If this is a balance SMS, update the balance and mark that we have balance info
      if (isBalanceSms && balance > 0) {
        account['currentBalance'] = balance;
        account['hasBalanceSms'] = true;
      }

      // Only count transaction amounts for non-balance SMS
      if (!isBalanceSms && type != 'Unknown') {
        if (type == 'Credit') {
          account['totalCredits'] =
              (account['totalCredits'] as double) + amount;
        } else if (type == 'Debit') {
          account['totalDebits'] = (account['totalDebits'] as double) + amount;
        }

        account['transactionCount'] = (account['transactionCount'] as int) + 1;

        // Update last transaction info
        final messageDate = message['date'] ?? '';
        if (messageDate.isNotEmpty) {
          account['lastTransactionDate'] = messageDate;
          account['lastTransactionAmount'] = amount;
        }
      }
    }

    // Convert to list and calculate net balance
    final allAccounts = accountMap.values.map((account) {
      final totalCredits = account['totalCredits'] as double;
      final totalDebits = account['totalDebits'] as double;
      // final currentBalance = account['currentBalance'] as double;
      final hasBalanceSms = account['hasBalanceSms'] as bool;

      // If we have balance SMS, use that balance
      // Otherwise, estimate it from transactions
      // final estimatedBalance =
      //     hasBalanceSms ? currentBalance : totalCredits - totalDebits;

      return {
        ...account,
        'totalReceived': totalCredits,
        'totalSpent': totalDebits,
        'hasBalanceSms': hasBalanceSms,
      };
    }).toList();
    // Filter out accounts with insufficient data
    return allAccounts.where((account) {
      final transactionCount = account['transactionCount'] as int;
      final netBalance = account['totalReceived'] as double;
      final totalSpent = account['totalSpent'] as double;
      final hasBalanceSms = account['hasBalanceSms'] as bool;

      // Exclude accounts with:
      // 1. Zero or one transaction (insufficient data)
      // 2. Balance equals spent amount (incomplete data)
      // 3. No transactions and no balance SMS (no data)
      // 4. Zero balance (no funds)

      if (transactionCount <= 1 && !hasBalanceSms) {
        return false; // Zero or one transaction without balance SMS
      }

      if (transactionCount > 0 && (netBalance - totalSpent).abs() < 0.01) {
        return false; // Balance equals spent amount (incomplete data)
      }

      if (transactionCount == 0 && hasBalanceSms) {
        return false; // No transactions and no balance SMS
      }

      // Exclude accounts with zero or negative balance (unless it's a credit card or loan account)
      // if (netBalance <= 0 && !hasBalanceSms) {
      //   return false; // Zero or negative balance without balance SMS
      // }

      return true; // Keep accounts with sufficient data
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

  double _getTotalAmount(List<Map<String, dynamic>> messages, String type) =>
      messages
          .where((msg) => msg['type'] == type && msg['amount'] != 'Unknown')
          .map((msg) => double.tryParse(msg['amount']!) ?? 0.0)
          .fold(0.0, (sum, amt) => sum + amt);

  double getTotalCreditedAmount(List<Map<String, dynamic>> messages) =>
      _getTotalAmount(messages, 'Credit');

  double getTotalDebitedAmount(List<Map<String, dynamic>> messages) =>
      _getTotalAmount(messages, 'Debit');

  double getNetAmount(List<Map<String, String>> messages) =>
      getTotalCreditedAmount(messages) - getTotalDebitedAmount(messages);

  // Test method to verify account extraction (for debugging)
  Map<String, String> testAccountExtraction(String smsBody) {
    return {
      'accountNumber': _extractReceiverAccountNumber(smsBody),
      'lastFourDigits': _extractLastFourDigits(smsBody),
      'bankFromBody': _extractBankFromBody(smsBody),
      'balance': _extractBalance(smsBody).toString(),
      'transactionType': _getTransactionType(smsBody),
      'upiIdOrSenderName': _extractUpiIdOrSenderName(smsBody),
    };
  }

  // Debug method to analyze all messages and identify issues
  Map<String, dynamic> debugAccountAnalysis(
      List<Map<String, dynamic>> messages) {
    final Map<String, List<Map<String, dynamic>>> bankGroups = {};
    final List<Map<String, dynamic>> accountsWithIssues = [];

    for (final message in messages) {
      final bank = message['bank'] ?? 'Unknown';
      final accountNumber = message['accountNumber'] ?? '';
      final body = message['body'] ?? '';

      // Group by bank
      if (!bankGroups.containsKey(bank)) {
        bankGroups[bank] = [];
      }
      bankGroups[bank]!.add(message);

      // Identify potential issues
      if (accountNumber.isEmpty && bank != 'Unknown') {
        accountsWithIssues.add({
          'bank': bank,
          'body': body,
          'issue': 'No account number extracted',
        });
      }
    }

    return {
      'totalMessages': messages.length,
      'bankGroups': bankGroups.map((key, value) => MapEntry(key, value.length)),
      'accountsWithIssues': accountsWithIssues,
      'uniqueBanks': bankGroups.keys.toList(),
    };
  }

  Future<List<Map<String, String>>> parseTransactionMessagesFlexible(
    dynamic messages, {
    Function(int processed, int total, int found, String month,
            List<Map<String, String>> results)?
        onProgress,
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

    int found = 0;
    final Map<String, List<Map<String, String>>> messagesByMonth = {};
    // final dateFormat = DateFormat('yyyy-MM-dd');
    final monthKeyFormat = DateFormat('yyyy-MM');

    for (final message in messageMaps) {
      final dateStr = int.parse(message['date'] ?? '');
      // if (dateStr == null) continue;

      try {
        // final date = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(dateStr));
        final monthKey =
            monthKeyFormat.format(DateTime.fromMillisecondsSinceEpoch(dateStr));

        messagesByMonth.putIfAbsent(monthKey, () => []).add(message);
      } catch (e) {
        // Invalid date, skip or handle
        continue;
      }
    }

    // Step 2: Process messages month by month
    for (final entry in messagesByMonth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      final month = entry.key;
      final messages = entry.value;

      final monthResults = parseTransactionMessages(messages);
      found += monthResults.length;

      onProgress?.call(found, totalMessages, found, month, monthResults);

      // Optional: Small delay if needed
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return messageMaps;
  }
}
