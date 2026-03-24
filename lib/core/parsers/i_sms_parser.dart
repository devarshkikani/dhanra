import '../models/sms_transaction.dart';

abstract class ISmsParser {
  /// Unique identifier for the parser (e.g., 'HDFC', 'SBI', 'Generic')
  String get id;

  /// Determines if this parser can handle the given message
  bool canParse(String sender, String body);

  /// Parsers the message and returns a [SmsTransaction] or null if parsing fails
  SmsTransaction? parse({
    required String sender,
    required String body,
    DateTime? receivedDate,
  });
}
