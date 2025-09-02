/// ---------- Utilities ----------
class CategoryDetailsUtils {
  static DateTime? parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
      } catch (_) {}
    }
    return null;
  }

  static Stats calculateStats(List<Map<String, dynamic>> txs) {
    final amounts = txs
        .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
        .toList();
    if (amounts.isEmpty) return Stats(0, 0, 0, 0);

    final total = amounts.reduce((a, b) => a + b);
    return Stats(
      total,
      amounts.reduce((a, b) => a < b ? a : b),
      amounts.reduce((a, b) => a > b ? a : b),
      total / amounts.length,
    );
  }

  static List<PeriodData> groupByPeriod(List<Map<String, dynamic>> txs,
      String period, DateTime start, DateTime end) {
    final data = <PeriodData>[];

    if (period == 'Weekly' || period == 'Custom') {
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        final day = start.add(Duration(days: i));
        final total = _sumForRange(txs, day, day);
        data.add(PeriodData("${day.day}/${day.month}", total));
      }
    } else if (period == 'Monthly') {
      DateTime weekStart = start;
      while (weekStart.isBefore(end)) {
        final weekEnd = weekStart.add(const Duration(days: 6)).isAfter(end)
            ? end
            : weekStart.add(const Duration(days: 6));
        final total = _sumForRange(txs, weekStart, weekEnd);
        data.add(PeriodData("${weekStart.day}/${weekStart.month}", total));
        weekStart = weekEnd.add(const Duration(days: 1));
      }
    } else if (period == 'Yearly') {
      for (int m = 1; m <= 12; m++) {
        final total = _sumForRange(
            txs, DateTime(start.year, m, 1), DateTime(start.year, m + 1, 0));
        data.add(PeriodData("$m", total));
      }
    }

    return data;
  }

  static double _sumForRange(
      List<Map<String, dynamic>> txs, DateTime from, DateTime to) {
    return txs
        .where((tx) {
          final date = parseDate(tx['date']);
          return date != null && !date.isBefore(from) && !date.isAfter(to);
        })
        .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
        .fold(0.0, (a, b) => a + b);
  }

  static bool canGoToPrevious(String period, DateTime start) {
    if (period == 'Weekly') return start.isAfter(DateTime(2020));
    if (period == 'Monthly') return start.isAfter(DateTime(2020, 1, 1));
    if (period == 'Yearly') return start.year > 2020;
    return true;
  }

  static bool canGoToNext(String period, DateTime end) {
    final now = DateTime.now();
    if (period == 'Weekly') {
      return end.isBefore(now.subtract(const Duration(days: 1)));
    }
    if (period == 'Monthly') {
      return end.isBefore(DateTime(now.year, now.month, 1));
    }
    if (period == 'Yearly') return end.year < now.year;
    return false;
  }

  static String getPreviousPeriod(String period, DateTime start) {
    if (period == 'Weekly') {
      final prev = start.subtract(const Duration(days: 7));
      return "${prev.year}-${prev.month}-${prev.day}";
    } else if (period == 'Monthly') {
      final prev = DateTime(start.year, start.month - 1, 1);
      return "${prev.year}-${prev.month}";
    } else if (period == 'Yearly') return "${start.year - 1}";
    return period;
  }

  static String getNextPeriod(String period, DateTime start) {
    if (period == 'Weekly') {
      final next = start.add(const Duration(days: 7));
      return "${next.year}-${next.month}-${next.day}";
    } else if (period == 'Monthly') {
      final next = DateTime(start.year, start.month + 1, 1);
      return "${next.year}-${next.month}";
    } else if (period == 'Yearly') return "${start.year + 1}";
    return period;
  }

  static PeriodRange updatePeriodDates(
      String currentPeriod, String key, DateTime oldStart, DateTime oldEnd) {
    final now = DateTime.now();
    if (currentPeriod == 'Weekly') {
      final parts = key.split('-');
      final start = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return PeriodRange(start, start.add(const Duration(days: 6)));
    } else if (currentPeriod == 'Monthly') {
      final parts = key.split('-');
      final start = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      return PeriodRange(start, DateTime(start.year, start.month + 1, 0));
    } else if (currentPeriod == 'Yearly') {
      final year = int.parse(key);
      return PeriodRange(DateTime(year, 1, 1), DateTime(year, 12, 31));
    }
    return PeriodRange(oldStart, oldEnd);
  }

  static String getPeriodLabel(String period, DateTime start, DateTime end) {
    if (period == 'Weekly') {
      if (start.month == end.month && start.year == end.year) {
        return "${start.day} - ${end.day} ${_month(start.month)} ${start.year}";
      } else if (start.year == end.year) {
        return "${start.day} ${_month(start.month)} - ${end.day} ${_month(end.month)} ${start.year}";
      }
      return "${start.day} ${_month(start.month)} ${start.year} - ${end.day} ${_month(end.month)} ${end.year}";
    } else if (period == 'Monthly') {
      return "${_month(start.month)} ${start.year}";
    } else if (period == 'Yearly') {
      return "${start.year}";
    }
    return "Custom Period";
  }

  static String _month(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m];
  }
}

/// ---------- Models ----------
class PeriodData {
  final String label;
  final double value;
  PeriodData(this.label, this.value);
}

class PeriodRange {
  final DateTime start;
  final DateTime end;
  PeriodRange(this.start, this.end);
}

class Stats {
  final double total, min, max, avg;
  Stats(this.total, this.min, this.max, this.avg);
}
