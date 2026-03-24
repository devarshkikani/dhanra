import 'rule_based_parser.dart';

class BankRulesConfig {
  static final List<ParserConfig> configs = [
    // HDFC Bank
    ParserConfig(
      bankName: 'HDFC Bank',
      senderPrefixes: ['HDFCBK'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'(?:a/c(?:count)?(?:\s*no\.?)?|acc(?:ount)?|ac)\s*[xX*\.]*\s*(\d{4,})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
    // State Bank of India
    ParserConfig(
      bankName: 'State Bank of India',
      senderPrefixes: ['SBIN', 'SBIINB', 'CBSSBI'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'(?:a/c|A/c|Account|X)\s*[xX*\.]*(\d{4,})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
    // ICICI Bank
    ParserConfig(
      bankName: 'ICICI Bank',
      senderPrefixes: ['ICICIB'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'Acct\s*[xX*\.]*(\d{3,4})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
    // Axis Bank
    ParserConfig(
      bankName: 'Axis Bank',
      senderPrefixes: ['AXISBK', 'AXIS'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'(?:a/c|A/c|Account)\s*[xX*\.]*(\d{4,})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
    // Kotak Mahindra Bank
    ParserConfig(
      bankName: 'Kotak Mahindra Bank',
      senderPrefixes: ['KOTAKB', 'KOTAK'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'(?:a/c|A/c|Account)\s*[xX*\.]*(\d{4,})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
    // Punjab National Bank
    ParserConfig(
      bankName: 'Punjab National Bank',
      senderPrefixes: ['PNB', 'PNBSMS'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'(?:a/c|A/c|Account)\s*[xX*\.]*(\d{4,})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
    // Bank of Baroda
    ParserConfig(
      bankName: 'Bank of Baroda',
      senderPrefixes: ['BOB', 'BARBNK'],
      amountPatterns: [
        RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'(?:a/c|A/c|Account)\s*[xX*\.]*(\d{4,})', caseSensitive: false),
      ],
      balancePatterns: [
        RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
      ],
      creditPatterns: [
        RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
      ],
      debitPatterns: [
        RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
      ],
    ),
  ];

  // A generic configuration that can be used as a fallback
  static final ParserConfig genericConfig = ParserConfig(
    bankName: 'Generic',
    senderPrefixes: [], // Matches everything if used as fallback
    amountPatterns: [
      RegExp(r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
    ],
    accountPatterns: [
      RegExp(r'(?:a/c(?:count)?(?:\s*no\.?)?|acc(?:ount)?|ac)\s*[xX*\.]*\s*(\d{4,})', caseSensitive: false),
    ],
    balancePatterns: [
      RegExp(r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)', caseSensitive: false),
    ],
    creditPatterns: [
      RegExp(r'(credited|received|deposited|added|credit)', caseSensitive: false),
    ],
    debitPatterns: [
      RegExp(r'(debited|sent|withdrawn|paid|deducted|spent|transferred)', caseSensitive: false),
    ],
  );
}
