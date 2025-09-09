class AppRegexp {
  static final RegExp excludePattern = RegExp(
    r'\b('
    r'offer|discount|cashback|reward|rewards|save|off|get up to|enjoy|t&c|'
    r'bill|due|overdue|last date|outstanding|payment request|requested money|'
    r'pay instantly|pay immediately|to avoid service interruption|'
    r'ignore if already paid|reminder'
    r')\b',
    caseSensitive: false,
  );

  // Regex patterns
  static final RegExp senderPattern = RegExp(
    r'^(?:[A-Z]{2}-)?('
    r'HDFCBK|SBIN|SBIINB|CBSSBI|' // HDFC + SBI
    r'ICICIB|'
    r'AXISBK|AXIS|AXISB|'
    r'KOTAKB|KOTAK|' // Kotak
    r'PNB|PNBSMS|'
    r'BOB|BARBNK|'
    r'CANBNK|'
    r'UNIONB|UNIONS|'
    r'YESBNK|'
    r'MAHABK|'
    r'IDFCBK|IDFCFB|'
    r'INDUSB|'
    r'BOIIND|'
    r'FEDBNK|'
    r'BOMBNK|'
    r'UJJIVN|'
    r'KARBAN|'
    r'DCBBNK|'
    r'SURYOD|'
    r'RBLBNK|'
    r'AUFINS|'
    r'FINO|'
    r'JIOBNK|'
    r'NBINBK|'
    r'PAYTM|PAYTMB|'
    r'AIRTEL|'
    r'NSDL|'
    r'FINSER|'
    r'CASHP|'
    r'BHIM|UPI|'
    r'GPAY|G-PAY|'
    r'PHONEPE|PHNPE|'
    r'AMZNPY|'
    r'IMPS|NEFT|RTGS'
    r')[A-Z0-9-]*$', // <- allow suffix/prefix
    caseSensitive: false,
  );

  static final RegExp transactionPattern = RegExp(
    r'('
    // keyword (maybe "by"/"of"/":") then optional currency then amount
    r'(?:(?:credit(?:ed)?|received|deposited|added|debit(?:ed)?|sent|withdrawn|paid|deducted|spent|transferred)\b(?:\s*(?:by|for|of|:|amount))?\s*(?:rs\.?|inr)?\s*[0-9]{1,3}(?:[0-9,]*)(?:\.\d{1,2})?)'
    r'|'
    // amount then later keyword
    r'(?:(?:rs\.?|inr)?\s*[0-9]{1,3}(?:[0-9,]*)(?:\.\d{1,2})?.*?(?:credit(?:ed)?|received|deposited|added|debit(?:ed)?|sent|withdrawn|paid|deducted|spent|transferred)\b)'
    r')',
    caseSensitive: false,
  );

  static final RegExp amountPattern = RegExp(
    r'(?:Rs\.?|INR)\s*([\d,.]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // static final RegExp datePattern = RegExp(
  //   r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{1,2}[A-Za-z]{3}\d{2,4})',
  //   caseSensitive: false,
  // );

  // Account number patterns for different banks - focusing on receiver account
  static final RegExp receiverAccountPattern = RegExp(
    r'(?:a/c|account|acc)\s*(?:no|number|#)?\s*[:\-]?\s*(?:XX)?(\d{4,19})',
    caseSensitive: false,
  );
  static final RegExp balancePattern = RegExp(
    r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*([\d,.]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp lastFourDigitsPattern = RegExp(
    r'(?:card|account|a/c)\s*(?:ending|no|number|#)?\s*(?:with|in|on)?\s*(?:last|ending)?\s*(?:digits|numbers)?\s*[:\-]?\s*(?:XX)?(\d{4})',
    caseSensitive: false,
  );

  // Pattern to find receiver account in transaction messages
  static final RegExp receiverAccountInBodyPattern = RegExp(
    r'(?:credited|received|credit|deposited|added|debited|sent|withdrawn|paid|deducted|spent|transferred)'
    r'\s*(?:to|in|from|out)?\s*(?:your\s*)?(?:account|a/c|wallet)?\s*(?:no|number|#)?\s*[:\-]?\s*(\d{4,19})',
    caseSensitive: false,
  );

  // Pattern to find "your account" references
  static final RegExp yourAccountPattern = RegExp(
    r'(?:your\s+)?(?:account|a/c|acc)\s*(?:no|number|#)?\s*[:\-]?\s*(\d{4,19})',
    caseSensitive: false,
  );

  // Pattern to find account numbers in bank-specific formats
  static final RegExp bankAccountPattern = RegExp(
    r'(?:AC|A/C|Account)\s*([A-Z0-9]{4,19})',
    caseSensitive: false,
  );

  // Pattern to find account numbers after bank names
  static final RegExp bankNameAccountPattern = RegExp(
    r'(?:Bank|BK)\s+(?:AC|A/C|Account)?\s*([A-Z0-9]{4,19})',
    caseSensitive: false,
  );

  // Pattern to identify balance SMS messages
  static final RegExp balanceSmsPattern = RegExp(
    r'(?:bal|balance|avl|available)\s*(?:bal|balance)?\s*[:\-]?\s*(?:Rs\.?|INR)?\s*[\d,.]+',
    caseSensitive: false,
  );

  static final upiRegex =
      RegExp(r'\b[\w.\-]+@[a-z]{2,}(?:\.[a-z]{2,})?\b', caseSensitive: false);

  static final nameRegex = RegExp(
    r'(?:(?:to|from)\s+)([A-Za-z0-9&.\- ]{2,})',
    caseSensitive: false,
  );
}
