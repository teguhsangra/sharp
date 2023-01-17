import 'dart:convert';
import 'package:flutter/material.dart';

class DialogPopUpSuccessCheckOut extends StatefulWidget {

  const DialogPopUpSuccessCheckOut({Key? key,})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DialogPopUpSuccessCheckOutState();
}

class DialogPopUpSuccessCheckOutState extends State<DialogPopUpSuccessCheckOut> {
  var image_success = "assets/images/illustration_container.png";

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image_success,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(padding: EdgeInsets.only(top: 20),
              child: Text(
                'Successfull',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),),
            Padding(padding: EdgeInsets.only(top: 10),
              child: Text(
                'Anda berhasil Check-Out',
                style: TextStyle(
                  fontSize: 14,),
              ),),
          ],
        ),
      ),
    );
  }

}