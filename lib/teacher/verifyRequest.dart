// ignore_for_file: file_names, use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_management/utils/nonSkipableLoader.dart';
import 'package:student_management/utils/utils.dart';

class VerifyRequest extends StatefulWidget {
  const VerifyRequest({super.key});

  @override
  State<VerifyRequest> createState() => _VerifyRequestState();
}

class _VerifyRequestState extends State<VerifyRequest> {
  bool loading = true;
  late List studentList = [];
  final List sem = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
  String? semester;
  String? searchText;
  String dept = "CST";

  getStudentList(String sem) async {
    try {
      LoaderManager.showLoader(context);
      var query = FirebaseFirestore.instance.collection("sgp");
      query
          .doc(sem)
          .collection(dept)
          .doc("Student List")
          .collection("Students")
          .get()
          .then((value) {
        LoaderManager.hideLoader();
        setState(() {
          studentList = value.docs;
          loading = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      LoaderManager.hideLoader();
      setState(() {
        loading = false;
      });
      Utils.snackBarModal(context, e.code.toString().replaceAll("-", " "),
          AnimatedSnackBarType.error);
    }
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
          title: const Text("Verify Requests"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      dropdownColor: Utils.secondaryColor,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Utils.primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Utils.primaryColor,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.school,
                          color: Utils.primaryColor,
                        ),
                      ),
                      hint: Text(
                        "Select Semester",
                        style: GoogleFonts.poppins(
                          color: Utils.primaryColor,
                        ),
                      ),
                      items: sem
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text("$e Sem"),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          semester = value.toString();
                        });
                        getStudentList(semester!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Utils.customDropDown(
                      Utils.dept
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      (value) {
                        setState(() {
                          dept = value.toString();
                        });
                        getStudentList(semester!);
                      },
                      dept,
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Utils.whiteColor,
                  hintText: "Search",
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Utils.primaryColor,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Utils.primaryColor,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        searchText = "";
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  if (studentList[index]['is_verified'] == false &&
                      (searchText == null ||
                          studentList[index]['name']
                              .toLowerCase()
                              .contains(searchText!.toLowerCase()) ||
                          studentList[index]['email']
                              .toLowerCase()
                              .contains(searchText!.toLowerCase()))) {
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(studentList[index]['name']),
                        subtitle: Row(
                          children: [
                            Text(studentList[index]['email']),
                            const VerticalDivider(
                              color: Colors.black,
                              thickness: 2,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () async {
                                try {
                                  CollectionReference query = FirebaseFirestore
                                      .instance
                                      .collection("sgp");
                                  query
                                      .doc(semester)
                                      .collection(dept)
                                      .doc("Student List")
                                      .collection("Students")
                                      .doc(studentList[index]['uid'])
                                      .update({"is_verified": true}).then(
                                          (value) {
                                    Utils.snackBarModal(
                                        context,
                                        "Student Verified",
                                        AnimatedSnackBarType.success);
                                    setState(() {
                                      loading = false;
                                    });
                                  });
                                  getStudentList(semester!);
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    loading = false;
                                  });
                                  Utils.snackBarModal(
                                      context,
                                      e.code.toString().replaceAll("-", " "),
                                      AnimatedSnackBarType.error);
                                }
                              },
                              child: const Icon(
                                Icons.verified_outlined,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
