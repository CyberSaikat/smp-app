// ignore_for_file: use_build_context_synchronously

import 'package:awesome_floating_bottom_navigation/awesome_floating_bottom_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_management/root/classes.dart';
import 'package:student_management/root/notification.dart';
import 'package:student_management/root/profile.dart';
import 'package:student_management/utils/utils.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Home();
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> with SingleTickerProviderStateMixin {
  int _index = 0;
  final controller = ScrollController();
  late TabController tabController;
  late int currentPage;
  // NotificationServices notificationServices = NotificationServices();
  User? user = Utils.getCurrentUser();

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  defaultConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString('dept');
    prefs.getString('sem');
    // notificationServices.requestPermission();
    // notificationServices.foregroundNotification();
    // notificationServices.firebaseInit(context);
    // notificationServices.isRefreshed();
    // notificationServices.getDeviceToken().then((value) async {
    //   if (value != null) {
    //     String? token = value;
    //     if (user != null) {
    //       User? user = Utils.getCurrentUser();
    //       var query = FirebaseFirestore.instance.collection("sgp");
    //       query
    //           .doc(sem)
    //           .collection(dept!)
    //           .doc("Student List")
    //           .collection("Students")
    //           .doc(user!.uid)
    //           .update({"fcmToken": token});
    //     }
    //   }
    // });
  }

  deleteNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dept = prefs.getString('dept');
    var sem = prefs.getString('sem');
    FirebaseFirestore.instance
        .collection("sgp")
        .doc("Notifications")
        .collection("Student")
        .doc(sem)
        .collection(dept!)
        .where("date",
            isNotEqualTo: DateFormat('y-MM-dd').format(DateTime.now()))
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    tabController = TabController(length: 3, vsync: this);
    tabController.animation!.addListener(
      () {
        final value = tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
    defaultConfig();
    deleteNotification();
  }

  @override
  Widget build(BuildContext context) {
    final iconList = <IconData>[
      Icons.class_sharp,
      // Icons.grade,
      Icons.notifications,
      Icons.account_circle
    ];
    PageController pageController = PageController();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: AwesomeFloatingBottomNavigation.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.white : Utils.secondaryColor;
          return Center(
            child: Icon(
              iconList[index],
              size: 24,
              color: color,
            ),
          );
        },
        backgroundColor: Utils.primaryColor,
        activeIndex: _index,
        splashColor: Colors.green.shade400,
        splashSpeedInMilliseconds: 300,
        cornerRadius: 32,
        onTap: (index) {
          setState(() {
            _index = index;
            pageController.jumpToPage(index);
          });
        },
        padding: const EdgeInsets.all(16),
        leftAndRightBonusPadding: 48,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.grey,
        ),
        navigationBarType: NavigationBarType.center,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Utils.secondaryColor,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 2.8,
              right: 80,
            ),
            transformAlignment: Alignment.centerRight,
            transform: Matrix4.rotationZ(40 * 3.1415927 / 180),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(10, 78, 138, 1),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 2.8, left: 100),
            transformAlignment: Alignment.centerLeft,
            transform: Matrix4.rotationZ(40 * 3.1415927 / 180),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(134, 199, 255, 1),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                    pageController.jumpToPage(index);
                  });
                },
                children: const [
                  Classes(),
                  // InternalMarks(),
                  NotificationPage(),
                  Profile(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  final IconData iconData;

  const NavigationScreen(this.iconData, {super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void didUpdateWidget(NavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData) {
      _startAnimation();
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    super.initState();
  }

  _startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        children: [
          const SizedBox(height: 64),
          Center(
            child: Icon(
              widget.iconData,
              color: Colors.green,
              size: 160,
            ),
          ),
        ],
      ),
    );
  }
}
