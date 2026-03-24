class DataExtractors {
  static String? extractUpiId(String body) {
    final upiRegex = RegExp(
        r'(?:UPI|VPA)\s*[:/]?\s*([a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+)',
        caseSensitive: false);
    final match = upiRegex.firstMatch(body);
    if (match != null) return match.group(1);

    final upiIdOnlyRegex = RegExp(r'\b[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+\b');
    final match2 = upiIdOnlyRegex.firstMatch(body);
    return match2?.group(0);
  }

  static String? extractMerchantName(String body, {String? type}) {
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 1. UPI ID or VPA in body (highest priority)
    final vpa = extractUpiId(body);
    if (vpa != null) return vpa;

    // 2. High Confidence UPI Path Extraction
    final upiPathRegex = RegExp(
        r'UPI\/(?:[A-Za-z0-9_]+\/|CR\/|DR\/){1,3}([^\/\n\r]+)',
        caseSensitive: false);
    final upiPathMatch = upiPathRegex.firstMatch(body);
    if (upiPathMatch != null) {
      final cand = _cleanCandidate(upiPathMatch.group(1)!);
      final truncated = _truncateAtExclusion(cand);
      if (_isValidMerchant(truncated)) return truncated;
    }

    // 3. Leading name followed by "on [Date] reported" or "has requested" or "reported"
    final leadingRegex = RegExp(
        r'^([A-Za-z0-9&\-\.]{3,}(?:\s+[A-Za-z0-9&\-\.]{1,}){0,3})\s+(?:on\b|has\b|reported\b|reported\b)',
        caseSensitive: false);
    final leadingMatch = leadingRegex.firstMatch(normalized);
    if (leadingMatch != null) {
      final cand = _cleanCandidate(leadingMatch.group(1)!);
      if (_isValidMerchant(cand)) return cand;
    }

    // 4. Action-based matches (Priority to those NOT matching bank names)
    final actionRegex = RegExp(
        r'([A-Za-z0-9&\-\.]{3,}(?:\s+[A-Za-z0-9&\-\.]{1,}){0,3})\s+(?:credited|debited)\b',
        caseSensitive: false);
    final actionMatches = actionRegex.allMatches(normalized);
    String? fallbackAction;
    for (var match in actionMatches) {
      final cand = _cleanCandidate(match.group(1)!);
      final truncated = _truncateAtExclusion(cand);
      if (_isValidMerchant(truncated) && !_isSentenceFragment(truncated)) {
        if (!_isBankNameOnly(truncated)) return truncated;
        fallbackAction ??= truncated;
      }
    }

    // 5. Prefix-based extraction (to, from, etc.)
    final prefixes = (type == 'Debit')
        ? [r'\bto\b', r'\btowards\b', r'\bat\b', r'\bthru\b']
        : (type == 'Credit')
            ? [r'\bfrom\b', r'\bby\b', r'\bInfo\b', r'\btransfer from\b', r'\bsent to\b']
            : [
                r'\bto\b',
                r'\bfrom\b',
                r'\bat\b',
                r'\btowards\b',
                r'\bInfo\b',
                r'\bthru\b',
                r'\bsent to\b'
              ];

    for (var prefix in prefixes) {
      final nameRegex = RegExp(
          '$prefix\\s*[:\\-]?\\s*([A-Za-z0-9&\-\.]{2,}(?:\\s+[A-Za-z0-9&\-\.]{1,}){0,5})',
          caseSensitive: false);
      final matches = nameRegex.allMatches(normalized);
      for (var match in matches) {
        var cand = _cleanCandidate(match.group(1)!);
        cand = _truncateAtExclusion(cand);
        if (_isValidMerchant(cand)) {
          // If it looks like a UPI path, prioritize it
          if (cand.startsWith('UPI/')) return cand;
          // Special case for Airtel/Zomato alerts
          if (normalized.toLowerCase().contains('airtel')) return 'Airtel';
          if (normalized.toLowerCase().contains('zomato')) return 'Zomato';
          
          if (!_isBankNameOnly(cand)) return cand;
        }
      }
    }

    // 6. NEFT/IMPS/RTGS info
    final neftRegex = RegExp(
        r'(?:NEFT|IMPS|RTGS|TRANSFER|TRF)[ \-:/]([A-Z0-9 \-_]+)[ \-:/]([A-Za-z0-9 &\.\-]+)',
        caseSensitive: false);
    final neftMatch = neftRegex.firstMatch(normalized);
    if (neftMatch != null) {
      var cand = _cleanCandidate(neftMatch.group(2)!);
      cand = _truncateAtExclusion(cand);
      if (_isValidMerchant(cand)) return cand;
    }

    return fallbackAction;
  }

  static String _truncateAtExclusion(String s) {
    if (s.isEmpty) return s;
    final exclusions = [
      'ref', 'no', 'a/c', 'acct', 'account', 'ac', 'rs', 'inr', 'transaction', 
      'bal', 'avl', 'on', 'at', 'from', 'to', 'your', 'the', 'beneficiary',
      'clearing', 'subject', 'immediately', 'avoid', 'view', 'using', 'if',
      'sent', 'is', 'has', 'been', 'was', 'were', 'credited', 'debited', 'clear', 
      'balance', 'of', 'for', 'with', 'by', 'thru', 'towards', 'info', 'utr', 'dtd',
      'click', 'link', 'tap', 'fraud', 'kmbl', 'visit', 'done', 'reported', 'bal',
      'debit', 'credit', 'stop', 'limit', 'card', 'bill', 'due', 'will', 'is', 'in',
      'into', 'at', 'on', 'tnx', 'sms', 'call'
    ];
    
    var words = s.split(' ');
    var result = <String>[];
    for (var word in words) {
      final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[\.,:/*]'), '');
      if (exclusions.contains(cleanWord) || cleanWord.isEmpty) {
        if (result.isNotEmpty) break; // Stop at first exclusion
        continue;
      }
      result.add(word);
    }
    return result.join(' ').trim();
  }

  static bool _isSentenceFragment(String s) {
    if (s.isEmpty) return true;
    final t = s.toLowerCase();
    final fragments = ['has', 'been', 'was', 'is', 'your', 'the', 'credited', 'debited', 'will', 'if', 'done', 'by'];
    if (fragments.contains(t)) return true;
    return fragments.any((f) => t.contains(' $f ') || t.endsWith(' $f') || t.startsWith('$f '));
  }

  static bool _isBankNameOnly(String s) {
    final t = s.toLowerCase();
    final bankNames = [
      'hdfc', 'sbi', 'icici', 'axis', 'kotak', 'pnb', 'bob', 'bank', 
      'idfc', 'sudico', 'varachha', 'kmbl', 'beneficiary', 'clearing'
    ];
    // If it's just a bank name or bank + account suffix
    if (bankNames.any((b) => t == b || t == '$b bank' || t == 'bank of $b')) return true;
    if (s.split(' ').length < 2) {
       return bankNames.any((b) => t.contains(b));
    }
    return false;
  }

  static bool _isValidMerchant(String s) {
    if (s.isEmpty) return false;
    if (s.length < 3 && !s.contains('@')) return false; // Too short for a name
    final t = s.toLowerCase();
    
    // Check for IFSC (4 chars + 0 + 6 chars)
    if (RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(s)) return false;

    if (t.contains('@')) return true; // It's a UPI ID
    if (RegExp(r'^[0-9xX\-\s\*]+$').hasMatch(t)) return false; // numbers/stars/X
    if (RegExp(r'^[0-9]{3,}').hasMatch(t)) return false;

    final commonSentenceFillers = ['your', 'the', 'beneficiary', 'clearing', 'rs', 'inr', 'subject', 'to', 'been', 'was', 'done', 'will', 'txn', 'sms'];
    if (commonSentenceFillers.contains(t)) return false;
    
    return true;
  }

  static String _cleanCandidate(String s) {
    var out = s.trim();
    out = out.replaceAll(RegExp(r'[\.,;:/\-]+$'), '');
    return out.trim();
  }
}
