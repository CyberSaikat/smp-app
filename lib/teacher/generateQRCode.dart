// ignore_for_file: must_be_immutable, file_names

import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:student_management/utils/createExcelFile.dart';
import 'package:student_management/utils/location.dart';
import 'package:student_management/utils/utils.dart';

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({super.key});

  @override
  State<GenerateQRCode> createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  TextEditingController nameController = TextEditingController();
  String semester = "1st";
  String department = "CST";
  List<String> subjects = [];
  String subject = "";
  bool loading = false;

  String generateQRData(
      String semester, String department, String subject, uid) {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return "$semester|$department|$subject|$currentDate|$uid";
  }

  getSubjectList() {
    try {
      setState(() {
        loading = true;
      });
      subjects.clear();
      var query = FirebaseFirestore.instance.collection("sgp");
      query
          .doc(semester.toString())
          .collection(department.toString())
          .doc("Subject List")
          .collection("Subjects")
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          for (var doc in querySnapshot.docs) {
            subjects.add(doc.id);
          }
          setState(() {
            loading = false;
            subject = subjects[0];
          });
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

  @override
  void initState() {
    super.initState();
    getSubjectList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.thirdColor,
      appBar: AppBar(
        title: const Text("Generate QR Code"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Utils.customDropDown(
                Utils.sem
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e + " Semester"),
                      ),
                    )
                    .toList(),
                (value) {
                  setState(() {
                    semester = value;
                  });
                  getSubjectList();
                },
                semester,
                padding: const EdgeInsets.only(left: 20, right: 20),
                isFilled: true,
                color: Utils.primaryColor,
                iconData: Icons.bookmark_added_sharp,
              ),
              const SizedBox(height: 20),
              Utils.customDropDown(
                Utils.dept
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                (value) {
                  setState(() {
                    department = value;
                  });
                  getSubjectList();
                },
                department,
                padding: const EdgeInsets.only(left: 20, right: 20),
                isFilled: true,
                color: Utils.primaryColor,
                iconData: Icons.school,
              ),
              if (subjects.isNotEmpty) ...[
                const SizedBox(height: 20),
                Utils.customDropDown(
                  subjects
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  (value) {
                    setState(() {
                      subject = value;
                    });
                  },
                  subjects[0],
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  iconData: Icons.subject,
                ),
                const SizedBox(height: 20),
                Utils.customTextButton(
                  loading,
                  "Generate",
                  () {
                    String qrData = generateQRData(semester, department,
                        subject, Utils.getCurrentUser().uid);
                    Utils.goto(context, QRCodePage(qrData: qrData));
                  },
                ),
              ] else ...[
                const SizedBox(height: 20),
                const Text("No subject found"),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class QRCodePage extends StatefulWidget {
  String qrData = "";
  QRCodePage({super.key, required this.qrData});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  // ignore: non_constant_identifier_names
  Map<String, dynamic>? Students = {};
  late Timer _timer;

  checkDetails() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      var newData = await studentList();
      if (newData != Students) {
        setState(() {
          Students = newData;
        });
      }
    });
  }

  Future<Map<String, dynamic>?> studentList() async {
    var data = widget.qrData.split("|");
    String semester = data[0];
    String department = data[1];
    String subject = data[2];
    String date = data[3];

    var value = await FirebaseFirestore.instance
        .collection("sgp")
        .doc(semester)
        .collection(department)
        .doc("Subject List")
        .collection("Subjects")
        .doc(subject)
        .collection("Attendance")
        .doc(date)
        .get();

    if (value.exists) {
      return value.data();
    } else {
      return null;
    }
  }

  updateLocation() async {
    var data = widget.qrData.split("|");
    String semester = data[0];
    String department = data[1];
    String subject = data[2];
    LocationDetails.requestPermission();
    LocationData? location = await LocationDetails.getLocation();
    double? latitude = location?.latitude;
    double? longitude = location?.longitude;
    await FirebaseFirestore.instance
        .collection("sgp")
        .doc(semester)
        .collection(department)
        .doc("Subject List")
        .collection("Subjects")
        .doc(subject)
        .set({
      "location": {"latitude": latitude, "longitude": longitude}
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    checkDetails();
    updateLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.qrData.split("|");
    String semester = data[0];
    String department = data[1];
    String subject = data[2];
    String date = data[3];
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List attendanceList = [];
          var attendance = await FirebaseFirestore.instance
              .collection("sgp")
              .doc(semester)
              .collection(department)
              .doc("Subject List")
              .collection("Subjects")
              .doc(subject)
              .collection("Attendance")
              .doc(date)
              .get();
          if (attendance.exists) {
            var uid = attendance.data()!.keys.toList();
            for (var i = 0; i < uid.length; i++) {
              var student = await FirebaseFirestore.instance
                  .collection("sgp")
                  .doc(semester)
                  .collection(department)
                  .doc("Student List")
                  .collection("Students")
                  .doc(uid[i])
                  .get();
              var st = {
                'name': student.get("name"),
                'email': student.get("email"),
                'regNo': student.data()!["regNo"] ?? "NA",
              };
              attendanceList.add(st);
            }
          }
          CreateExcel.createExcel(attendanceList);
        },
        child: const Icon(Icons.save_alt_sharp),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: QrImageView(
                data: widget.qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Attendance Marked: ${Students?.length ?? 0}",
                  style: GoogleFonts.poppins(
                      color: Utils.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Students == null
                ? const Center(child: Text("No data found"))
                : ListView.builder(
                    itemCount: Students!.length,
                    itemBuilder: (context, index) {
                      // ignore: unused_local_variable
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("sgp")
                            .doc(semester)
                            .collection(department)
                            .doc("Student List")
                            .collection("Students")
                            .doc(Students!.keys.elementAt(index))
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show loading indicator while data is being fetched
                            return const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ); // You can use any other loading widget
                          } else {
                            if (snapshot.hasError) {
                              // Show error message if there's an error
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData &&
                                snapshot.data!.exists) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              // Build the ListTile with the fetched name
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  tileColor: Utils.tertiaryColor,
                                  textColor: Colors.white,
                                  title: Text(data['name']),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
