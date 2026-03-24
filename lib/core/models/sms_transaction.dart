class SmsTransaction {
  final String id;
  final double amount;
  final DateTime? date;
  final String bank;
  final String type; // Credit, Debit, or Unknown
  final String sender;
  final String rawBody;
  final String upiIdOrSenderName;
  final String category;
  final String accountNumber;
  final String lastFourDigits;
  final double balance;
  final bool hasBalanceInfo;
  SmsTransaction({
    required this.id,
    required this.amount,
    this.date,
    required this.bank,
    required this.type,
    required this.sender,
    required this.rawBody,
    this.upiIdOrSenderName = 'Unknown',
    this.category = 'Miscellaneous',
    this.accountNumber = 'Unknown',
    this.lastFourDigits = 'Unknown',
    this.balance = 0.0,
    this.hasBalanceInfo = false,
  });

  Map<String, String> toMap() {
    return {
      'id': id,
      'amount': amount.toStringAsFixed(2),
      'date': date?.millisecondsSinceEpoch.toString() ?? 'Unknown',
      'bank': bank,
      'type': type,
      'sender': sender,
      'body': rawBody,
      'upiIdOrSenderName': upiIdOrSenderName,
      'category': category,
      'accountNumber': accountNumber,
      'lastFourDigits': lastFourDigits,
      'balance': balance.toStringAsFixed(2),
      'hasBalanceSms': hasBalanceInfo.toString(),
    };
  }

  @override
  String toString() => 'SmsTransaction(bank: $bank, amount: $amount, type: $type)';
}
