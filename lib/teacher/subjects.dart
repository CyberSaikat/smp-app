import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_management/utils/utils.dart';

class Subjects extends StatefulWidget {
  const Subjects({super.key});

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> subjects = [];
  bool loading = false;
  final List sem = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
  List dept = Utils.dept;
  String semester = "1st";
  String department = "CST";

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
          if (mounted) {
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Utils.thirdColor,
        appBar: AppBar(
          leadingWidth: 35,
          title: const Text(
            'Add Subjects',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Utils.customDropDown(
                        sem
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        (val) {
                          setState(() {
                            semester = val;
                          });
                          getSubjectList();
                        },
                        semester,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        iconData: Icons.school,
                      ),
                      const SizedBox(height: 20),
                      Utils.customDropDown(
                        dept
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        (val) {
                          setState(() {
                            department = val;
                          });
                          getSubjectList();
                        },
                        department,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        iconData: Icons.bookmark_added_sharp,
                      ),
                      const SizedBox(height: 20),
                      Utils.customInputBox(
                        "Subject Name",
                        Icons.book,
                        _nameController,
                        [],
                        color: Utils.tertiaryColor,
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        isFilled: true,
                      ),
                      const SizedBox(height: 20),
                      Utils.customTextButton(false, "Add Subject", () {
                        if (_formKey.currentState!.validate()) {
                          bool notExits = subjects.every((element) {
                            if (element.toLowerCase() ==
                                _nameController.text.toLowerCase()) {
                              Utils.snackBarModal(
                                  context,
                                  "Subject already exits!",
                                  AnimatedSnackBarType.error);
                              return false;
                            }
                            return true;
                          });
                          if (notExits) {
                            setState(() {
                              subjects.add(_nameController.text.toString());
                            });
                          }
                          _nameController.clear();
                        }
                      }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      "Subjects: ",
                      style: GoogleFonts.roboto(
                        color: Utils.supportiveColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                subjects.isNotEmpty
                    ? SizedBox(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                tileColor: Utils.primaryColor,
                                leading: CircleAvatar(
                                    child: Text((index + 1).toString())),
                                title: Text(subjects[index]),
                                trailing: GestureDetector(
                                  onTap: () {
                                    CollectionReference query =
                                        FirebaseFirestore.instance
                                            .collection("sgp");
                                    query
                                        .doc(semester.toString())
                                        .collection(department.toString())
                                        .doc("Subject List")
                                        .collection("Subjects")
                                        .doc(subjects[index])
                                        .delete()
                                        .then((value) {
                                      setState(() {
                                        subjects.removeAt(index);
                                      });
                                      Utils.snackBarModal(
                                        context,
                                        "Subject Deleted",
                                        AnimatedSnackBarType.info,
                                      );
                                    });
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                                titleTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(
                        height: 20,
                      ),
                const SizedBox(
                  height: 20,
                ),
                Utils.customTextButton(loading, "Save Subjects", () async {
                  if (subjects.isNotEmpty) {
                    setState(() {
                      loading = true;
                    });
                    try {
                      User? user = Utils.getCurrentUser();
                      CollectionReference query =
                          FirebaseFirestore.instance.collection("sgp");
                      for (int i = 0; i < subjects.length; i++) {
                        query
                            .doc(semester.toString())
                            .collection(department.toString())
                            .doc("Subject List")
                            .collection("Subjects")
                            .doc(subjects[i])
                            .set({"teacherUid": user?.uid}).then((value) {
                          setState(() {
                            loading = false;
                          });
                          Utils.snackBarModal(
                              context,
                              "Subjects saved successfully!",
                              AnimatedSnackBarType.success);
                        }).catchError((error) {
                          if (mounted) {
                            setState(() {
                              loading = true;
                            });
                          }
                          Utils.snackBarModal(
                            context,
                            "Failed to add subject: $error",
                            AnimatedSnackBarType.error,
                          );
                        });
                      }
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
                  } else {
                    Utils.snackBarModal(
                      context,
                      "Please add atleast one subject!",
                      AnimatedSnackBarType.error,
                    );
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
