extension ExtDatetime on DateTime {
  String formattedDate() {
    return "${_getPadded(day)}/${_getPadded(month)}/$year";
  }

  String formattedTime() {
    return "${_getPadded(hour)}:${_getPadded(minute)}";
  }

  String formattedDateTime() {
    return "${formattedDate()} - ${formattedTime()}";
  }

  String _getPadded(int value) => value.toString().padLeft(2, '0');
}
