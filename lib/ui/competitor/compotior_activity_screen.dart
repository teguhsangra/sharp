import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetitorActivityScreen extends StatefulWidget {
  const CompetitorActivityScreen({super.key});

  @override
  State<StatefulWidget> createState() => CompetitorActivityState();
}

class CompetitorActivityState extends State<CompetitorActivityScreen> {
  var user = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    loadUserData();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });

  }

  loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userSession = jsonDecode(localStorage.getString('user').toString());
    setState(() {
      user = userSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: const Text(
          "Competitor Activity",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [],
        elevation: 0,
      ),
      body: isLoading ?
          Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: const Center(child: CircularProgressIndicator()),
          ) : RefreshIndicator(
            onRefresh: () async {
              loadUserData();
            },
            child: Column(
              children: const [
                Text("Page for Competitor Activity")
              ],
            ),
      ),
    );
  }
}

