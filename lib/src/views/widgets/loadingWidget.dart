import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Widget? child;
  const LoadingWidget({super.key,this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const Center(child: CircularProgressIndicator());
  }
}
