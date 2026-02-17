import 'dart:convert';
import 'dart:isolate' show Isolate;
import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/constants/app_regexp.dart';
import 'package:dhanra/core/constants/bank_names.dart';
import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class SmsParserService {
  SmsParserService._();

  static Set<String> _knownSenders = {};
  static Map<String, String> bankMapping = {};

  static final SmsParserService instance = SmsParserService._();

  static Map<String, String?> _extractUpiIdOrSenderName(String body) {
    if (body.trim().isEmpty) return {"merchant": null, "upiId": null};

    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();

    String? merchant;
    String? upiId;

    // 1) Extract UPI ID (abc@bank etc.)
    final upiRegex = RegExp(r'\b[\w.\-]+@[a-z0-9.\-]+\b', caseSensitive: false);
    final upiMatch = upiRegex.firstMatch(normalized);
    if (upiMatch != null) {
      upiId = upiMatch.group(0)!;
    }

    // 2) Merchant name after UPI/.../.../NAME
    final upiPathRegex = RegExp(r'UPI\/(?:[A-Za-z0-9_]+\/){1,3}([^\/\n\r]+)',
        caseSensitive: false);
    final upiPathMatch = upiPathRegex.firstMatch(body);
    if (upiPathMatch != null) {
      final cand = _cleanCandidate(upiPathMatch.group(1)!);
      if (cand.isNotEmpty && !_looksLikeAccount(cand)) merchant = cand;
    }

    // 3) Merchant name after keywords (to|from|at)
    if (merchant == null) {
      final nameAfterRegex = RegExp(
          r'(?:(?:\bto\b|\bfrom\b|\bat\b)\s+)([A-Za-z0-9&.\-\ ]{2,50})',
          caseSensitive: false);
      final nameAfterMatch = nameAfterRegex.firstMatch(normalized);
      if (nameAfterMatch != null) {
        final cand = _cleanCandidate(nameAfterMatch.group(1)!);
        // If candidate contains '@' → it’s a UPI ID
        if (cand.contains('@')) {
          upiId ??= cand;
        } else if (!_looksLikeAccount(cand)) {
          merchant = cand;
        }
      }
    }

    // 4) If still no merchant but we have UPI → use its left part as merchant
    if (merchant == null && upiId != null) {
      merchant = upiId.split('@').first;
    }

    // 5) Merchant from NEFT/IMPS/RTGS info
    if (merchant == null) {
      final neftRegex = RegExp(
          r'(?:NEFT|IMPS|RTGS)\/[A-Z0-9]+\/([A-Za-z0-9 &.\-]+)',
          caseSensitive: false);
      final neftMatch = neftRegex.firstMatch(normalized);
      if (neftMatch != null) {
        final cand = _cleanCandidate(neftMatch.group(1)!);
        if (cand.isNotEmpty && !_looksLikeAccount(cand)) merchant = cand;
      }
    }

    return {
      "merchant": merchant,
      "upiId": upiId,
    };
  }

  static String _cleanCandidate(String s) {
    var out = s.trim();
    out = out.replaceAll(RegExp(r'[\.,;:/\-]+$'), '');
    return out.trim();
  }

  static bool _looksLikeAccount(String s) {
    final t = s.trim();
    if (RegExp(r'^(?:xx|x)[0-9]{2,}$', caseSensitive: false).hasMatch(t)) {
      return true;
    }
    if (RegExp(r'^(?:a\/?c|acct|account)\b', caseSensitive: false)
        .hasMatch(t)) {
      return true;
    }
    if (RegExp(r'^[0-9\-\s]{1,}$').hasMatch(t)) return true;
    return false;
  }

  static Future<void> loadSenders() async {
    final jsonStr =
        await rootBundle.loadString('assets/json/list_sms_headers.json');
    final jsonData = jsonDecode(jsonStr);
    _knownSenders = Set<String>.from(
        jsonData.map((s) => s['Header'].toString().toUpperCase()));
    bankMapping = {
      for (var item in jsonData)
        item['Header'].toString().toUpperCase(): item['Name'].toString()
    };
  }

  static bool senderMatches(String sender) {
    final normalized = sender.toUpperCase();
    return _knownSenders.any(
      (prefix) =>
          normalized.startsWith(prefix) || normalized.contains('-$prefix'),
    );
  }

  static String? extractAccountLast4(String message) {
    final match = AppRegexp.fourDigitAccountRegex.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  static String? extractFullAccountNumber(String sms) {
    final match = AppRegexp.fullAccountRegex.firstMatch(sms);
    if (match != null) {
      return match.group(1);
    }

    return null;
  }

  static double _extractBalance(String body) {
    final balanceMatch = AppRegexp.balancePattern.firstMatch(body);
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

  static String _getBankName(String sender) {
    final upperSender = sender.toUpperCase();

    final bankCodeMatch =
        RegExp(r'^[A-Z]{2,3}-([A-Z]+)(?:-[A-Z])?$').firstMatch(upperSender);
    final bankCode = bankCodeMatch?.group(1) ?? upperSender;

    return BankNames.bankMapping[bankCode] ?? bankCode;
  }

// Helper method to extract bank name from SMS body as well
  static String _extractBankFromBody(String body) {
    final lowerBody = body.toLowerCase();

    // First: direct match with codes/names in _bankMapping
    for (final entry in BankNames.bankMapping.entries) {
      final bankCode = entry.key.toLowerCase();
      final bankName = entry.value.toLowerCase();

      if (lowerBody.contains(bankCode) || lowerBody.contains(bankName)) {
        return entry.value;
      }
    }

    // Second: handle additional variations/synonyms
    if (lowerBody.contains('axis')) return 'Axis Bank';
    if (lowerBody.contains('hdfc')) return 'HDFC Bank';
    if (lowerBody.contains('icici')) return 'ICICI Bank';
    if (lowerBody.contains('kotak')) return 'Kotak Mahindra Bank';
    if (lowerBody.contains('sbi') || lowerBody.contains('state bank')) {
      return 'State Bank of India';
    }
    if (lowerBody.contains('pnb') || lowerBody.contains('punjab national')) {
      return 'Punjab National Bank';
    }
    if (lowerBody.contains('bob') || lowerBody.contains('bank of baroda')) {
      return 'Bank of Baroda';
    }
    if (lowerBody.contains('canara')) return 'Canara Bank';
    if (lowerBody.contains('union')) return 'Union Bank of India';
    if (lowerBody.contains('yes')) return 'Yes Bank';
    if (lowerBody.contains('idfc')) return 'IDFC First Bank';
    if (lowerBody.contains('indus')) return 'IndusInd Bank';
    if (lowerBody.contains('paytm')) return 'Paytm Payments Bank';
    if (lowerBody.contains('bhim')) return 'BHIM UPI';
    if (lowerBody.contains('gpay') || lowerBody.contains('google pay')) {
      return 'Google Pay';
    }
    if (lowerBody.contains('phonepe')) return 'PhonePe';
    if (lowerBody.contains('amazon pay') || lowerBody.contains('amznpay')) {
      return 'Amazon Pay';
    }
    if (lowerBody.contains('boi') || lowerBody.contains('bank of india')) {
      return 'Bank of India';
    }
    if (lowerBody.contains('federal')) return 'Federal Bank';
    if (lowerBody.contains('maharashtra')) return 'Bank of Maharashtra';
    if (lowerBody.contains('karur') || lowerBody.contains('karban')) {
      return 'Karnataka Bank';
    }
    if (lowerBody.contains('ujjivan')) return 'Ujjivan Bank';
    if (lowerBody.contains('airtel')) return 'Airtel Payments Bank';
    if (lowerBody.contains('nsdl')) return 'NSDL Payments Bank';
    if (lowerBody.contains('bajaj')) return 'Bajaj Finserv';
    if (lowerBody.contains('dcb')) return 'DCB Bank';
    if (lowerBody.contains('suryoday')) return 'Suryoday Bank';
    if (lowerBody.contains('rbl')) return 'RBL Bank';
    if (lowerBody.contains('au small') || lowerBody.contains('aufins')) {
      return 'AU Small Finance Bank';
    }
    if (lowerBody.contains('fino')) return 'Fino Payments Bank';
    if (lowerBody.contains('cashfree') || lowerBody.contains('cashp')) {
      return 'Cashfree';
    }
    if (lowerBody.contains('jio')) return 'Jio Payments Bank';
    if (lowerBody.contains('nbfc') || lowerBody.contains('nbinbk')) {
      return 'NBFC';
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

  static bool _isWithdrawalTransaction(String body) {
    final lowerBody = body.toLowerCase();
    const withdrawalKeywords = [
      'withdrawn',
      'withdrawal',
      'cash withdrawal',
      'atm withdrawal',
      'cash dispensed',
      'withdraw',
      'cash out'
    ];

    return withdrawalKeywords.any(lowerBody.contains);
  }

  static List<Map<String, String>> parseTransactionMessages(
      List<Map<String, String>> smsMessages) {
    return smsMessages.map((message) {
      final sender = message['sender']!.toUpperCase();
      final body = message['body']!;
      final String date = message['date'] ?? "";

      final amountMatch = AppRegexp.amountPattern.firstMatch(body);
      // final dateMatch = _datePattern.firstMatch(body);
      final parseDate = date.isEmpty
          ? null
          : DateTime.fromMillisecondsSinceEpoch(int.parse(date));

      final type = _getTransactionType(body);
      final data = _extractUpiIdOrSenderName(body);
      final upiIdOrName = data["upiId"] ?? data["merchant"] ?? "Unkown";

      // Set category based on transaction type
      String category;
      if (_isWithdrawalTransaction(body)) {
        category = 'Cash Withdrawal';
      } else {
        category = _getCategoryByUpiOrSender(type, upiIdOrName);
      }
      String bankName;
      if (_isWithdrawalTransaction(body)) {
        bankName = 'Cash';
      } else {
        // Try to get bank name from body first, then fallback to sender
        bankName = _extractBankFromBody(body);
        if (bankName.isEmpty) {
          bankName = _getBankName(sender);
        }
      }

      final accountNumber = extractFullAccountNumber(body) ??
          (bankName == 'Cash' ? '' : "Unkown");
      final lastFourDigits =
          extractAccountLast4(body) ?? (bankName == 'Cash' ? '' : "Unkown");
      final balance = _extractBalance(body);

      // Create a unique ID for the transaction
      final transactionId = '${body.hashCode}_$parseDate';
      final isBalanceSms =
          AppRegexp.balanceSmsPattern.hasMatch(body.toLowerCase());

      return {
        'id': transactionId,
        'amount': amountMatch?.group(1)?.replaceAll(',', '') ?? 'Unknown',
        'date': date.isEmpty ? 'Unknown' : date,
        'bank': bankName,
        'type': type,
        'sender': sender,
        'body': "[$sender] $body",
        'upiIdOrSenderName': upiIdOrName,
        'category': category,
        'accountNumber': accountNumber,
        'lastFourDigits': lastFourDigits,
        'balance': balance.toString(),
        'hasBalanceSms': isBalanceSms.toString(),
      };
    }).toList();
  }

  // New method to generate account summaries
  static List<Map<String, dynamic>> generateAccountSummaries(
      List<Map<String, dynamic>> messages) {
    final Map<String, Map<String, dynamic>> accountMap = {};

    for (final message in messages) {
      final bank = message['bank'] ?? 'Unknown Bank';
      String accountNumber = message['accountNumber'] ?? '';
      String lastFourDigits = message['lastFourDigits'] ?? '';
      final amount = double.tryParse(message['amount'] ?? '0') ?? 0.0;
      final type = message['type'] ?? 'Unknown';
      final balance = double.tryParse(message['balance'] ?? '0') ?? 0.0;
      final isBalanceSms = message['hasBalanceSms'] == 'true';

      // Check if this is a balance SMS

      // Create a unique key for each account - prioritize account number if available
      String accountKey;
      if (bank == 'Cash') {
        // Consolidate all cash transactions into a single Cash account
        accountKey = 'Cash';
        accountNumber = '';
        lastFourDigits = '';
      } else if (accountNumber.isNotEmpty) {
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
      if ((account['bank'] == "Cash" || !isBalanceSms) && type != 'Unknown') {
        if (type == 'Credit') {
          account['totalCredits'] =
              (account['totalCredits'] as double) + amount;
          // For Cash bank, increase current balance on credit
          if (bank == 'Cash') {
            account['currentBalance'] =
                (account['currentBalance'] as double) + amount;
          }
        } else if (type == 'Debit') {
          account['totalDebits'] = (account['totalDebits'] as double) + amount;
          // For Cash bank, decrease current balance on debit
          if (bank == 'Cash') {
            account['currentBalance'] =
                (account['currentBalance'] as double) - amount;
          }
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

      if (account['bank'] == "Cash") {
        return true;
      }

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

  static List<Map<String, String>> convertSmsMessages(
          List<SmsMessage> messages) =>
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

    List<Map<String, String>> transitionMessages =
        await _filterMessagesInIsolate(messageMaps, _knownSenders);

    int found = 0;
    final Map<String, List<Map<String, String>>> messagesByMonth = {};
    // final dateFormat = DateFormat('yyyy-MM-dd');
    final monthKeyFormat = DateFormat('yyyy-MM');
    for (final message in transitionMessages) {
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

      final monthResults = await _parseMonthInIsolate(messages);
      monthResults.removeWhere((d) =>
          d['amount'] == 'Unknown' ||
          d['lastFourDigits'] == "Unkown" ||
          d['hasBalanceSms'] == "true");
      found += monthResults.length;

      onProgress?.call(
          found, transitionMessages.length, totalMessages, month, monthResults);
    }
    return transitionMessages;
  }

  static Future<List<Map<String, String>>> _parseMonthInIsolate(
      List<Map<String, String>> messages) async {
    return await Isolate.run(() => parseTransactionMessages(messages));
  }

  static Future<List<Map<String, String>>> _filterMessagesInIsolate(
      List<Map<String, String>> messageMaps, Set<String> knownSenders) async {
    return await Isolate.run(() {
      return messageMaps.where((message) {
        final sender = message['sender']?.toUpperCase() ?? '';
        final body = message['body']?.toLowerCase() ?? '';
        if (AppRegexp.excludePattern.hasMatch(body)) {
          return false;
        }
        // Re-implementing senderMatches locally for the isolate
        final normalized = sender.toUpperCase();
        final matches = knownSenders.any(
          (prefix) =>
              normalized.startsWith(prefix) || normalized.contains('-$prefix'),
        );

        return matches &&
            AppRegexp.transactionPattern
                .hasMatch(instance.normalizeFancyText(body).toLowerCase());
      }).toList();
    });
  }

  String normalizeFancyText(String input) {
    // Normalizes many "mathematical alphanumeric" fancy unicode letters/digits back to ASCII.
    // Covers the common blocks used in SMS (bold, italic, sans, fraktur, monospace, digits)
    final buffer = StringBuffer();

    for (var cp in input.runes) {
      String? replacement;

      // Bold digits 0-9
      if (cp >= 0x1D7CE && cp <= 0x1D7D7) {
        replacement = String.fromCharCode('0'.codeUnitAt(0) + (cp - 0x1D7CE));
      }
      // Sans-serif digits 0-9
      else if (cp >= 0x1D7E2 && cp <= 0x1D7EB) {
        replacement = String.fromCharCode('0'.codeUnitAt(0) + (cp - 0x1D7E2));
      }

      // Uppercase A-Z blocks (multiple styled blocks)
      else if (cp >= 0x1D400 && cp <= 0x1D419) {
        replacement = String.fromCharCode(
            'A'.codeUnitAt(0) + (cp - 0x1D400)); // MATHEMATICAL BOLD
      } else if (cp >= 0x1D434 && cp <= 0x1D44D) {
        replacement = String.fromCharCode(
            'A'.codeUnitAt(0) + (cp - 0x1D434)); // MATHEMATICAL ITALIC
      } else if (cp >= 0x1D504 && cp <= 0x1D51C) {
        replacement =
            String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D504)); // FRAKTUR
      } else if (cp >= 0x1D5A0 && cp <= 0x1D5B9) {
        replacement = String.fromCharCode(
            'A'.codeUnitAt(0) + (cp - 0x1D5A0)); // SANS-SERIF
      } else if (cp >= 0x1D56C && cp <= 0x1D585) {
        replacement = String.fromCharCode(
            'A'.codeUnitAt(0) + (cp - 0x1D56C)); // SANS-SERIF BOLD
      } else if (cp >= 0x1D670 && cp <= 0x1D689) {
        replacement = String.fromCharCode(
            'A'.codeUnitAt(0) + (cp - 0x1D670)); // MONOSPACE
      }

      // Lowercase a-z blocks
      else if (cp >= 0x1D41A && cp <= 0x1D433) {
        replacement =
            String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D41A)); // bold
      } else if (cp >= 0x1D44E && cp <= 0x1D467) {
        replacement =
            String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D44E)); // italic
      } else if (cp >= 0x1D51E && cp <= 0x1D537) {
        replacement =
            String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D51E)); // fraktur
      } else if (cp >= 0x1D5BA && cp <= 0x1D5D3) {
        replacement = String.fromCharCode(
            'a'.codeUnitAt(0) + (cp - 0x1D5BA)); // sans-serif
      } else if (cp >= 0x1D586 && cp <= 0x1D59F) {
        replacement = String.fromCharCode(
            'a'.codeUnitAt(0) + (cp - 0x1D586)); // sans-serif bold
      } else if (cp >= 0x1D68A && cp <= 0x1D6A3) {
        replacement = String.fromCharCode(
            'a'.codeUnitAt(0) + (cp - 0x1D68A)); // monospace
      }

      // If we didn't map it, keep original char
      buffer.write(replacement ?? String.fromCharCode(cp));
    }

    return buffer.toString();
  }
}

class BankInfo {
  final String header;
  final String name;

  BankInfo({required this.header, required this.name});

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      header: json['Header'],
      name: json['Name'],
    );
  }
}

final smsList = [
  "ICICI Bank Acct XX741 debited for Rs 300.00 on 30-Jul-25; Uma Petroleum credited. UPI:521191835483. Call 18002662 for dispute. SMS BLOCK 741 to 9215676766.",
  "Dear SBI User, your A/c X8732-credited by Rs.8000 on 31Aug25 transfer from RAJESHSARAGADAM Ref No 084718897182 -SBI",
  '''INR 50000.00 credited
A/c no. XX2057
02-09-25, 16:02:45 IST
UPI/P2A/524565742400/KIKANI MA/ICICI Ban - Axis Bank''',
  '''INR 50000.00 debited
A/c no. XX2057
02-09-25, 16:27:59
UPI/P2A/561121815830/KIKANI MANSIBEN BHA
Not you? SMS BLOCKUPI Cust ID to 919951860002
Axis Bank

''',
  "Sent Rs.22.00 from Kotak Bank AC X4034 to dmartavenuesupermart.41116152@hdfcbank on 01-09-25.UPI Ref 561024161196. Not you, https://kotak.com/KBANKT/Fraud",
  "You've spent Rs.500.00 thru Kotak Bank Debit Card XX3983 at GOOGLESERVIS on 01/03/2024 Avl bal 5130.67 Not you?Visit kotak.com/fraud",
  "Dear Customer, Your A/c xxx0003652 debited Rs.8300 by UPI/001913816303. Clear Balance is Rs.22128.18 Date.11/05/25. If not done by you send SMS to Stop Debit Tnx. in your ACCOUNT, <VARA> <NODEBIT> <LAST_7_DIGIT_A/C_NUMBER> to 9133574000 or Call 18002587750. VARACHHABANK",
  "VARACHHABANK A/c *3652 is CREDITED by UPI of Rs.10000 on 03/09/25 12:54 PM Ref. UPI/CR/561265200331/VARACHHABANK Your A/c **3652 is DEBITED Rs.160000 by Cash with CHQ 6 Clear Balance is Rs.11957.38",
  "Dear Customer, Your NEFT of Rs 77,500.00 with UTR SBIN325126177342 DTD 06/05/2025 credited to Beneficiary AC NO. XX5741 at ICIC0000052 on 06/05/2025 at 09:06 AM.-SBI",
  "Dear Customer, Your A/c XX8732 has been debited with INR 77,500.00 on 06/05/2025 towards NEFT with UTR SBIN325126177342 sent to Manu Kikani ICIC0000052-SBI",
  "Update! INR 12,345.00 deposited in HDFC Bank A/c XX5900 on 01-JUL-25 for NEFT Cr-INDB0000006-SMART SHIP HUB DIGITAL INDIA PRIVATE LIMITED-SARVESH  RAJENDRA RANSUBHE-INDBN52025070100394100.Avl bal INR 69,696.79. Cheque deposits in A/C are subject to clearing",
  '''Sent Rs.3000.00
From HDFC Bank A/C *5900
To SARVESH RAJENDRA RANSUBHE
On 29/06/25
Ref 107223161170
Not You?
Call 18002586161/SMS BLOCK UPI to 7308080808''',
  "INR 4,655.00 is debited to your Account XXXXXX3145 on 02/07/2025 towards NACH-10-IDFCFIRSTBANKLIMITE Kotak Bank",
  '''INR 99000.00 credited
A/c no. XX2057
16-06-25, 10:27:44 IST
UPI/P2A/724125670472/SURANI DI/Kotak Mah - Axis Bank''',
  "Your Account XXXXX54270 has been Credited with RS.2000 on 19/06/2024 at 07:02:53.Info: PM KISAN SAMMAN NIDHI YOJNA.Current balance is Rs.3536.91CRSUDICO",
  "NEFT transaction with reference number SDCBN24107108991 for Rs 200000 has been credited to the beneficiary account on 16/04/2024 SUDICO",
  "IRCTC CF has requested money from you on Google Pay. On approving the request, INR 242.75 will be debited from your A/c - Axis Bank",
  "IMPORTANT! Bill of Rs. 125 for your Airtel Wi-Fi ID 02614609230 was due on 28-MAR-25 . Please pay immediately to avoid service interruption. Click i.airtel.in/BBpayBills to pay. Ignore if already paid. To view your bill, click i.airtel.in/Previous-bills",
  "Hi, bill of Rs. 125 for your Airtel Wi-Fi ID 02614609230 is due on 28-MAR-25 . Pay instantly using Airtel Thanks App i.airtel.in/BBpayBills . Ignore if already paid. To view your bill, click i.airtel.in/Previous-bills",
  "Dear Customer, your business capital is ready! Complete KYC & get a pre-approved Kotak Business Loan of Rs.147000! Tap: https://1.kmbl.in/KOTAKB/JiG3W6 TCA",
  "INDMONEY PRIVATE LIMITED on 30-08-25 reported your Fund bal Rs.87.6 & Securities bal 0. This excludes your Bank, DP & PMS bal with the broker-NSE",
  "CDSL: Debit in a/c *52314532 for 3-ONGC-EQ-RS.5/-, 34-SCHLOSS BANGALORE-EQ on 04SEP",
  "Dear Customer, you could have earned rewards on your purchase of Rs. 308 with a Pre-approved Kotak Credit Card! Get it now https://1.kmbl.in/D8JlKZ T&C",
  "Dear Devarsh, fulfil your cravings with Zomato! Get up to Rs.250 off monthly with Kotak Debit Cards from Fri to Sun. T&C https://1.kmbl.in/D-XyNc",
];
