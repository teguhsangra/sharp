// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../constants.dart';
import 'text_field_container.dart';

class RoundedInputField extends StatefulWidget {
  final Function onChanged;
  final Function validation;
  final String? title;
  final String? hintText;
  final bool enabled;
  final int maxlines;
  final IconData? icon;
  final String initVal;
  bool isNumber;

  RoundedInputField({
    Key? key,
    this.title,
    this.hintText,
    this.enabled = true,
    this.maxlines = 1,
    this.icon,
    required this.onChanged,
    this.initVal = '',
    required this.validation,
    this.isNumber = false,
  }) : super(key: key);

  @override
  State<RoundedInputField> createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {



  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: widget.initVal,
        maxLines: widget.maxlines,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        cursorColor: kPrimaryColor,
        onChanged: (value) {
          widget.onChanged(value);
        },
        decoration: InputDecoration(
            hintText: widget.hintText, border: InputBorder.none),
        validator: (value) {
          return  widget.validation(value);
        },
      ),
    );
  }
}
