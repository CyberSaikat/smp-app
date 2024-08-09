import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:student_management/studentLogin.dart';
import 'package:student_management/teacherLogin.dart';
import 'package:student_management/utils/utils.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Class Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Utils.primaryColor,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Utils.primaryColor),
            elevation: WidgetStatePropertyAll(15),
            shadowColor: WidgetStatePropertyAll(Colors.black),
          ),
        ),
      ),
      home: const CheckUser(),
    );
  }
}

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  bool animate = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              color: Utils.tertiaryColor,
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
              color: Utils.thirdColor,
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
            top: animate ? 0 : -MediaQuery.of(context).size.height,
            left: MediaQuery.of(context).size.width * 0.05,
            duration: const Duration(milliseconds: 1000),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 35.5),
                    Image.asset("assets/images/icons/icon.png"),
                    const SizedBox(height: 13),
                    const SizedBox(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Smart',
                              ),
                              TextSpan(
                                text: ' Classroom',
                                style: TextStyle(color: Utils.supportiveColor),
                              ),
                              TextSpan(
                                text: ' Management',
                                style: TextStyle(color: Utils.primaryColor),
                              ),
                              TextSpan(
                                text: ' System',
                                style: TextStyle(color: Utils.whiteColor),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontFamily: 'KaushanScript',
                            color: Utils.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      child: Utils.customTextButton(loading, "Login as Student",
                          () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const LoginPage(),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      child: Utils.customTextButton(loading, "Login as Teacher",
                          () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const TeacherLogin(),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
