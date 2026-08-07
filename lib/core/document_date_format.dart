import 'package:intl/intl.dart';

/// Date under a document name. The design shows `12.04.2025`.
abstract final class DocumentDateFormat {
  static final DateFormat _format = DateFormat('dd.MM.yyyy');

  static String short(DateTime date) => _format.format(date);
}
