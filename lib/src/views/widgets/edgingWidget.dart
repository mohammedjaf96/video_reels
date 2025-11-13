import 'package:flutter/material.dart';

class EdgingWidget extends StatelessWidget {
  const EdgingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black,Colors.black12,Colors.transparent],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft
            )
        ),
      ),
    );
  }
}
