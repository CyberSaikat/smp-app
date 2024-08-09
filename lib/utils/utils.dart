// ignore_for_file: avoid_init_to_null

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/main.dart';
import 'package:student_management/root/home.dart';
import 'package:student_management/teacher/home.dart';
import 'package:student_management/utils/location.dart';
import 'package:student_management/utils/permissions.dart';
import 'package:student_management/utils/verify.dart';

class Utils {
  static const Color primaryColor = Color.fromRGBO(10, 78, 138, 1);
  static const Color secondaryColor = Color.fromRGBO(193, 224, 251, 1);
  static const Color thirdColor = Color.fromRGBO(134, 199, 255, 1);
  static const Color supportiveColor = Color.fromRGBO(29, 45, 80, 1);
  static const Color whiteColor = Color.fromRGBO(255, 255, 255, 1);
  static const Color tertiaryColor = Color.fromRGBO(19, 59, 92, 1);
  static final List sem = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
  static final List dept = [
    "CST",
    "EE",
    "ETCE",
    "EIE",
    "CE",
    "ARCH",
    "Pharmecy"
  ];
  static List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static customInputBox(
    String text,
    IconData iconData,
    TextEditingController controller,
    List<TextInputFormatter>? inputFormatters, {
    TextInputType? keyboardType = TextInputType.text,
    Color color = Utils.primaryColor,
    EdgeInsets padding = const EdgeInsets.only(left: 20, right: 40),
    bool isFilled = false,
    Color fillColor = Utils.whiteColor,
    Function()? onTap = null,
    bool readOnly = false,
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        onTap: onTap,
        readOnly: readOnly,
        style: GoogleFonts.poppins(
          color: color,
        ),
        decoration: InputDecoration(
          filled: isFilled,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.only(bottom: 0),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: color,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: color,
            ),
          ),
          label: Text(
            text,
            style: GoogleFonts.poppins(
              color: color,
            ),
          ),
          prefixIcon: Icon(
            iconData,
            color: color,
          ),
        ),
      ),
    );
  }

  static customDropDown(
    List<DropdownMenuItem<Object>>? items,
    Function onChangedFunc,
    String value, {
    EdgeInsets padding = const EdgeInsets.only(left: 20, right: 40),
    bool isFilled = true,
    Color fillColor = Utils.whiteColor,
    Color color = Utils.primaryColor,
    IconData iconData = Icons.arrow_drop_down,
  }) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField(
        dropdownColor: Utils.secondaryColor,
        isExpanded: true,
        decoration: InputDecoration(
          filled: isFilled,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: color,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: color,
            ),
          ),
          prefixIcon: Icon(
            iconData,
            color: color,
          ),
        ),
        hint: Text(
          "Select Semester",
          style: GoogleFonts.poppins(
            color: color,
          ),
        ),
        value: value,
        items: items,
        onChanged: (value) {
          onChangedFunc(value);
        },
      ),
    );
  }

  static customTextButton(
    bool loading,
    String text,
    VoidCallback callback, {
    double fontSize = 20,
    Color bgColor = Utils.primaryColor,
    Color textColor = Utils.whiteColor,
  }) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            loading ? null : callback();
          },
          style: TextButton.styleFrom(
            backgroundColor: bgColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          fontFamily: GoogleFonts.habibi().fontFamily,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static goto(context, Widget widget,
      {PageTransitionType transitionType = PageTransitionType.rightToLeft}) {
    return Navigator.push(
      context,
      PageTransition(
        child: widget,
        type: transitionType,
      ),
    );
  }

  static gotoReplaced(context, Widget widget) {
    return Navigator.pushReplacement(
      context,
      PageTransition(
        child: widget,
        type: PageTransitionType.rightToLeft,
      ),
    );
  }

  static snackBarModal(
      BuildContext context, String msg, AnimatedSnackBarType type) {
    return AnimatedSnackBar.material(
      msg,
      type: type,
      duration: const Duration(seconds: 5),
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 100,
      ),
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
    ).show(context);
  }

  static void showAlertDialog(
      BuildContext context, String title, List<Widget> content,
      {Color bgColor = Utils.primaryColor}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: Border.all(color: Utils.primaryColor),
          backgroundColor: bgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Utils.whiteColor,
                    ),
                  ),
                ),
              ),
              ...content
            ],
          ),
        );
      },
    );
  }

  static signOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    gotoReplaced(context, const MainHome());
  }
}

class CheckUser extends StatelessWidget {
  const CheckUser({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator if data is still loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Show error message if an error occurs
          return Text('Error: ${snapshot.error}');
        } else {
          if (snapshot.data == "false") {
            return const MainHome();
          } else {
            if (snapshot.data == "StudentVerify") {
              return Verify(
                user: 'Student',
              );
            } else if (snapshot.data == "TeacherVerify") {
              return Verify(
                user: 'Teacher',
              );
            } else if (snapshot.data == "Teacher") {
              return const TeacherHome();
            } else {
              return const Home();
            }
          }
        }
      },
    );
  }

  Future<String> checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    await LocationDetails.requestPermission();
    await RequestPermission.requestStoragePermission();
    if (user != null) {
      const String collage = "sgp";
      final User? user = Utils.getCurrentUser();
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collage)
          .doc('Staff')
          .collection('Teachers')
          .doc(user?.uid)
          .get();
      if (documentSnapshot.exists) {
        final value = await FirebaseFirestore.instance
            .collection("sgp")
            .doc("Staff")
            .collection("Teachers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        if (value.exists) {
          if (value.data()!["isVerified"] == true) {
            return "Teacher";
          } else {
            return "TeacherVerify";
          }
        } else {
          return "false";
        }
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var dept = prefs.getString('dept');
        var sem = prefs.getString('sem');
        final value = await FirebaseFirestore.instance
            .collection("sgp")
            .doc(sem)
            .collection(dept!)
            .doc("Student List")
            .collection("Students")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        if (value.exists) {
          if (value.data()!["is_verified"] == true) {
            return "Student";
          } else {
            return "StudentVerify";
          }
        } else {
          return "false";
        }
      }
    } else {
      return "false";
    }
  }
}
