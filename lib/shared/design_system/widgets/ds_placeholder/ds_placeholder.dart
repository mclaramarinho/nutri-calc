import 'package:flutter/widgets.dart';

class DsPlaceholder extends StatelessWidget {
  const DsPlaceholder({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      children: [Row(
        mainAxisAlignment: .center,
        children: [
          Text(message ?? "Conteúdo em breve!", textAlign: .center,),
        ],
      )],
    );
  }
}
