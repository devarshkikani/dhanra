import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _SmsCase {
  final String name;
  final int smsIndex;
  final String sender;
  final String amount;
  final String type;
  final String? merchant;
  final String? category;
  final String bank;

  const _SmsCase({
    required this.name,
    required this.smsIndex,
    required this.sender,
    required this.amount,
    required this.type,
    required this.bank,
    this.merchant,
    this.category,
  });
}

void main() {
  group('SmsParserService', () {
    final cases = <_SmsCase>[
      const _SmsCase(
        name: 'ICICI debit transfer',
        smsIndex: 0,
        sender: 'ICICIB',
        amount: '300.00',
        type: 'Debit',
        merchant: 'Uma Petroleum',
        bank: 'ICICI Bank',
      ),
      const _SmsCase(
        name: 'SBI credit transfer',
        smsIndex: 1,
        sender: 'SBIN',
        amount: '8000.00',
        type: 'Credit',
        merchant: 'RAJESHSARAGADAM',
        bank: 'State Bank of India',
      ),
      const _SmsCase(
        name: 'Axis credit UPI',
        smsIndex: 2,
        sender: 'AXISBK',
        amount: '50000.00',
        type: 'Credit',
        merchant: 'KIKANI MA',
        bank: 'Axis Bank',
      ),
      const _SmsCase(
        name: 'Axis debit UPI',
        smsIndex: 3,
        sender: 'AXISBK',
        amount: '50000.00',
        type: 'Debit',
        merchant: 'KIKANI MANSIBEN BHA',
        bank: 'Axis Bank',
      ),
      const _SmsCase(
        name: 'Kotak UPI debit',
        smsIndex: 4,
        sender: 'KOTAKB',
        amount: '22.00',
        type: 'Debit',
        merchant: 'dmartavenuesupermart.41116152@hdfcbank',
        bank: 'Kotak Mahindra Bank',
      ),
      const _SmsCase(
        name: 'Kotak card debit',
        smsIndex: 5,
        sender: 'KOTAKB',
        amount: '500.00',
        type: 'Debit',
        merchant: 'GOOGLESERVIS',
        bank: 'Kotak Mahindra Bank',
      ),
      const _SmsCase(
        name: 'Varachha debit',
        smsIndex: 6,
        sender: 'VARACHHABANK',
        amount: '8300.00',
        type: 'Debit',
        merchant: 'Unknown',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'Varachha credit',
        smsIndex: 7,
        sender: 'VARACHHABANK',
        amount: '10000.00',
        type: 'Credit',
        merchant: 'VARACHHABANK',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'SBI NEFT credit',
        smsIndex: 8,
        sender: 'SBIN',
        amount: '77500.00',
        type: 'Credit',
        merchant: 'Unknown',
        bank: 'State Bank of India',
      ),
      const _SmsCase(
        name: 'SBI NEFT debit',
        smsIndex: 9,
        sender: 'SBIN',
        amount: '77500.00',
        type: 'Debit',
        merchant: 'Manu Kikani ICIC0000052-SBI',
        bank: 'State Bank of India',
      ),
      const _SmsCase(
        name: 'HDFC credit deposit',
        smsIndex: 10,
        sender: 'HDFCBK',
        amount: '12345.00',
        type: 'Credit',
        bank: 'HDFC Bank',
      ),
      const _SmsCase(
        name: 'HDFC debit transfer',
        smsIndex: 11,
        sender: 'HDFCBK',
        amount: '3000.00',
        type: 'Debit',
        bank: 'HDFC Bank',
      ),
      const _SmsCase(
        name: 'Kotak NACH debit',
        smsIndex: 12,
        sender: 'KOTAKB',
        amount: '4655.00',
        type: 'Debit',
        merchant: 'NACH-10-IDFCFIRSTBANKLIMITE Kotak Bank',
        bank: 'Kotak Mahindra Bank',
      ),
      const _SmsCase(
        name: 'Axis credit UPI against Kotak',
        smsIndex: 13,
        sender: 'AXISBK',
        amount: '99000.00',
        type: 'Credit',
        merchant: 'SURANI DI',
        bank: 'Axis Bank',
      ),
      const _SmsCase(
        name: 'CRSUDI credit',
        smsIndex: 14,
        sender: 'CRSUDI',
        amount: '2000.00',
        type: 'Credit',
        merchant: 'Your Account XXXXX54270',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'SUDICO credit',
        smsIndex: 15,
        sender: 'SUDICO',
        amount: '200000.00',
        type: 'Credit',
        merchant: 'Unknown',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'Axis money request',
        smsIndex: 16,
        sender: 'AXISBK',
        amount: '242.75',
        type: 'Debit',
        merchant: 'IRCTC CF',
        bank: 'Axis Bank',
      ),
      const _SmsCase(
        name: 'Airtel bill debit',
        smsIndex: 17,
        sender: 'AIRTEL',
        amount: '125.00',
        type: 'Debit',
        merchant: 'Airtel',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'Airtel bill reminder debit',
        smsIndex: 18,
        sender: 'AIRTEL',
        amount: '125.00',
        type: 'Debit',
        merchant: 'Airtel',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'Kotak loan promo',
        smsIndex: 19,
        sender: 'KOTAKB',
        amount: '147000.00',
        type: 'Unknown',
        merchant: 'Unknown',
        bank: 'Kotak Mahindra Bank',
      ),
      const _SmsCase(
        name: 'NSE balance update',
        smsIndex: 20,
        sender: 'NSE',
        amount: '87.60',
        type: 'Unknown',
        merchant: 'INDMONEY PRIVATE LIMITED',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'CDSL debit',
        smsIndex: 21,
        sender: 'CDSL',
        amount: '5.00',
        type: 'Unknown',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'Kotak credit card promo',
        smsIndex: 22,
        sender: 'KOTAKB',
        amount: '308.00',
        type: 'Credit',
        merchant: 'Unknown',
        bank: 'Kotak Mahindra Bank',
      ),
      const _SmsCase(
        name: 'Zomato promo',
        smsIndex: 23,
        sender: 'ZOMATO',
        amount: '250.00',
        type: 'Unknown',
        merchant: 'Zomato',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'HDFC credit card promo',
        smsIndex: 24,
        sender: 'HDFCBK',
        amount: '150000.00',
        type: 'Credit',
        bank: 'HDFC Bank',
      ),
      const _SmsCase(
        name: 'SBI credit card spend',
        smsIndex: 25,
        sender: 'SBICRD',
        amount: '842.00',
        type: 'Debit',
        merchant: 'POLICYBAZAAR',
        category: 'Credit Card Spend',
        bank: 'Generic',
      ),
      const _SmsCase(
        name: 'HDFC debit UPI',
        smsIndex: 26,
        sender: 'HDFCBK',
        amount: '1000.00',
        type: 'Debit',
        merchant: 'Unknown',
        bank: 'HDFC Bank',
      ),
      const _SmsCase(
        name: 'HDFC credit card spend purchase',
        smsIndex: 30,
        sender: 'HDFCBK',
        amount: '1150.00',
        type: 'Debit',
        merchant: 'BOOKMYSHOW',
        category: 'Credit Card Spend',
        bank: 'HDFC Bank',
      ),
      const _SmsCase(
        name: 'HDFC credit card payment',
        smsIndex: 31,
        sender: 'HDFCBK',
        amount: '5000.00',
        type: 'Unknown',
        merchant: 'HDFC Bank Credit Card',
        category: 'Credit Card Payment',
        bank: 'HDFC Bank',
      ),
      const _SmsCase(
        name: 'ICICI blocked credit card transaction',
        smsIndex: 28,
        sender: 'ICICIB',
        amount: '843.00',
        type: 'Unknown',
        merchant: 'Unknown',
        category: 'Blocked Transaction',
        bank: 'ICICI Bank',
      ),
      const _SmsCase(
        name: 'Axis cash withdrawal',
        smsIndex: 29,
        sender: 'AXISBK',
        amount: '2000.00',
        type: 'Debit',
        category: 'Cash Withdrawal',
        bank: 'Axis Bank',
      ),
      const _SmsCase(
        name: 'SBI blocked credit card transaction',
        smsIndex: 32,
        sender: 'SBICRD',
        amount: '842.00',
        type: 'Unknown',
        merchant: 'Transaction declined',
        category: 'Blocked Transaction',
        bank: 'Generic',
      ),
    ];

    test('parses diverse transaction SMS messages correctly', () {
      final expectedCases = cases
          .where(
              (c) => c.type != 'Unknown' && c.bank.toLowerCase() != 'generic')
          .toList();

      final testInputs = cases
          .map(
            (c) => {
              'sender': c.sender,
              'body': smsList[c.smsIndex],
              'date': '1722336000000',
            },
          )
          .toList();

      final results = SmsParserService.parseTransactionMessages(testInputs);

      expect(results, hasLength(expectedCases.length));

      for (var i = 0; i < expectedCases.length; i++) {
        final result = results[i];
        final testCase = expectedCases[i];

        expect(
          result['amount'],
          testCase.amount,
          reason: testCase.name,
        );
        expect(
          result['type'],
          testCase.type,
          reason: testCase.name,
        );
        expect(
          result['bank'],
          testCase.bank,
          reason: testCase.name,
        );

        if (testCase.merchant != null) {
          expect(
            result['upiIdOrSenderName'],
            testCase.merchant,
            reason: testCase.name,
          );
        }

        if (testCase.category != null) {
          expect(
            result['category'],
            testCase.category,
            reason: testCase.name,
          );
        }
      }
    });

    test('skips unknown type and generic bank transactions', () {
      final filteredCases = cases
          .where(
              (c) => c.type == 'Unknown' || c.bank.toLowerCase() == 'generic')
          .toList();

      final testInputs = filteredCases
          .map(
            (c) => {
              'sender': c.sender,
              'body': smsList[c.smsIndex],
              'date': '1722336000000',
            },
          )
          .toList();

      final results = SmsParserService.parseTransactionMessages(testInputs);

      expect(results, isEmpty);
    });

    test('applies special SMS category overrides consistently', () {
      final sampleCases = <_SmsCase>[
        cases.firstWhere((c) => c.name == 'HDFC credit card spend purchase'),
        cases.firstWhere((c) => c.name == 'Axis cash withdrawal'),
      ];

      final sampleInputs = sampleCases
          .map(
            (c) => {
              'sender': c.sender,
              'body': smsList[c.smsIndex],
              'date': '1722336000000',
            },
          )
          .toList();

      final parsed = SmsParserService.parseTransactionMessages(sampleInputs);

      expect(parsed, hasLength(2));
      expect(parsed[0]['category'], 'Credit Card Spend');
      expect(parsed[1]['category'], 'Cash Withdrawal');
    });

    // test('blocked credit card alerts do not count as income', () {
    //   final blockedMessage = {
    //     'sender': 'ICICIB',
    //     'body': smsList[28],
    //     'date': '1722336000000',
    //   };

    //   final parsed =
    //       SmsParserService.parseTransactionMessages([blockedMessage]);

    //   expect(parsed, hasLength(1));
    //   expect(parsed.first['type'], 'Unknown');
    //   expect(parsed.first['category'], 'Blocked Transaction');

    //   final creditedAmount = SmsParserService.instance
    //       .getTotalCreditedAmount(parsed.cast<Map<String, dynamic>>());
    //   expect(creditedAmount, 0.0);
    // });
  });
}
