import 'dart:convert';
import 'package:flutter/material.dart';

class DialogPopUpSuccess extends StatefulWidget {
    var text;

    DialogPopUpSuccess({
      Key? key,
      this.text
    })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DialogPopUpSuccessState(this.text);
}

class DialogPopUpSuccessState extends State<DialogPopUpSuccess> {
  var image_success = "assets/images/illustration_container.png";
  var text;

  DialogPopUpSuccessState(this.text);

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
                text,
                style: TextStyle(
                  fontSize: 14,),
              ),),
          ],
        ),
      ),
    );
  }

}