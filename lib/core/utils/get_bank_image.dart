class GetBankImage {
  static String? getBankImagePath(String bankName) {
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
}
