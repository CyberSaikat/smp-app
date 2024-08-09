// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/utils/nonSkipableLoader.dart';
import 'package:student_management/utils/signature.dart';
import 'package:student_management/utils/utils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  // ignore: prefer_typing_uninitialized_variables
  var userdata;
  bool loading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController regController = TextEditingController();
  TextEditingController semController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dobController = TextEditingController();

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
          .ref("Profile Pics")
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var dept = prefs.getString('dept');
      var sem = prefs.getString('sem');
      User? user = Utils.getCurrentUser();
      var query = FirebaseFirestore.instance.collection("sgp");
      query
          .doc(sem)
          .collection(dept!)
          .doc("Student List")
          .collection("Students")
          .doc(user!.uid)
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
              regController.text = data['regNo'] ?? "N/A";
              semController.text = data['semester'];
              genderController.text = data['gender'];
              dobController.text = data['dob'];
            });
          }
        } else {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
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

  updateRegNo() {
    LoaderManager.showLoader(context);
    FirebaseFirestore.instance
        .collection("sgp")
        .doc(userdata['semester'])
        .collection(userdata['department'])
        .doc("Student List")
        .collection("Students")
        .doc(user!.uid)
        .set(
      {"regNo": regController.text},
      SetOptions(merge: true),
    ).then((value) {
      LoaderManager.hideLoader();
      Utils.snackBarModal(
        context,
        "Registration number updated",
        AnimatedSnackBarType.success,
      );
      setState(() {});
    }).onError((error, stackTrace) {
      LoaderManager.hideLoader();
      Utils.snackBarModal(
        context,
        error.toString(),
        AnimatedSnackBarType.error,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Utils.goto(context, const SignaturePage());
                      },
                      icon: const Icon(
                        size: 32,
                        Icons.info_rounded,
                        color: Utils.primaryColor,
                      ),
                    ),
                    Text(
                      "Profile",
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                  controller: regController,
                  readOnly: regController.text == "N/A" ? false : true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Registration No.",
                    suffix: regController.text == "N/A"
                        ? InkWell(
                            onTap: () {
                              if (regController.text != "N/A" &&
                                  regController.text != "") {
                                updateRegNo();
                              }
                            },
                            child: const Text("Update"),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: semController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Semester",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        controller: genderController,
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Gender",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Date of Birth",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: InkWell(
                  onTap: () {
                    Utils.signOut(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Utils.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                      child: Row(
                        children: [
                          const Spacer(),
                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
