// ignore_for_file: file_names

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:student_management/utils/utils.dart';

class TempClass extends StatefulWidget {
  const TempClass({super.key});

  @override
  State<TempClass> createState() => _TempClassState();
}

class _TempClassState extends State<TempClass> {
  TextEditingController timeController = TextEditingController();
  String semester = "1st";
  String department = "CST";
  List<String> subjects = [];
  String subject = "";
  bool loading = false;
  List timeSlots = [];
  String day = "Monday";
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  updateTimeSlot(String subject, String semester, String dept) {
    try {
      Utils.showAlertDialog(
        context,
        "Update Class Schedule",
        [
          Utils.customInputBox(
            "Time",
            Icons.watch_later_outlined,
            timeController,
            null,
            isFilled: true,
            readOnly: true,
            onTap: () async {
              await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  return Theme(
                    data: isDarkMode
                        ? ThemeData.dark().copyWith(
                            // Dark mode theme settings
                            primaryColor: Utils.primaryColor,
                            colorScheme: const ColorScheme.dark(
                              primary: Utils.primaryColor,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          )
                        : ThemeData.light().copyWith(
                            // Light mode theme settings
                            primaryColor: Utils.primaryColor,
                            colorScheme: const ColorScheme.light(
                              primary: Utils.primaryColor,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                    child: child!,
                  );
                },
              ).then((value) {
                timeController.text = value!.format(context);
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Utils.customTextButton(
              loading,
              "Update",
              () async {
                if (timeController.text.isNotEmpty) {}
              },
              bgColor: Utils.thirdColor,
              textColor: Utils.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    } catch (e) {
      loading = false;
      Utils.snackBarModal(
        context,
        "Failed to add user: $e",
        AnimatedSnackBarType.error,
      );
    }
  }

  getTimeSlots() {
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
    getTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Utils.thirdColor,
        appBar: AppBar(
          title: const Text('Re-Schedule Class'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                    getTimeSlots();
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
                    getTimeSlots();
                  },
                  department,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  isFilled: true,
                  color: Utils.primaryColor,
                  iconData: Icons.school,
                ),
                const SizedBox(height: 10),
                Utils.customDropDown(
                  daysOfWeek
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  (value) {
                    setState(() {
                      day = value;
                    });
                    getTimeSlots();
                  },
                  day,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  iconData: Icons.calendar_month,
                ),
                const SizedBox(height: 10),
                timeSlots.isEmpty
                    ? const Center(
                        child: Text("No data found"),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              tileColor: Utils.secondaryColor,
                              leading: CircleAvatar(
                                backgroundColor: Utils.primaryColor,
                                child: Text(
                                  (index + 1).toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Utils.whiteColor,
                                  ),
                                ),
                              ),
                              title: Text(timeSlots[index]['subject']),
                              subtitle: Row(
                                children: [
                                  Text(timeSlots[index]['day']),
                                  const SizedBox(width: 10),
                                  Text(timeSlots[index]['time']),
                                ],
                              ),
                              onTap: () async {
                                await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    final isDarkMode =
                                        Theme.of(context).brightness ==
                                            Brightness.dark;
                                    return Theme(
                                      data: isDarkMode
                                          ? ThemeData.dark().copyWith(
                                              // Dark mode theme settings
                                              primaryColor: Utils.primaryColor,
                                              colorScheme:
                                                  const ColorScheme.dark(
                                                primary: Utils.primaryColor,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                            )
                                          : ThemeData.light().copyWith(
                                              // Light mode theme settings
                                              primaryColor: Utils.primaryColor,
                                              colorScheme:
                                                  const ColorScheme.light(
                                                primary: Utils.primaryColor,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                            ),
                                      child: child!,
                                    );
                                  },
                                ).then((value) {
                                  if (value != null) {
                                    timeController.text = value.format(context);
                                    if (timeController.text.isNotEmpty) {
                                      FirebaseFirestore.instance
                                          .collection("sgp")
                                          .doc("Notifications")
                                          .collection("Student")
                                          .doc(semester)
                                          .collection(department)
                                          .doc(timeSlots[index]['subject'])
                                          .set(
                                        {
                                          "time": timeController.text,
                                          "subject": timeSlots[index]
                                              ['subject'],
                                          "date": DateFormat('y-MM-dd')
                                              .format(DateTime.now()),
                                        },
                                      );
                                    }
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
