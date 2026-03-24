import 'package:flutter_test/flutter_test.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';

void main() {
  group('SmsParserService Comprehensive Tests', () {
    test('Test all messages in smsList', () {
      final List<Map<String, String>> testInputs = [
        {'sender': 'ICICIB', 'body': smsList[0], 'date': '1722336000000'},
        {'sender': 'SBIN', 'body': smsList[1], 'date': '1722336000000'},
        {'sender': 'AXISBK', 'body': smsList[2], 'date': '1722336000000'},
        {'sender': 'AXISBK', 'body': smsList[3], 'date': '1722336000000'},
        {'sender': 'KOTAKB', 'body': smsList[4], 'date': '1722336000000'},
        {'sender': 'KOTAKB', 'body': smsList[5], 'date': '1722336000000'},
        {'sender': 'VARACHHABANK', 'body': smsList[6], 'date': '1722336000000'},
        {'sender': 'VARACHHABANK', 'body': smsList[7], 'date': '1722336000000'},
        {'sender': 'SBIN', 'body': smsList[8], 'date': '1722336000000'},
        {'sender': 'SBIN', 'body': smsList[9], 'date': '1722336000000'},
        {'sender': 'HDFCBK', 'body': smsList[10], 'date': '1722336000000'},
        {'sender': 'HDFCBK', 'body': smsList[11], 'date': '1722336000000'},
        {'sender': 'KOTAKB', 'body': smsList[12], 'date': '1722336000000'},
        {'sender': 'AXISBK', 'body': smsList[13], 'date': '1722336000000'},
        {'sender': 'CRSUDI', 'body': smsList[14], 'date': '1722336000000'},
        {'sender': 'SUDICO', 'body': smsList[15], 'date': '1722336000000'},
        {'sender': 'AXISBK', 'body': smsList[16], 'date': '1722336000000'},
        {'sender': 'AIRTEL', 'body': smsList[17], 'date': '1722336000000'},
        {'sender': 'AIRTEL', 'body': smsList[18], 'date': '1722336000000'},
        {'sender': 'KOTAKB', 'body': smsList[19], 'date': '1722336000000'},
        {'sender': 'NSE', 'body': smsList[20], 'date': '1722336000000'},
        {'sender': 'CDSL', 'body': smsList[21], 'date': '1722336000000'},
        {'sender': 'KOTAKB', 'body': smsList[22], 'date': '1722336000000'},
        {'sender': 'ZOMATO', 'body': smsList[23], 'date': '1722336000000'},
      ];

      final results = SmsParserService.parseTransactionMessages(testInputs);
      
      final expected = [
        {'amount': '300.00', 'type': 'Debit', 'merchant': 'uma@okicici'}, // 0 ICICI
        {'amount': '8000.00', 'type': 'Credit', 'merchant': 'RAJESHSARAGADAM'}, // 1 SBI
        {'amount': '50000.00', 'type': 'Credit', 'merchant': 'KIKANI MA'}, // 2 Axis
        {'amount': '50000.00', 'type': 'Debit', 'merchant': 'KIKANI MANSIBEN BHA'}, // 3 Axis
        {'amount': '22.00', 'type': 'Debit', 'merchant': 'dmartavenuesupermart.41116152@hdfcbank'}, // 4 Kotak
        {'amount': '500.00', 'type': 'Debit', 'merchant': 'GOOGLESERVIS'}, // 5 Kotak
        {'amount': '8300.00', 'type': 'Debit', 'merchant': 'UPI/001913816303'}, // 6 Varachha
        {'amount': '10000.00', 'type': 'Credit', 'merchant': 'VARACHHABANK'}, // 7 Varachha
        {'amount': '77500.00', 'type': 'Credit', 'merchant': 'Beneficiary'}, // 8 SBI NEFT
        {'amount': '77500.00', 'type': 'Debit', 'merchant': 'Manu Kikani'}, // 9 SBI NEFT
        {'amount': '12345.00', 'type': 'Credit', 'merchant': 'SMART SHIP HUB DIGITAL INDIA'}, // 10 HDFC
        {'amount': '3000.00', 'type': 'Debit', 'merchant': 'SARVESH RAJENDRA RANSUBHE'}, // 11 HDFC
        {'amount': '4655.00', 'type': 'Debit', 'merchant': 'IDFCFIRSTBANKLIMITE'}, // 12 Kotak
        {'amount': '99000.00', 'type': 'Credit', 'merchant': 'SURANI DI'}, // 13 Axis
        {'amount': '2000.00', 'type': 'Credit', 'merchant': 'PM KISAN SAMMAN NIDHI YOJNA'}, // 14 SUDICO
        {'amount': '200000.00', 'type': 'Credit', 'merchant': 'beneficiary'}, // 15 SUDICO
        {'amount': '242.75', 'type': 'Debit', 'merchant': 'IRCTC CF'}, // 16 Axis Request
        {'amount': '125.00', 'type': 'Debit', 'merchant': 'Airtel'}, // 17 Airtel Bill
        {'amount': '125.00', 'type': 'Debit', 'merchant': 'Airtel'}, // 18 Airtel Bill
        {'amount': '147000.00', 'type': 'Unknown', 'merchant': 'Unknown'}, // 19 Kotak Loan
        {'amount': '87.60', 'type': 'Unknown', 'merchant': 'INDMONEY PRIVATE LIMITED'}, // 20 NSE
        {'amount': '5.00', 'type': 'Debit', 'merchant': 'ONGC-EQ-RS.5/-'}, // 21 CDSL
        {'amount': '308.00', 'type': 'Unknown', 'merchant': 'Unknown'}, // 22 Kotak Promo
        {'amount': '250.00', 'type': 'Unknown', 'merchant': 'Zomato'}, // 23 Zomato Promo
      ];

      for (int i = 0; i < results.length; i++) {
        final res = results[i];
        final exp = expected[i];
        
        print('\n--- Message $i ---');
        print('Body: ${testInputs[i]['body']}');
        print('Actual:   Amt: ${res['amount']}, Type: ${res['type']}, Merchant: ${res['upiIdOrSenderName']}');
        print('Expected: Amt: ${exp['amount']}, Type: ${exp['type']}, Merchant: ${exp['merchant']}');
      }

      expect(results.length, expected.length);
    });
  });
}
