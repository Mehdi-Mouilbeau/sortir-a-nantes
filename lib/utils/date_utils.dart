import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm');

  static String format(DateTime date) {
    return _formatter.format(date);
  }
}
