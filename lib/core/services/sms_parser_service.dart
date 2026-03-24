import 'dart:convert';
import 'dart:isolate' show Isolate;
import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/constants/app_regexp.dart';
import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/core/parsers/parser_registry.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class SmsParserService {
  SmsParserService._();

  static Set<String> _knownSenders = {};
  static Map<String, String> bankMapping = {};

  static final SmsParserService instance = SmsParserService._();
  
  static final ParserRegistry _registry = ParserRegistry()..initialize();
  static final SmsParserEngine _engine = SmsParserEngine(_registry);

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

  static List<Map<String, String>> parseTransactionMessages(
      List<Map<String, String>> smsMessages) {
    final transactions = _engine.parseMessages(smsMessages);
    
    return transactions.map((tx) {
      final map = tx.toMap();
      final body = tx.rawBody;
      final type = tx.type;
      final upiIdOrName = tx.upiIdOrSenderName;
      final bankName = tx.bank;

      // Category logic
      String category = tx.category;
      if (_isWithdrawalTransaction(body)) {
        category = 'Cash Withdrawal';
      } else if (category == 'Miscellaneous' || category == 'Unknown') {
        category = _getCategoryByUpiOrSender(type, upiIdOrName);
      }

      map['category'] = category;
      map['bank'] = bankName;
      map['upiIdOrSenderName'] = upiIdOrName;
      map['lastFourDigits'] = tx.lastFourDigits;
      map['accountNumber'] = tx.accountNumber;
      
      return map;
    }).toList();
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

      String accountKey;
      if (bank == 'Cash') {
        accountKey = 'Cash';
        accountNumber = '';
        lastFourDigits = '';
      } else if (accountNumber.isNotEmpty && accountNumber != 'Unknown') {
        accountKey = accountNumber
            .replaceAll("X", '')
            .replaceAll('x', ''); 
      } else if (lastFourDigits.isNotEmpty && lastFourDigits != 'Unknown') {
        accountKey = '$bank-$lastFourDigits';
      } else {
        accountKey = bank;
      }

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

      if (isBalanceSms && balance > 0) {
        account['currentBalance'] = balance;
        account['hasBalanceSms'] = true;
      }
      
      if ((account['bank'] == "Cash" || !isBalanceSms) && type != 'Unknown') {
        if (type == 'Credit') {
          account['totalCredits'] =
              (account['totalCredits'] as double) + amount;
          if (bank == 'Cash') {
            account['currentBalance'] =
                (account['currentBalance'] as double) + amount;
          }
        } else if (type == 'Debit') {
          account['totalDebits'] = (account['totalDebits'] as double) + amount;
          if (bank == 'Cash') {
            account['currentBalance'] =
                (account['currentBalance'] as double) - amount;
          }
        }

        account['transactionCount'] = (account['transactionCount'] as int) + 1;

        final messageDate = message['date'] ?? '';
        if (messageDate.isNotEmpty) {
          account['lastTransactionDate'] = messageDate;
          account['lastTransactionAmount'] = amount;
        }
      }
    }

    final allAccounts = accountMap.values.map((account) {
      final totalCredits = account['totalCredits'] as double;
      final totalDebits = account['totalDebits'] as double;
      final hasBalanceSms = account['hasBalanceSms'] as bool;

      return {
        ...account,
        'totalReceived': totalCredits,
        'totalSpent': totalDebits,
        'hasBalanceSms': hasBalanceSms,
      };
    }).toList();

    return allAccounts.where((account) {
      final transactionCount = account['transactionCount'] as int;
      final netBalance = account['totalReceived'] as double;
      final totalSpent = account['totalSpent'] as double;
      final hasBalanceSms = account['hasBalanceSms'] as bool;

      if (account['bank'] == "Cash") return true;
      if (transactionCount <= 1 && !hasBalanceSms) return false;
      if (transactionCount > 0 && (netBalance - totalSpent).abs() < 0.01) return false;
      if (transactionCount == 0 && hasBalanceSms) return false;

      return true;
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
    final monthKeyFormat = DateFormat('yyyy-MM');
    for (final message in transitionMessages) {
      final dateStr = int.parse(message['date'] ?? '');

      try {
        final monthKey =
            monthKeyFormat.format(DateTime.fromMillisecondsSinceEpoch(dateStr));

        messagesByMonth.putIfAbsent(monthKey, () => []).add(message);
      } catch (e) {
        continue;
      }
    }

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
    final buffer = StringBuffer();

    for (var cp in input.runes) {
      String? replacement;

      if (cp >= 0x1D7CE && cp <= 0x1D7D7) {
        replacement = String.fromCharCode('0'.codeUnitAt(0) + (cp - 0x1D7CE));
      }
      else if (cp >= 0x1D7E2 && cp <= 0x1D7EB) {
        replacement = String.fromCharCode('0'.codeUnitAt(0) + (cp - 0x1D7E2));
      }
      else if (cp >= 0x1D400 && cp <= 0x1D419) {
        replacement = String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D400));
      } else if (cp >= 0x1D434 && cp <= 0x1D44D) {
        replacement = String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D434));
      } else if (cp >= 0x1D504 && cp <= 0x1D51C) {
        replacement = String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D504));
      } else if (cp >= 0x1D5A0 && cp <= 0x1D5B9) {
        replacement = String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D5A0));
      } else if (cp >= 0x1D56C && cp <= 0x1D585) {
        replacement = String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D56C));
      } else if (cp >= 0x1D670 && cp <= 0x1D689) {
        replacement = String.fromCharCode('A'.codeUnitAt(0) + (cp - 0x1D670));
      }
      else if (cp >= 0x1D41A && cp <= 0x1D433) {
        replacement = String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D41A));
      } else if (cp >= 0x1D44E && cp <= 0x1D467) {
        replacement = String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D44E));
      } else if (cp >= 0x1D51E && cp <= 0x1D537) {
        replacement = String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D51E));
      } else if (cp >= 0x1D5BA && cp <= 0x1D5D3) {
        replacement = String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D5BA));
      } else if (cp >= 0x1D586 && cp <= 0x1D59F) {
        replacement = String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D586));
      } else if (cp >= 0x1D68A && cp <= 0x1D6A3) {
        replacement = String.fromCharCode('a'.codeUnitAt(0) + (cp - 0x1D68A));
      }

      buffer.write(replacement ?? String.fromCharCode(cp));
    }

    return buffer.toString();
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
