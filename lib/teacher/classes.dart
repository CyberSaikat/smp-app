// ignore_for_file: use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:student_management/teacher/generateQRCode.dart';
import 'package:student_management/utils/utils.dart';

class ScheduledClasses extends StatefulWidget {
  const ScheduledClasses({super.key});

  @override
  State<ScheduledClasses> createState() => _ScheduledClassesState();
}

class _ScheduledClassesState extends State<ScheduledClasses> {
  String scanResult = 'No data yet';
  bool loading = false;
  List timeSlots = [];
  String day = "";
  String? subject;
  String? time;
  DateTime today = DateTime.now();
  String semester = "1st";
  String department = "CST";

// Define a date format to get the name of the day
  DateFormat dateFormat = DateFormat('EEEE');

  getScheduledClasses() async {
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
            if (doc.data()['teacher'] ==
                FirebaseAuth.instance.currentUser!.uid) {
              timeSlots.add(doc.data());
            }
            setState(() {
              loading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
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
    day = dateFormat.format(today);
    getScheduledClasses();
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
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text.rich(
                    TextSpan(
                      text: 'Scheduled  ',
                      style: TextStyle(
                        color: Utils.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Classes',
                          style: TextStyle(
                            color: Utils.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const GenerateQRCode(),
                          type: PageTransitionType.rightToLeft,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.qr_code_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                getScheduledClasses();
              },
              semester,
              padding: const EdgeInsets.only(left: 20, right: 20),
              isFilled: true,
              color: Utils.primaryColor,
              iconData: Icons.bookmark_added_sharp,
            ),
            const SizedBox(height: 10),
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
                getScheduledClasses();
              },
              department,
              padding: const EdgeInsets.only(left: 20, right: 20),
              isFilled: true,
              color: Utils.primaryColor,
              iconData: Icons.school,
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
                getScheduledClasses();
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
                          "No Classes Scheduled",
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
