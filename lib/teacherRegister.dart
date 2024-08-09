// ignore_for_file: file_names, use_build_context_synchronously, unused_local_variable

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:student_management/teacherLogin.dart';
import 'package:student_management/utils/utils.dart';

class TeacherRegister extends StatelessWidget {
  const TeacherRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TeacherRegister();
  }
}

class _TeacherRegister extends StatefulWidget {
  const _TeacherRegister();

  @override
  State<_TeacherRegister> createState() => _TeacherRegisterState();
}

class _TeacherRegisterState extends State<_TeacherRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loader = false;
  bool passwordVisible = true;
  bool animate = false;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  List collageList = [];
  bool loading = true;
  String selectedCollage = "sgp";
  List dept = Utils.dept;
  String? deptSelect;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        animate = true;
      });
    });
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
              AnimatedContainer(
                margin: EdgeInsets.only(
                  left: 25,
                  bottom: animate ? 535 : MediaQuery.of(context).size.height,
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
                duration: const Duration(milliseconds: 500),
              ),
              AnimatedContainer(
                margin: EdgeInsets.only(
                  left: 125,
                  right: 0,
                  bottom: animate ? 0 : MediaQuery.of(context).size.height,
                ),
                transformAlignment: Alignment.centerRight,
                transform: Matrix4.rotationZ(35 * 3.1415927 / 180),
                decoration: const BoxDecoration(
                  color: Utils.thirdColor,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
                duration: const Duration(milliseconds: 500),
              ),
              AnimatedContainer(
                margin: EdgeInsets.only(
                  top: animate ? 380 : MediaQuery.of(context).size.height,
                  left: 90,
                ),
                transformAlignment: Alignment.bottomLeft,
                transform: Matrix4.rotationZ(35 * 3.1415927 / 180),
                decoration: const BoxDecoration(
                  color: Utils.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                  ),
                ),
                duration: const Duration(milliseconds: 500),
              ),
              AnimatedPositioned(
                right: animate ? 0 : MediaQuery.of(context).size.width,
                width: 1000,
                height: MediaQuery.of(context).size.height + 200,
                duration: const Duration(milliseconds: 500),
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
              AnimatedPositioned(
                right: animate ? 0 : MediaQuery.of(context).size.width,
                width: 1000,
                height: MediaQuery.of(context).size.height + 200,
                duration: const Duration(milliseconds: 500),
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
              AnimatedPositioned(
                duration: const Duration(milliseconds: 750),
                top: animate ? 150 : -MediaQuery.of(context).size.height,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
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
                        Utils.customInputBox("Name", Icons.person, _name, []),
                        const SizedBox(
                          height: 20,
                        ),
                        Utils.customInputBox("Email", Icons.email, _email, []),
                        const SizedBox(
                          height: 20,
                        ),
                        Utils.customInputBox(
                            "Phone No",
                            Icons.phone,
                            _phone,
                            [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]+$')),
                            ],
                            keyboardType: TextInputType.number),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 40),
                          child: TextFormField(
                            controller: _password,
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
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        InkWell(
                          onTap: () async {
                            String name = _name.text;
                            String email = _email.text;
                            String password = _password.text;
                            if (name.isNotEmpty &&
                                email.isNotEmpty &&
                                password.isNotEmpty) {
                              if (RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              ).hasMatch(email)) {
                                try {
                                  setState(() {
                                    loader = true;
                                  });
                                  var userCredential =
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  )
                                          .then((value) {
                                    FirebaseFirestore.instance
                                        .collection(selectedCollage)
                                        .doc("Staff")
                                        .collection("Teachers")
                                        .doc(value.user!.uid)
                                        .set({
                                      "name": name,
                                      "email": email,
                                      "phone": _phone.text,
                                      "dept": deptSelect,
                                      "collage": selectedCollage,
                                      "uid": value.user!.uid,
                                      "password": password,
                                      "isVerified": false,
                                    }).then((value) {
                                      setState(() {
                                        loader = false;
                                      });
                                      Utils.snackBarModal(
                                          context,
                                          "Registered Successfully",
                                          AnimatedSnackBarType.success);
                                      Utils.gotoReplaced(
                                          context, const TeacherLogin());
                                    });
                                  });
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    loader = false;
                                  });
                                  AnimatedSnackBar.material(
                                          Casing.titleCase(e.code
                                              .toString()
                                              .replaceAll("-", " ")),
                                          type: AnimatedSnackBarType.error,
                                          mobileSnackBarPosition:
                                              MobileSnackBarPosition.bottom)
                                      .show(context);
                                }
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
                          height: 100,
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
                                      color: Utils.whiteColor,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                                openBuilder: (context, action) =>
                                    const TeacherLogin(),
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
