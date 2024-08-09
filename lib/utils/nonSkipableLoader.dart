// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:student_management/utils/utils.dart';

class NonSkippableLoader extends StatelessWidget {
  const NonSkippableLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Utils.tertiaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16.0),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoaderManager {
  static OverlayEntry? _overlayEntry;

  static void showLoader(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.transparent,
          child: const NonSkippableLoader(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hideLoader() {
    _overlayEntry?.remove();
  }
}
