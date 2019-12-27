import 'package:intl/intl.dart';
class Utils{

  static String dateTimeToString(DateTime dt,String timeFormat){
    return DateFormat(timeFormat).format(dt);
  }

}