import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats integer VND with thousand separators for display.
class MoneyFormatter {
  static final NumberFormat _vnd = NumberFormat('#,###', 'vi_VN');

  /// Format integer amount as Vietnamese currency string, e.g. 1,500,000 ₫
  static String format(int amount) {
    return '${_vnd.format(amount)} ₫';
  }

  /// Format without currency symbol.
  static String formatNumber(int amount) {
    return _vnd.format(amount);
  }

  /// Parse common Vietnamese amount strings to integer VND.
  /// Supports: 50k, 50K, 50.000, 50,000, 1tr, 1 triệu, 8tr, 1.5tr, etc.
  static int? parse(String input) {
    if (input.trim().isEmpty) return null;
    var s = input.trim().toLowerCase().replaceAll(' ', '');
    s = s.replaceAll('₫', '').replaceAll('d', '').replaceAll('đ', '');

    double multiplier = 1;
    if (s.endsWith('triệu') || s.endsWith('trieu')) {
      multiplier = 1000000;
      s = s.replaceAll(RegExp(r'tri[eệ]u$'), '');
    } else if (s.endsWith('tr')) {
      multiplier = 1000000;
      s = s.substring(0, s.length - 2);
    } else if (s.endsWith('k')) {
      multiplier = 1000;
      s = s.substring(0, s.length - 1);
    }

    // Normalize decimal/thousand separators for VN
    // 1.5tr -> 1.5 * 1e6, 50.000 -> 50000, 50,000 -> 50000
    if (s.contains(',') && s.contains('.')) {
      // Assume European: 1.500,50 or US: 1,500.50 — prefer VN style 1.500.000
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      // Could be 50,000 or 1,5
      final parts = s.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        s = '${parts[0]}.${parts[1]}';
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (s.contains('.')) {
      final parts = s.split('.');
      if (parts.length == 2 && parts[1].length <= 2 && multiplier > 1) {
        // 1.5tr style
      } else {
        // 50.000 style thousand separator
        s = s.replaceAll('.', '');
      }
    }

    final value = double.tryParse(s);
    if (value == null || value < 0) return null;
    return (value * multiplier).round();
  }
}

/// TextInputFormatter that adds thousand separators while typing.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Keep only digits
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Avoid leading zeros issues for large numbers
    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final formatted = MoneyFormatter.formatNumber(number);

    // Approximate cursor at end for simplicity and reliability
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
