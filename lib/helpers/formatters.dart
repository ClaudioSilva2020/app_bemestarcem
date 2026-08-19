import 'package:intl/intl.dart';

final NumberFormat _currency =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

String formatPrice(double price) => _currency.format(price);
