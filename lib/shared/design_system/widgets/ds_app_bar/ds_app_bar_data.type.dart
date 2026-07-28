import 'dart:ui';

class AppBarData {
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  const AppBarData({this.title, this.onBack, this.onClose});
}
