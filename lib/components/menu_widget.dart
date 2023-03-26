import 'package:flutter/material.dart';

import '../config/constants.dart';

class MenuWidget extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onTap;
  const MenuWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Image.asset(
              icon,
              height: 32.0,
              width: 32.0,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              text,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
