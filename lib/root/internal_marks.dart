import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_management/utils/card.dart';
import 'package:student_management/utils/utils.dart';

class InternalMarks extends StatefulWidget {
  const InternalMarks({super.key});

  @override
  State<InternalMarks> createState() => _InternalMarksState();
}

class _InternalMarksState extends State<InternalMarks> {
  final exams = [
    ['1st Internal', '1st'],
    ['2nd Internal', '2nd']
  ];
  String selectedExam = '1st';
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
                "Internal Marks",
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            DropdownButtonFormField(
              dropdownColor: Utils.secondaryColor,
              isExpanded: true,
              value: selectedExam,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Utils.primaryColor,
                  ),
                ),
                label: Text(
                  "Select Internal",
                  style: TextStyle(
                    color: Utils.primaryColor,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.school,
                  color: Utils.primaryColor,
                ),
              ),
              hint: Text(
                "Select Internal",
                style: GoogleFonts.poppins(
                  color: Utils.primaryColor,
                ),
              ),
              items: exams
                  .map(
                    (e) => DropdownMenuItem(
                      value: e[1],
                      child: Text(e[0]),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedExam = value.toString();
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            CustomCard(
              title: "$selectedExam Internal Marks",
              details: [
                BuildDetails(label: "Algo", value: "10"),
                BuildDetails(label: "OS", value: "10"),
                BuildDetails(label: "DBMS", value: "10"),
                BuildDetails(label: "CN", value: "10"),
                BuildDetails(label: "DS", value: "10"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
