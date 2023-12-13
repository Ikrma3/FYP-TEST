import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = "dashboard-screen";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int total_user = 0;
  int total_donor = 0;
  int total_ngo = 0;

  @override
  void initState() {
    super.initState();
    getValues();
  }

  Future<void> getValues() async {
    var userSnap =
        await FirebaseFirestore.instance.collection('DonorData').get();

    int donorCount = 0;
    int ngoCount = 0;

    for (var doc in userSnap.docs) {
      String userType = doc['userType'];

      print("Document ID: ${doc.id}, userType: $userType");

      if (userType == "Donor") {
        donorCount++;
      } else if (userType == "ngo") {
        ngoCount++;
      } else {
        // Print unknown userType values for debugging
        print("Unknown userType: $userType");
      }
    }

    setState(() {
      total_donor = donorCount;
      total_ngo = ngoCount;
      total_user = userSnap.docs.length;
    });

    print("Total Users: $total_user");
    print("Total Donors: $total_donor");
    print("Total NGOs: $total_ngo");
  }

  @override
  Widget build(BuildContext context) {
    Widget analyticWidget({String? title, int? value}) {
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          height: 100,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value.toString()), // Convert value to a string
                    Icon(Icons.show_chart),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            analyticWidget(title: "Total User", value: total_user),
            analyticWidget(title: "Total Donor", value: total_donor),
            analyticWidget(title: "Total NGO", value: total_ngo),
          ],
        ),
      ],
    );
  }
}
