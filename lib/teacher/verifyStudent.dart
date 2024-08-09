// ignore_for_file: file_names, use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_management/teacher/verifyRequest.dart';
import 'package:student_management/utils/nonSkipableLoader.dart';
import 'package:student_management/utils/utils.dart';

class VerifyStudent extends StatefulWidget {
  const VerifyStudent({super.key});

  @override
  State<VerifyStudent> createState() => _VerifyStudentState();
}

class _VerifyStudentState extends State<VerifyStudent> {
  bool loading = true;
  late List studentList = [];
  final List sem = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
  String? semester;
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: const Icon(Icons.person_add_alt_1_rounded),
                  onTap: () {
                    Utils.goto(context, const VerifyRequest());
                  },
                ),
                Text(
                  "Student List",
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    color: Utils.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    (value) {
                      setState(() {
                        dept = value.toString();
                      });
                      getStudentList(semester!);
                    },
                    dept,
                    padding: const EdgeInsets.all(0),
                    iconData: Icons.bookmark_added_sharp,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                if (studentList[index]['is_verified'] == true) {
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
                    ),
                  );
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
