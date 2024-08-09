// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/forgotPassword.dart';
import 'package:student_management/main.dart';
import 'package:student_management/register.dart';
import 'package:student_management/utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loader = false;
  bool passwordVisible = true;
  String selectedCollage = "sgp";
  List dept = Utils.dept;
  final List sem = ["1st", "2nd", "3rd", "4th", "5th", "6th"];
  String? semester;
  String? deptSelect;

  login(String email, String password) async {
    try {
      setState(() {
        loader = true;
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        FirebaseFirestore.instance
            .collection(selectedCollage)
            .doc(semester)
            .collection(deptSelect!)
            .doc("Student List")
            .collection("Students")
            .doc(value.user?.uid)
            .get()
            .then((value) async {
          if (value.exists) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("collage", selectedCollage);
            prefs.setString("sem", semester!);
            prefs.setString("dept", deptSelect!);
            Utils.gotoReplaced(context, const CheckUser());
          } else {
            setState(() {
              loader = false;
            });
            Utils.snackBarModal(
                context, "You are not a student", AnimatedSnackBarType.error);
          }
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loader = false;
      });
      Utils.snackBarModal(
          context,
          Casing.titleCase(e.code.toString().replaceAll(RegExp('-'), " ")),
          AnimatedSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                top: 50,
                left: 20,
                child: InkWell(
                  onTap: () {
                    Utils.gotoReplaced(context, const MainHome());
                  },
                  child: const CircleAvatar(
                    backgroundColor: Utils.tertiaryColor,
                    child: Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
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
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 80),
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(bottom: 0),
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
                                "Email",
                                style: GoogleFonts.poppins(
                                  color: Utils.primaryColor,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Utils.primaryColor,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              } else {
                                if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 80),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: passwordVisible,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(bottom: 0),
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
                                  color: Utils.primaryColor,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 80),
                          child: InkWell(
                            onTap: () {
                              Utils.goto(context, const ForgotPassword());
                            },
                            child: const SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Forgot Password?"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              String email = _usernameController.text;
                              String pass = _passwordController.text;
                              login(email, pass);
                            } else {
                              Utils.snackBarModal(context, "Fill all details",
                                  AnimatedSnackBarType.error);
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              border: Border.all(color: Utils.primaryColor),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
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
                                            "Login",
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
                          height: 150,
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
                                    "Don't have an account? Sign up",
                                    style: GoogleFonts.poppins(
                                      color: Utils.primaryColor,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                                openBuilder: (context, action) =>
                                    const Register(),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
