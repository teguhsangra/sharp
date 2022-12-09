// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:telkom/components/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final Function onChanged;
  final Function validation;
  final String? title;
  final String? hintText;
  final bool enabled;
  final int maxlines;
  final bool password;
  final IconData? icon;
  bool securePassword;
  final String initVal;
  bool isNumber;

  RoundedPasswordField({
    Key? key,
    this.title,
    this.hintText,
    this.enabled = true,
    this.maxlines = 1,
    this.password = false,
    this.icon,
    this.securePassword = true,
    required this.onChanged,
    this.initVal = '',
    required this.validation,
    this.isNumber = false,
  }) : super(key: key);

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: widget.securePassword,
        onChanged: (value) {
          widget.onChanged(value);
        },
        decoration: InputDecoration(
            hintText: "Password",
            suffixIcon: Visibility(
              visible: widget.password,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.securePassword = !widget.securePassword;
                  });
                },
                child: Icon(
                  widget.securePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.black87,
                ),
              ),
            ),
            border: InputBorder.none),
        validator: (value) {
          return widget.validation(value);
          return null;
        },
      ),
    );
  }
}
