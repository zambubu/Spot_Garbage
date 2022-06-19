import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:authentifaction_app/views/helper.dart';

class Report {
  DateTime? date;
  String? file;
  GeoPoint? location;
  bool? resolved;

  Report();

  Report.fromSnapshot(snapshot)
      : date = snapshot.data()['date'].toDate(),
        file = snapshot.data()['file'],
        location = snapshot.data()['location'],
        resolved = snapshot.data()['resolved'];
}

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Object> _historyList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          centerTitle: true,
        ),
        body: SafeArea(
            child: ListView.builder(
          itemCount: _historyList.length,
          itemBuilder: (context, index) {
            return ReportCard(_historyList[index] as Report);
          },
        )));
  }

  Future getData() async {
    final uid = user!.uid;
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('records')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _historyList =
          List.from(data.docs.map((doc) => Report.fromSnapshot(doc)));
    });
  }
}
