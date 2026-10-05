import 'package:intl/intl.dart';
import '../models/transaction.dart';

class CsvService {
  static String transactionsToCsv(List<Transaction> txs) {
    final buf = StringBuffer();
    buf.writeln('Date,Type,Category,Amount,Note');
    for (final t in txs) {
      final date = DateFormat('yyyy-MM-dd').format(t.date);
      final note = (t.note ?? '').replaceAll('"', '""');
      buf.writeln('$date,${t.type},${t.category},${t.amount},"$note"');
    }
    return buf.toString();
  }

  static String suggestedFilename() {
    final d = DateFormat('yyyy-MM').format(DateTime.now());
    return 'LifeSync_Transactions_$d.csv';
  }
}
