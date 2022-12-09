import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slugify/slugify.dart';
import 'package:timeago/timeago.dart' as timeago;

// const kPrimaryColor = Color.fromARGB(255, 0, 2, 101);
const kPrimaryColor = Color.fromARGB(255, 23, 144, 243);
const kPrimaryLightColor = Color.fromARGB(255, 237, 237, 255);
const mBackgroundColor = Color(0xFFFAFAFA);
const mBlueColor = Color(0xFF2C53B1);
const mGrayColor = Color(0xFFB4B0B0);
const mTitleColor = Color(0xFF23374D);
const mSubtitleColor = Color(0xFF8E8E8E);
const mBorderColor = Color(0xFFE8E8F3);
const mFillColor = Color(0xFFFFFFFF);
const mCardTitleColor = Color(0xFF2E4ECF);
const mCardSubtitleColor = mTitleColor;

const hajjPrimary = Colors.green;
const hajjSecondary = Color.fromARGB(255, 234, 252, 234);

const baseUrl = 'http://178.128.126.205:3024/';

currencyFormat(int price, {String currency = 'IDR'}) {
  var priceWithCurrency =
      '$currency ${intl.NumberFormat.decimalPattern().format(price)}';

  return priceWithCurrency;
}

emailValidation(email) {
  bool validationEmail = RegExp(
          r"^[a-zA-Z0-9.!#$%&'+ /=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$")
      .hasMatch(email);

  return validationEmail;
}

modal(context, child, size, height) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
    ),
    builder: (context) => Container(
      alignment: Alignment.topCenter,
      height: height.toDouble(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/icons/line.png'),
                ),
                const SizedBox(
                  height: 20,
                ),
                child
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

hpValidation(hp) {
  bool validationPhone = RegExp(r"^[0-9]{6,15}$").hasMatch(hp);

  return validationPhone;
}

String parseVideoUrl(String url) {
  final List<String> splitted = url.split('/');
  final List<String> code = splitted[4].split('-');
  return code[0].toString();
}

slug(String data) {
  // print(data);
  String format = slugify(data, delimiter: '-', lowercase: true);

  return format;
}

formatDate(format, date) {
  final intl.DateFormat formatter = intl.DateFormat(format);
  final String formatted = formatter.format(date);
  return formatted; // something like 2013-04-20
}

getFirstDayOfMonth() {
  final now = DateTime.now();

  var date = DateTime(now.year, now.month, 1).toString();

  return DateTime.parse(date);
}

formatAgo(DateTime dateTime) {
  final anHourAgo = timeago.format(dateTime); // 15 minutes ago;

  return anHourAgo;
}

removeLast(jumlah, string) {
  if (string != null && string.length >= jumlah) {
    string = string.substring(0, string.length - jumlah);
  }

  return string;
}

arabicnumber(number) {
  var arabNumber = '';
  for (int i = 0; i < number.length; i++) {
    if (number[i] == '1') {
      arabNumber += '١';
    } else if (number[i] == '2') {
      arabNumber += '٢';
    } else if (number[i] == '3') {
      arabNumber += '٣';
    } else if (number[i] == '4') {
      arabNumber += '٤';
    } else if (number[i] == '5') {
      arabNumber += '٥';
    } else if (number[i] == '6') {
      arabNumber += '٦';
    } else if (number[i] == '7') {
      arabNumber += '٧';
    } else if (number[i] == '8') {
      arabNumber += '٨';
    } else if (number[i] == '9') {
      arabNumber += '٩';
    } else if (number[i] == '0') {
      arabNumber += '٠';
    }
  }

  return arabNumber;
}

Future setSession(key, value, type) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (type == bool) {
    preferences.setBool(key, value);
  }

  if (type == String) {
    preferences.setString(key, value);
  }

  if (type == int) {
    preferences.setInt(key, value);
  }

  // if(type != bool && type != String && type !=)
}

convertTime(String time) {
  var split = time.split(':');
  Map<String, int> times = {
    "hour": int.parse(split[0]),
    "minutes": int.parse(split[1])
  };
  // print(times);

  return times;
}

String greeting(int bahasa) {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return bahasa == 1 ? 'Selamat Pagi' : 'Good Morning';
  }
  if (hour < 17) {
    return bahasa == 1 ? 'Selamat Siang' : 'Good Afternoon';
  }
  return bahasa == 1 ? 'Selamat Malam' : 'Good Night';
}

showAlertDialog(
  String title,
  String body,
  VoidCallback functionOk,
  BuildContext context,
) {
  // set up the buttons
  Widget cancelButton = ElevatedButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = ElevatedButton(
    onPressed: functionOk,
    child: const Text(
      "Hapus",
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
  );
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    content: Text(
      body,
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

dateToLocal(date) {
  // var dateValue = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC("2020-06-14T18:55:21Z").toLocal();
  String formattedDate = intl.DateFormat("yyyy-MM-dd").format(date);
// debugPrint("formattedDate = "+formattedDate);

  return formattedDate;
}
