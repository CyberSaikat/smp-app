// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:student_management/forgotPassword.dart';
import 'package:student_management/main.dart';
import 'package:student_management/teacher/home.dart';
import 'package:student_management/teacherRegister.dart';
import 'package:student_management/utils/utils.dart';
import 'package:student_management/utils/verify.dart';

class TeacherLogin extends StatefulWidget {
  const TeacherLogin({super.key});

  @override
  _TeacherLoginState createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loader = false;
  bool passwordVisible = true;

  List collageList = [];
  bool loading = true;
  String selectedCollage = "sgp";

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
            .doc("Staff")
            .collection("Teachers")
            .doc(value.user!.uid)
            .get()
            .then((value) {
          if (value.exists) {
            if (value.data()!["isVerified"] == true) {
              Utils.gotoReplaced(context, const TeacherHome());
            } else {
              Utils.gotoReplaced(context, Verify(user: "Teacher"));
            }
          } else {
            setState(() {
              loader = false;
            });
            Utils.snackBarModal(
                context, "You are not a teacher", AnimatedSnackBarType.error);
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
    } catch (e) {
      setState(() {
        loader = false;
      });
      Utils.snackBarModal(context, e.toString(), AnimatedSnackBarType.error);
    }
  }

  @override
  void initState() {
    super.initState();
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
                  color: Utils.secondaryColor,
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
                  color: Utils.primaryColor,
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
                    color: Utils.primaryColor,
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
                  color: Utils.tertiaryColor,
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
                          height: 100,
                        ),
                        InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              String email = _usernameController.text;
                              String pass = _passwordController.text;
                              if (selectedCollage.isEmpty) {
                                Utils.snackBarModal(
                                    context,
                                    "Select Collage Name",
                                    AnimatedSnackBarType.error);
                                return;
                              }
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
                          height: 200,
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
                                      color: Utils.whiteColor,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                                openBuilder: (context, action) =>
                                    const TeacherRegister(),
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
