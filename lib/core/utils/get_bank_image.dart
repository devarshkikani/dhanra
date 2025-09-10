class GetBankImage {
  static String? getBankImagePath(String bankName) {
    // Special case for Cash bank
    if (bankName == 'Cash') {
      return null; // Will use icon instead
    }
    
    List<String> bankImages = [
      "Axis Bank",
      "HDFC Bank",
      "ICICI Bank",
      "Kotak Mahindra Bank",
      "State Bank of India",
    ];
    if (bankImages.contains(bankName)) {
      return 'assets/images/banks/$bankName.png';
    } else {
      null;
    }
    return null;
  }
  
  static bool isCashBank(String bankName) {
    return bankName == 'Cash';
  }
}
