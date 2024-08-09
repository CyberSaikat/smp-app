// ignore_for_file: use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/utils/location.dart';
import 'package:student_management/utils/nonSkipableLoader.dart';
import 'package:student_management/utils/utils.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  String scanResult = 'No data yet';
  bool loading = false;
  List timeSlots = [];
  String day = "";
  String? subject;
  String? time;
  String? semester;
  String? department; // Get today's date
  DateTime today = DateTime.now();

// Define a date format to get the name of the day
  DateFormat dateFormat = DateFormat('EEEE');

  getClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      semester = prefs.getString('sem');
      department = prefs.getString('dept');
    });
    try {
      setState(() {
        loading = true;
      });
      timeSlots.clear();
      var query = FirebaseFirestore.instance.collection("sgp");
      query
          .doc(semester.toString())
          .collection(department.toString())
          .doc("Schedule")
          .collection(day)
          .get()
          .then((value) {
        if (value.size > 0) {
          for (var doc in value.docs) {
            timeSlots.add(doc.data());
            setState(() {
              loading = false;
            });
          }
        } else {
          setState(() {
            loading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      Utils.snackBarModal(
        context,
        "Failed to add user: $e",
        AnimatedSnackBarType.error,
      );
    }
  }

  Future<void> scanQRCode() async {
    String result = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );
    setState(() {
      scanResult = result;
    });
    var data = scanResult.split("|");
    var sem = data[0];
    var dept = data[1];
    var sub = data[2];
    var date = data[3];
    try {
      LoaderManager.showLoader(context);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var query = FirebaseFirestore.instance.collection("sgp");
        query
            .doc(sem)
            .collection(dept)
            .doc("Student List")
            .collection("Students")
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          if (!documentSnapshot.exists) {
            LoaderManager.hideLoader();
            Utils.snackBarModal(
              context,
              "You are not enrolled in this class",
              AnimatedSnackBarType.error,
            );
            return;
          } else {
            LocationDetails.requestPermission();
            var location = await LocationDetails.getLocation();
            var lat = location?.latitude;
            var long = location?.longitude;
            var targetLocation = await FirebaseFirestore.instance
                .collection("sgp")
                .doc(sem)
                .collection(dept)
                .doc("Subject List")
                .collection("Subjects")
                .doc(sub)
                .get();
            if (targetLocation.exists) {
              var targetLat = targetLocation.data()!["location"]['latitude'];
              var targetLong = targetLocation.data()!["location"]['longitude'];
              // print("Target Location: $targetLat, $targetLong");
              var distance = LocationDetails.calculateDistance(
                  lat!, long!, targetLat, targetLong);
              // print("Distance: $distance");
              if (distance < 30) {
                await FirebaseFirestore.instance
                    .collection("sgp")
                    .doc(sem)
                    .collection(dept)
                    .doc("Subject List")
                    .collection("Subjects")
                    .doc(sub)
                    .collection("Attendance")
                    .doc(date)
                    .set(
                  {
                    Utils.getCurrentUser().uid: "true",
                  },
                  SetOptions(merge: true),
                ).then((value) {
                  LoaderManager.hideLoader();
                  Utils.snackBarModal(
                    context,
                    "Attendance marked",
                    AnimatedSnackBarType.success,
                  );
                });
              } else {
                LoaderManager.hideLoader();
                Utils.snackBarModal(
                  context,
                  "You are not near the class",
                  AnimatedSnackBarType.error,
                );
              }
            }
          }
        });
      }
    } catch (e) {
      LoaderManager.hideLoader();
      Utils.snackBarModal(
        context,
        e.toString(),
        AnimatedSnackBarType.error,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    day = dateFormat.format(today);
    getClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Classes",
                    textAlign: TextAlign.end,
                    style: GoogleFonts.poppins(
                      color: Utils.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: scanQRCode,
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Utils.customDropDown(
              Utils.days
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              (value) {
                setState(() {
                  day = value;
                });
                getClasses();
              },
              day,
              padding: const EdgeInsets.only(left: 20, right: 20),
              iconData: Icons.calendar_month,
            ),
            loading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : timeSlots.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "No classes scheduled",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                timeSlots[index]['subject'],
                              ),
                              subtitle: Row(
                                children: [
                                  Text(timeSlots[index]['day']),
                                  const VerticalDivider(
                                    color: Colors.black,
                                    thickness: 2,
                                  ),
                                  Text(timeSlots[index]['time']),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
