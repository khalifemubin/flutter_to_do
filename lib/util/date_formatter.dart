import 'package:intl/intl.dart';

String dateFormatted() {
  var now = DateTime.now();
  // var formatter = new DateFormat("EEE, MMM d, ''yy");
  // String formatted = formatter.format(now);
  var formatted = DateFormat.yMMMd().add_jm().format(now);
  return formatted;
}
