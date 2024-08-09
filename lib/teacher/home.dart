import 'package:awesome_floating_bottom_navigation/awesome_floating_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_management/teacher/classes.dart';
import 'package:student_management/teacher/notification.dart';
import 'package:student_management/teacher/profile.dart';
import 'package:student_management/teacher/verifyStudent.dart';
import 'package:student_management/utils/utils.dart';

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TeacherHome();
  }
}

class _TeacherHome extends StatefulWidget {
  const _TeacherHome();

  @override
  State<_TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<_TeacherHome>
    with SingleTickerProviderStateMixin {
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
    // notificationServices.requestPermission();
    // notificationServices.foregroundNotification();
    // notificationServices.firebaseInit(context);
    // notificationServices.isRefreshed();
    // notificationServices.getDeviceToken().then((value) async {
    //   if (value != null) {
    //     String? token = value;
    //     if (user != null) {
    //       user!.updateDisplayName(token);
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final iconList = <IconData>[
      Icons.class_sharp,
      // Icons.grade,
      Icons.notifications,
      Icons.supervised_user_circle_outlined,
      Icons.account_circle,
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
              color: Utils.thirdColor,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 2.8,
              right: 80,
            ),
            transformAlignment: Alignment.centerRight,
            transform: Matrix4.rotationZ(30 * 3.1415927 / 180),
            decoration: BoxDecoration(
              color: Utils.primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 2.3, left: 100),
            transformAlignment: Alignment.centerLeft,
            transform: Matrix4.rotationZ(30 * 3.1415927 / 180),
            decoration: BoxDecoration(
              color: Utils.tertiaryColor,
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
                  ScheduledClasses(),
                  // TeacherInternalMarks(),
                  TeacherNotificationPage(),
                  VerifyStudent(),
                  TeacherProfile(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
