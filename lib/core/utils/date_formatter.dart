class DateFormatter {
  // Map of month numbers to full month names
  static const Map<int, String> _monthNames = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  /// Converts a date string (millisecondsSinceEpoch or formatted) to 'DD, Month YYYY HH:mm' if time is available, else just date.
  static String formatDate(String inputDate) {
    try {
      DateTime date;
      // Try parsing as millisecondsSinceEpoch
      if (RegExp(r'^\d{10,}??$').hasMatch(inputDate)) {
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(inputDate));
        return '${date.day}, ${_monthNames[date.month]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
            .trim();
      }
      // Fallback to old format
      final dateParts = _parseDate(inputDate);
      if (dateParts == null) {
        return 'Invalid date format';
      }
      final day = dateParts[0];
      final month = dateParts[1];
      final year = dateParts[2];
      return '$day, ${_monthNames[month]} $year';
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Parses a date string in "DD-MM-YY" format and validates it.
  /// Returns a list of [day, month, year] or null if invalid.
  static List<int>? _parseDate(String inputDate) {
    // Check if the input matches the expected format (DD-MM-YY)
    final RegExp datePattern = RegExp(r'^(\d{2})-(\d{2})-(\d{2})$');
    if (!datePattern.hasMatch(inputDate)) {
      return null;
    }

    // Split the date into components
    final parts = inputDate.split('-');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    // Validate the parsed values
    if (day == null || month == null || year == null) {
      return null;
    }

    // Convert two-digit year to four-digit (assuming 21st century)
    final fullYear = 2000 + year;

    // Basic date validation
    if (month < 1 || month > 12) {
      return null;
    }
    if (day < 1 || day > 31) {
      return null;
    }
    // Check for months with fewer than 31 days
    if (month == 2) {
      // Simple leap year check
      bool isLeapYear =
          (fullYear % 4 == 0 && fullYear % 100 != 0) || (fullYear % 400 == 0);
      if (day > (isLeapYear ? 29 : 28)) {
        return null;
      }
    } else if ([4, 6, 9, 11].contains(month) && day > 30) {
      return null;
    }

    return [day, month, fullYear];
  }
}
