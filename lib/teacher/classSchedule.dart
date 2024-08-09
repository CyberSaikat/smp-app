// ignore_for_file: file_names

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_management/utils/utils.dart';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  State<ClassSchedule> createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
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

  void addTimeSlot() {
    if (timeController.text != "") {
      bool isTimeSlotExist = false;

      if (timeSlots.isNotEmpty) {
        for (var timeSlot in timeSlots) {
          if (timeSlot['time'] == timeController.text) {
            isTimeSlotExist = true;
            break;
          }
        }
      }

      if (!isTimeSlotExist) {
        setState(() {
          timeSlots.add({
            'day': day,
            'subject': subject,
            'time': timeController.text,
            'teacher': FirebaseAuth.instance.currentUser!.uid
          });
          timeController.clear();
        });
      } else {
        Utils.snackBarModal(context, "The time slot already exists.",
            AnimatedSnackBarType.error);
      }
    }
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
    getSubjectList();
    getTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        backgroundColor: Utils.thirdColor,
        appBar: AppBar(
          title: const Text("Class Schedule"),
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
                    getSubjectList();
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
                    getSubjectList();
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
                if (subjects.isNotEmpty) ...[
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Utils.customInputBox(
                    "Time",
                    Icons.access_time_outlined,
                    timeController,
                    [],
                    readOnly: true,
                    isFilled: true,
                    padding: const EdgeInsets.only(left: 20, right: 20),
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
                        setState(() {
                          timeController.text = value!.format(context);
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Utils.customTextButton(
                    loading,
                    "Add Time Slot",
                    () {
                      addTimeSlot();
                    },
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                timeSlots.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  if (timeSlots.isNotEmpty)
                    Utils.customTextButton(
                      loading,
                      "Submit",
                      () async {
                        if (timeSlots.isNotEmpty) {
                          for (var element in timeSlots) {
                            FirebaseFirestore.instance
                                .collection("sgp")
                                .doc(semester)
                                .collection(department)
                                .doc("Schedule")
                                .collection(day)
                                .doc(element['time'])
                                .set({
                              "subject": element['subject'],
                              "teacher": element['teacher'],
                              "day": element['day'],
                              "time": element['time'],
                            }).then((value) {
                              Utils.snackBarModal(
                                context,
                                "Time slot added successfully.",
                                AnimatedSnackBarType.success,
                              );
                            });
                          }
                        }
                      },
                    ),
                ] else ...[
                  const SizedBox(height: 10),
                  const Text("No subject found"),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
