// ignore_for_file: use_build_context_synchronously

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/utils/utils.dart';

class TeacherNotificationPage extends StatefulWidget {
  const TeacherNotificationPage({super.key});

  @override
  State<TeacherNotificationPage> createState() =>
      _TeacherNotificationPageState();
}

class _TeacherNotificationPageState extends State<TeacherNotificationPage> {
  bool loading = false;
  List notifications = [];

  getNotifications() async {
    try {
      setState(() {
        loading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var dept = prefs.getString('dept');
      var sem = prefs.getString('sem');
      FirebaseFirestore.instance
          .collection("sgp")
          .doc("Notifications")
          .collection("Teacher")
          .doc(sem)
          .collection(dept!)
          .get()
          .then((value) {
        for (var element in value.docs) {
          setState(() {
            notifications.add(element.data());
          });
        }
      });
    } catch (e) {
      Utils.snackBarModal(context, e.toString(), AnimatedSnackBarType.error);
    }
  }

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Notifications",
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            notifications.isEmpty
                ? Text("No Notifications",
                    style: GoogleFonts.poppins(color: Colors.white))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        notifications.length > 10 ? 10 : notifications.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.notifications,
                          ),
                          title: Text(
                            notifications[index]["subject"],
                          ),
                          subtitle: Text(
                              "class has been rescheduled to ${notifications[index]["time"]}"),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
