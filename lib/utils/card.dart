// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:student_management/utils/utils.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final List<Widget> details;

  const CustomCard({super.key, required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                color: Utils.primaryColor, // Choose a modern color
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...details,
          ],
        ),
      ),
    );
  }
}

class BuildDetails extends StatelessWidget {
  String label = '';
  String value = '';
  BuildDetails({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
