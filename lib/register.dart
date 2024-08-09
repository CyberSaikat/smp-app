// ignore_for_file: file_names, use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:student_management/studentLogin.dart';
import 'package:student_management/utils/utils.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Register();
  }
}

class _Register extends StatefulWidget {
  const _Register();

  @override
  State<_Register> createState() => _RegisterState();
}

class _RegisterState extends State<_Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loader = false;
  bool passwordVisible = true;
  final List sem = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
  List genderItems = ["Male", "Female", "Others"];
  List dept = Utils.dept;
  String? deptSelect;
  String? semester;
  String? gender;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  List collageList = [];
  bool loading = true;
  String selectedCollage = "sgp";

  @override
  void initState() {
    super.initState();
  }

  register(String email, String password, String name, String dob) async {
    try {
      setState(() {
        loader = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        value.user?.updateDisplayName(name);
        FirebaseFirestore.instance
            .collection(selectedCollage)
            .doc(semester!)
            .collection(deptSelect!)
            .doc("Student List")
            .collection("Students")
            .doc(value.user?.uid)
            .set({
          "name": name,
          "dob": dob,
          "email": email,
          "password": password,
          "gender": gender,
          "semester": semester,
          "department": deptSelect,
          "uid": value.user?.uid,
          "is_verified": false,
        }).then((value) {
          setState(() {
            loader = false;
          });
          Utils.snackBarModal(
            context,
            "Registration Success",
            AnimatedSnackBarType.success,
          );
          Utils.gotoReplaced(context, const LoginPage());
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loader = false;
      });
      AnimatedSnackBar.material(
              Casing.titleCase(e.code.toString().replaceAll("-", " ")),
              type: AnimatedSnackBarType.error,
              mobileSnackBarPosition: MobileSnackBarPosition.bottom)
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Utils.primaryColor,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 25,
                  bottom: 535,
                ),
                padding: const EdgeInsets.only(
                  top: 200,
                  left: 100,
                ),
                alignment: Alignment.topRight,
                transform: Matrix4.rotationZ(-55 * 3.1415927 / 180),
                decoration: const BoxDecoration(
                  color: Utils.secondaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 125, right: 20),
                transformAlignment: Alignment.centerRight,
                transform: Matrix4.rotationZ(35 * 3.1415927 / 180),
                decoration: const BoxDecoration(
                    color: Utils.secondaryColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50),
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 380,
                  left: 70,
                ),
                transformAlignment: Alignment.bottomLeft,
                transform: Matrix4.rotationZ(35 * 3.1415927 / 180),
                decoration: const BoxDecoration(
                  color: Utils.thirdColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                width: 1000,
                height: MediaQuery.of(context).size.height + 200,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 300,
                    right: 130,
                  ),
                  transformAlignment: Alignment.centerRight,
                  transform: Matrix4.rotationZ(35 * 3.1415927 / 180),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 25,
                        spreadRadius: 1,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                child: Scrollable(
                  viewportBuilder: (context, position) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Utils.customInputBox("Name", Icons.person, _name, []),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: TextFormField(
                              controller: _dob,
                              readOnly: true,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1970, 1, 1),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
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
                                    _dob.text = DateTime.parse(value.toString())
                                        .toString()
                                        .split(" ")[0];
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 0),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                label: Text(
                                  "Date of Birth",
                                  style: GoogleFonts.poppins(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                prefixIcon: const Icon(
                                  Icons.calendar_month,
                                  color: Utils.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: DropdownButtonFormField(
                              dropdownColor: Utils.secondaryColor,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.transgender,
                                  color: Utils.primaryColor,
                                ),
                              ),
                              hint: Text(
                                "Select Gender",
                                style: GoogleFonts.poppins(
                                  color: Utils.primaryColor,
                                ),
                              ),
                              items: genderItems
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text("$e"),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Utils.customInputBox(
                              "Email", Icons.email, _email, []),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: TextFormField(
                              controller: _password,
                              obscureText: passwordVisible,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 0),
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                label: Text(
                                  "Password",
                                  style: GoogleFonts.poppins(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Utils.primaryColor,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                  child: Icon(
                                    passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: DropdownButtonFormField(
                              dropdownColor: Utils.secondaryColor,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
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
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: DropdownButtonFormField(
                                dropdownColor: Utils.secondaryColor,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Utils.primaryColor,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
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
                                  "Select Department",
                                  style: GoogleFonts.poppins(
                                    color: Utils.primaryColor,
                                  ),
                                ),
                                items: dept
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    deptSelect = val.toString();
                                  });
                                }),
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                loader = true;
                              });
                              String name = _name.text;
                              String dob = _dob.text;
                              String email = _email.text;
                              String password = _password.text;
                              if (name.isNotEmpty &&
                                  dob.isNotEmpty &&
                                  email.isNotEmpty &&
                                  password.isNotEmpty &&
                                  gender != null &&
                                  semester != null &&
                                  deptSelect != null) {
                                if (RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(email)) {
                                  register(email, password, name, dob);
                                } else {
                                  AnimatedSnackBar.material('Enter valid email',
                                          type: AnimatedSnackBarType.error,
                                          mobileSnackBarPosition:
                                              MobileSnackBarPosition.bottom)
                                      .show(context);
                                }
                              } else {
                                AnimatedSnackBar.material(
                                  'Fill all details',
                                  type: AnimatedSnackBarType.error,
                                  mobileSnackBarPosition:
                                      MobileSnackBarPosition.bottom,
                                ).show(context);
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                border: Border.all(color: Utils.primaryColor),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: loader
                                    ? LoadingAnimationWidget.threeRotatingDots(
                                        color: Utils.primaryColor,
                                        size: 30,
                                      )
                                    : const SizedBox(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Register",
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_sharp,
                                              color: Utils.primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OpenContainer(
                                  transitionType: ContainerTransitionType.fade,
                                  closedColor: Colors.transparent,
                                  closedElevation: 0,
                                  closedBuilder: (context, action) {
                                    return Text(
                                      "Already have an account? Login",
                                      style: GoogleFonts.poppins(
                                        color: Utils.primaryColor,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                  openBuilder: (context, action) =>
                                      const LoginPage(),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
