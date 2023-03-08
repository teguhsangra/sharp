import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final double height;
  final Widget child;

  const CardContainer({
    Key? key,
    required this.height,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 2,
                // Shadow position
                spreadRadius: 1,
                offset: const Offset(0, 1)),
          ]),
      child: child,
    );
  }
}
