import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const kPrimaryColor = Color(0xFFE50404);
const kPrimaryLightColor = Color(0xFFF1E6FF);
const kSecondaryColor = Color(0xFFE50404);

const double defaultPadding = 20.0;
const kSpacingUnit = 10;

final kTitleTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.7),
  fontWeight: FontWeight.w600,
);

final kCaptionTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
  fontWeight: FontWeight.w100,
);

const APIKey = "AIzaSyD49vc-A2l7lcWp0JVxdOA4rGdPzpGi38U";