import '../core/utils/money_formatter.dart';

class QuickInputResult {
  final String type; // income | expense
  final int amount;
  final String? note;
  final String? category;
  final bool confident;

  const QuickInputResult({
    required this.type,
    required this.amount,
    this.note,
    this.category,
    this.confident = true,
  });
}

/// Parses natural Vietnamese finance text.
class QuickInputService {
  static final _expenseKeywords = [
    'chi',
    'tiêu',
    'mua',
    'trả',
    'thanh toán',
    'pay',
  ];
  static final _incomeKeywords = ['thu', 'lương', 'nhận', 'được', 'income'];

  static QuickInputResult? parse(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return null;

    final lower = raw.toLowerCase();

    String? type;
    for (final k in _expenseKeywords) {
      if (lower.contains(k)) {
        type = 'expense';
        break;
      }
    }
    if (type == null) {
      for (final k in _incomeKeywords) {
        if (lower.contains(k)) {
          type = 'income';
          break;
        }
      }
    }

    // Extract amount-like tokens
    final amountRegex = RegExp(
      r'(\d+[.,]?\d*)\s*(k|tr|triệu|trieu)?',
      caseSensitive: false,
    );
    final matches = amountRegex.allMatches(lower);
    int? amount;
    String? matchedToken;
    for (final m in matches) {
      final token = m.group(0)!;
      final parsed = MoneyFormatter.parse(token);
      if (parsed != null && parsed > 0) {
        amount = parsed;
        matchedToken = token;
        break;
      }
    }

    if (amount == null) return null;

    // Default type to expense if unclear
    final confident = type != null;
    type ??= 'expense';

    // Remaining text as note
    var note = raw;
    if (matchedToken != null) {
      note = note.replaceFirst(RegExp(matchedToken, caseSensitive: false), '');
    }
    for (final k in [..._expenseKeywords, ..._incomeKeywords]) {
      note = note.replaceAll(RegExp('\\b$k\\b', caseSensitive: false), '');
    }
    note = note.replaceAll(RegExp(r'\s+'), ' ').trim();
    final String? noteFinal = note.isEmpty ? null : note;

    String? category;
    if (note != null && note.isNotEmpty) {
      // Simple category heuristics
      final n = note.toLowerCase();
      if (n.contains('ăn') ||
          n.contains('sáng') ||
          n.contains('trưa') ||
          n.contains('tối')) {
        category = 'Ăn uống';
      } else if (n.contains('xăng') || n.contains('xe') || n.contains('grab')) {
        category = 'Di chuyển';
      } else if (n.contains('lương')) {
        category = 'Lương';
        type = 'income';
      } else if (n.contains('sách') || n.contains('học')) {
        category = 'Học tập';
      }
    }

    return QuickInputResult(
      type: type,
      amount: amount,
      note: noteFinal,
      category: category,
      confident: confident,
    );
  }
}
