import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:matrimony/db/db.dart';
import 'package:matrimony/firebase_options.dart';
import 'package:matrimony/screen/aboutUs.dart';
import 'package:matrimony/screen/addUserFormScreen.dart';
import 'package:matrimony/screen/dashboardScreen.dart';
import 'package:matrimony/screen/loginSignUp.dart';
import 'package:matrimony/screen/wishlist.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart';

import 'screen/splashScreen.dart';
import 'screen/view_users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Makes the status bar transparent
    statusBarIconBrightness: Brightness.dark, // For dark icons, use Brightness.light for white icons
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'Matrimony',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            // iconButtonTheme: IconButtonThemeData(
            //     style: ButtonStyle(
            //   iconColor:
            //       WidgetStatePropertyAll(Color.fromARGB(255, 255, 222, 164)),
            // ),
            // ),
            appBarTheme: AppBarTheme(
                iconTheme:
                    IconThemeData(color: Color.fromARGB(255, 255, 222, 164)))),
        home: FutureBuilder(
          future: MyDatabase().initDatabase(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasData && snapshot.data != null) {
              return SplashScreen();
            } else {
              return Center(child: Text('Some Error While Connecting to Database!'),);
            }
          },
        ),
      ),
    );
  }
}
