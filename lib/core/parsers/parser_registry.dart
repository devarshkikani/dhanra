import 'i_sms_parser.dart';
import 'rule_based_parser.dart';
import 'bank_rules_config.dart';
import '../models/sms_transaction.dart';

class ParserRegistry {
  final List<ISmsParser> _parsers = [];

  void register(ISmsParser parser) {
    _parsers.add(parser);
  }

  void initialize() {
    _parsers.clear();
    // Register bank-specific parsers
    for (var config in BankRulesConfig.configs) {
      register(RuleBasedParser(config));
    }
    // Add generic parser as fallback
    register(RuleBasedParser(BankRulesConfig.genericConfig));
  }

  ISmsParser? findParser(String sender, String body) {
    for (var parser in _parsers) {
      if (parser.canParse(sender, body)) {
        return parser;
      }
    }
    // If no bank-specific parser matches, use the last one (which should be Generic)
    return _parsers.isNotEmpty ? _parsers.last : null;
  }

  List<ISmsParser> get parsers => List.unmodifiable(_parsers);
}

class SmsParserEngine {
  final ParserRegistry registry;

  SmsParserEngine(this.registry);

  List<SmsTransaction> parseMessages(List<Map<String, String>> messages) {
    final List<SmsTransaction> results = [];

    for (var msg in messages) {
      final sender = msg['sender'] ?? '';
      final body = msg['body'] ?? '';
      final dateStr = msg['date'] ?? '';
      final date = dateStr.isEmpty ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));

      final parser = registry.findParser(sender, body);
      if (parser != null) {
        final tx = parser.parse(sender: sender, body: body, receivedDate: date);
        if (tx != null) {
          results.add(tx);
        }
      }
    }

    return results;
  }
}
