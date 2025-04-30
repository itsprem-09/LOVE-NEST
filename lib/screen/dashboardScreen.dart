import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matrimony/db/db.dart';
import 'package:matrimony/model/loginDetailsDb.dart';
import 'package:matrimony/model/userDb.dart';
import 'package:matrimony/screen/aboutUs.dart';
import 'package:matrimony/screen/addUserFormScreen.dart';
import 'package:matrimony/screen/analyticsPage.dart';
import 'package:matrimony/screen/faqScreen.dart';
import 'package:matrimony/screen/feedbackScreen.dart';
import 'package:matrimony/screen/loginSignUp.dart';
import 'package:matrimony/screen/notification.dart';
import 'package:matrimony/screen/view_users.dart';
import 'package:matrimony/screen/wishlist.dart';
import 'package:page_transition/page_transition.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class DashboardScreen extends StatefulWidget {
  var userObject;
  DashboardScreen({super.key, this.userObject});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List cateName = ['Add User', 'User List', 'Favourite User', 'About Us'];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // User? user;
  UserDb? user;
  LoginDetails login = LoginDetails();

  @override
  void initState() {
    if(widget.userObject != null){
      user = widget.userObject;
    }
    else{
      // user = User();
      user = UserDb();
    }
    displayUserImage();
    _updateLastLogin();
    super.initState();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false); // Clear the login status
    print("User logged out");
  }

  Future<void> _updateLastLogin() async {
    // Call the method to update lastLogin if the user is logged in
    print('update last login called');
    await login.updateLastLoginOnAppStart();
  }

  Future<String?> displayUserName() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int loggedUserId = sharedPreferences.getInt('loggedUserId')!;

    final user = await login.getLoggedInUserByLoginId(loggedUserId);

    if(user != null){
      return user[MyDatabase.USERNAME];
    }
    return null;
  }

  Future<String?> displayUserEmail() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int loggedUserId = sharedPreferences.getInt('loggedUserId')!;

    final user = await login.getLoggedInUserByLoginId(loggedUserId);

    if(user != null){
      return user[MyDatabase.LOGIN_EMAIL];
    }
    return null;
  }

  Future<String?> displayLastLogin() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int loggedUserId = sharedPreferences.getInt('loggedUserId')!;

    final user = await login.getLoggedInUserByLoginId(loggedUserId);

    if(user != null){
      return user[MyDatabase.LAST_LOGIN];
    }
    return null;
  }

  Future<Uint8List?> displayUserImage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int loggedUserId = sharedPreferences.getInt('loggedUserId')!;

    final user = await login.getLoggedInUserByLoginId(loggedUserId);

    if (user != null) {
      return user[MyDatabase.PROFILE_PICTURE];
    }
    return null;
  }

  List<Icon> cateIcons = [Icon(Icons.person_add, color: Color.fromARGB(255, 255, 222, 164), size: 45,),Icon(Icons.assignment_ind_rounded, color: Color.fromARGB(255, 255, 222, 164), size: 45,),Icon(Icons.favorite_rounded, color: Color.fromARGB(255, 255, 222, 164), size: 45,),Icon(Icons.info_outlined, color: Color.fromARGB(255, 255, 222, 164), size: 45,)];

  @override
  Widget build(BuildContext context) {

    final Color primaryColor = Color(0xFF594226);
    final Color accentColor = Color(0xFFFFDEA4);
    final Color drawerBgColor = Color(0xFFF5E6D3);

    List screens = [AddUserFormScreen(userObject: user,), ViewUsers(userObject: user,), Wishlist(userObject: user,), AboutUs(userObject: user,)];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: drawerBgColor,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
                child: Container(
                  color: drawerBgColor,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(40),
                        ),
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor.withOpacity(0.9), primaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  child: FutureBuilder(future: displayUserImage(), builder: (context, snapshot) {
                                    if(snapshot.connectionState == ConnectionState.waiting){
                                      return CircularProgressIndicator();
                                    }
                                    if(snapshot.hasData && snapshot.data != null){
                                      return CircleAvatar(
                                        radius: 40,
                                        backgroundImage: MemoryImage(snapshot.data!),
                                      );
                                    }
                                    else{
                                      return CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage('assets/images/profile.jpg'),
                                      );
                                    }
                                  },)
                                ),
                                SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(future: displayUserName(), builder: (context, snapshot) {
                                      if(snapshot.connectionState == ConnectionState.waiting){
                                        return CircularProgressIndicator();
                                      }
                                      if(snapshot.hasData && snapshot.data != null){
                                        return Container(
                                          width: MediaQuery.of(context).size.width*0.455,
                                          child: Text(
                                            snapshot.data!,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(255, 255, 222, 164),
                                            ),
                                          ),
                                        );
                                      }
                                      else{
                                        return Text(
                                          'Alex',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 255, 222, 164),
                                          ),
                                        );
                                      }
                                    },),
                                    SizedBox(height: 8),
                                    FutureBuilder(future: displayUserEmail(), builder: (context, snapshot) {
                                      if(snapshot.connectionState == ConnectionState.waiting){
                                        return CircularProgressIndicator();
                                      }
                                      if(snapshot.hasData && snapshot.data != null){
                                        return Container(
                                          width: MediaQuery.of(context).size.width*0.455,
                                          child: Text(
                                            snapshot.data!,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(255, 255, 222, 164).withOpacity(0.8),
                                            ),
                                          ),
                                        );
                                      }
                                      else{
                                        return Text(
                                          'alex@example.com',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(255, 255, 222, 164).withOpacity(0.8),
                                          ),
                                        );
                                      }
                                    },),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerOption(
                      icon: Icons.help_outline,
                      title: 'FAQs',
                      color: primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: FaqScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerOption(
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      color: primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerOption(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      color: primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      color: primaryColor.withOpacity(0.2),
                      height: 20,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    _buildDrawerOption(
                      icon: Icons.analytics_outlined,
                      title: 'Analytics',
                      color: primaryColor,
                      onTap: () {
                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: AdminAnalyticsPage()),);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0, bottom: 20),
                child: _buildDrawerOption(
                  icon: Icons.logout,
                  title: 'Log Out',
                  color: primaryColor,
                  onTap: () {
                    PanaraConfirmDialog.show(
                      context,
                      title: "Logout",
                      message:
                      "Are you sure you want to Logout?",
                      confirmButtonText: "Logout",
                      cancelButtonText: "Cancel",
                      onTapCancel: () {
                        Navigator.pop(context);
                      },
                      onTapConfirm: () async {
                        await logout();
                        Navigator.pop(context);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                      },
                      panaraDialogType: PanaraDialogType.error,
                      barrierDismissible: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Material(
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Stack(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.32,
                    decoration: BoxDecoration(
                      // color: Color.fromARGB(255, 3, 192, 129),
                      color: Color(0xFF594226),
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(70),),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: Icon(Icons.sort, size: 40, color: Colors.white,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: FutureBuilder(future: displayUserImage(), builder: (context, snapshot) {
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return CircularProgressIndicator();
                                }
                                if(snapshot.hasData && snapshot.data != null){
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                      image: DecorationImage(image: MemoryImage(snapshot.data!), fit: BoxFit.cover),
                                    ),
                                  );
                                }
                                else{
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                      image: DecorationImage(image: AssetImage('assets/images/profile.jpg'), fit: BoxFit.cover),
                                    )
                                  );
                                }
                              },)
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(future: displayUserName(), builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return CircularProgressIndicator();
                              }
                              if(snapshot.hasData && snapshot.data != null){
                                return Text('Welcome, ${snapshot.data!}', softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 38, color: Color.fromARGB(255, 255, 222, 164), fontWeight: FontWeight.w500),);
                              }
                              else{
                                return Text('Welcome, Alex', style: TextStyle(fontSize: 38, color: Color.fromARGB(255, 255, 222, 164), fontWeight: FontWeight.w500),);
                              }
                            },),
                            SizedBox(height: 5,),
                            FutureBuilder(future: displayLastLogin(), builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return CircularProgressIndicator();
                              }
                              if(snapshot.hasData && snapshot.data != null){
                                String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(snapshot.data!));
                                return Text('Last Login : $formattedDate', style: TextStyle(fontSize: 18, color: Colors.white54, letterSpacing: 1),);
                              }
                              else{
                                return Text('Last Login : 18 Nov 2025', style: TextStyle(fontSize: 18, color: Colors.white54, letterSpacing: 1),);
                              }
                            },)
                          ],
                        ),
                        SizedBox(height: 15,),
                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.431,
                  decoration: BoxDecoration(
                    // color: Colors.blueAccent,
                      color: Color(0xFF594226),
      
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.43,
                  padding: EdgeInsets.only(top: 40, bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: Column(
                        children: [
                          GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8 ), itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTopJoined, child: screens[index] , alignment: Alignment.topCenter, duration: Duration(milliseconds: 980), reverseDuration: Duration(milliseconds: 950), childCurrent: DashboardScreen()));
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF594226),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2), // Shadow color
                                          spreadRadius: 5, // How much the shadow spreads
                                          blurRadius: 6, // How blurred the shadow is
                                          offset: Offset(0, 2), // Shadow position (horizontal, vertical)
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: cateIcons[index],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text(cateName[index], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.6)),)
                              ],
                            );
                          }, itemCount: cateName.length, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),)
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

  Widget _buildDrawerOption({
    required IconData icon,
    required String title,
    required Function() onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      hoverColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

}
