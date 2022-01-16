import 'package:intl/intl.dart';

String idrFormat(String price) {
  var f = NumberFormat("#,###", "id_ID");
  return (f.format(int.parse(price)));
}
