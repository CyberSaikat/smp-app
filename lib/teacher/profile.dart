// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_management/teacher/classSchedule.dart';
import 'package:student_management/teacher/subjects.dart';
import 'package:student_management/teacher/tempClass.dart';
import 'package:student_management/utils/nonSkipableLoader.dart';
import 'package:student_management/utils/signature.dart';
import 'package:student_management/utils/utils.dart';

class TeacherProfile extends StatefulWidget {
  const TeacherProfile({super.key});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  User? user;
  var userdata;
  bool loading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController collageUid = TextEditingController();

  void getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  void pickImage(ImageSource imageSource) async {
    try {
      LoaderManager.showLoader(context);
      var photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) {
        LoaderManager.hideLoader();
        return;
      }
      final tempImage = File(photo.path);
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("TeacherProfile Pics")
          .child(user!.email.toString())
          .putFile(tempImage);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await user?.updatePhotoURL(downloadUrl);
      LoaderManager.hideLoader();
      Utils.snackBarModal(
        context,
        "Photo updated",
        AnimatedSnackBarType.success,
      );
      setState(() {
        getCurrentUser();
      });
    } catch (e) {
      LoaderManager.hideLoader();
      Utils.snackBarModal(
        context,
        e.toString(),
        AnimatedSnackBarType.error,
      );
    }
  }

  getUserData() async {
    try {
      setState(() {
        loading = true;
      });
      User? user = Utils.getCurrentUser();
      var query = FirebaseFirestore.instance.collection("sgp");
      query
          .doc("Staff")
          .collection("Teachers")
          .doc(user?.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data()! as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              loading = false;
              userdata = data;
              nameController.text = data['name'];
              emailController.text = data['email'];
              phoneController.text = data['phone'];
              collageUid.text = Casing.upperCase("SGP".toString());
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
    getCurrentUser();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                Text(
                  "Profile",
                  style: GoogleFonts.poppins(
                    color: Utils.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Utils.goto(context, const SignaturePage());
                  },
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Utils.signOut(context);
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    maxRadius: 50,
                    backgroundImage: NetworkImage(
                      user!.photoURL == null
                          ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png"
                          : user!.photoURL.toString(),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                Utils.showAlertDialog(
                                  context,
                                  "Upload image from",
                                  [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.camera,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        "Camera",
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        pickImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    const Divider(
                                      color: Colors.white,
                                      height: 2,
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.photo_album,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        "Gallery",
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        pickImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Utils.tertiaryColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: TextField(
                      controller: nameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        filled: true,
                        fillColor: Colors.white,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Name",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: emailController,
                readOnly: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Email",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: phoneController,
                readOnly: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Phone Number",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: collageUid,
                readOnly: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Collage Unique ID",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: InkWell(
                onTap: () {
                  Utils.goto(context, const Subjects());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Utils.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          "Subjects",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.book_outlined,
                          color: Colors.white,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: InkWell(
                onTap: () {
                  Utils.goto(context, const ClassSchedule());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Utils.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          "Class Routine",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.lock_clock,
                          color: Colors.white,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: InkWell(
                onTap: () {
                  Utils.goto(context, const TempClass());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Utils.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          "Re-Schedule Class",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.lock_clock,
                          color: Colors.white,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
