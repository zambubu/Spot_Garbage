import 'package:authentifaction_app/screens/history.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  Report? _report;
  ReportCard(this._report);

  final dateFormatter = DateFormat('EEEE, MMMM dd - h:mm a');

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            "Date Posted: ${dateFormatter.format(_report!.date as DateTime)}",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (_report!.resolved == false) ...[
                          Text("Status: Under Progress"),
                          Spacer(),
                          Icon(Icons.gpp_maybe, color: Colors.amber, size: 30.0)
                        ] else if (_report!.resolved == true) ...[
                          Text("Status: Resolved"),
                          Spacer(),
                          Icon(Icons.gpp_good, color: Colors.green, size: 30.0)
                        ]
                      ],
                    )
                  ],
                ))));
  }
}
