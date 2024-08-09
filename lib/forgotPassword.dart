// ignore_for_file: file_names, use_build_context_synchronously
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_management/main.dart';
import 'package:student_management/utils/utils.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ForgotPassword();
  }
}

class _ForgotPassword extends StatefulWidget {
  const _ForgotPassword();

  @override
  State<_ForgotPassword> createState() => __ForgotPasswordState();
}

class __ForgotPasswordState extends State<_ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;

  forgotPassword(String email) async {
    try {
      setState(() {
        loading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) {
        setState(() {
          loading = false;
        });
        Utils.snackBarModal(
          context,
          "Password reset link sent to your email address",
          AnimatedSnackBarType.success,
        );
        Utils.gotoReplaced(context, const MainHome());
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      Utils.snackBarModal(
        context,
        e.code.toString(),
        AnimatedSnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forgot  Password"),
        ),
        backgroundColor: Utils.tertiaryColor,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 80,
                  ),
                  Utils.customInputBox(
                    "Email",
                    Icons.email,
                    _emailController,
                    [],
                    color: Utils.whiteColor,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String email = _emailController.text.toString();
                          forgotPassword(email);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Utils.primaryColor,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 30, right: 30),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Send password reset email",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      fontFamily:
                                          GoogleFonts.habibi().fontFamily,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
