// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/root/home.dart';
import 'package:student_management/teacher/home.dart';
import 'package:student_management/utils/utils.dart';

class Verify extends StatefulWidget {
  String user = "";
  Verify({super.key, required this.user});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  bool loading = false;

  void verify() async {
    if (widget.user == "Student") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var dept = prefs.getString('dept');
      var sem = prefs.getString('sem');
      setState(() {
        loading = true;
      });
      FirebaseFirestore.instance
          .collection("sgp")
          .doc(sem)
          .collection(dept!)
          .doc("Student List")
          .collection("Students")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        if (value.exists) {
          if (value.data()!["is_verified"] == true) {
            Utils.gotoReplaced(context, const Home());
          }
        }
      });
    } else if (widget.user == "Teacher") {
      setState(() {
        loading = true;
      });
      FirebaseFirestore.instance
          .collection("sgp")
          .doc("Staff")
          .collection("Teachers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          loading = false;
        });
        if (value.exists) {
          if (value.data()!["isVerified"] == true) {
            Utils.gotoReplaced(context, const TeacherHome());
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    verify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.supportiveColor,
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Image.asset("assets/images/verify.png"),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "Verification Pending",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "Please wait while your account is verified",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Utils.customTextButton(
                        loading,
                        "Check Status",
                        () {
                          verify();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
