import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matrimony/db/db.dart';
import 'package:matrimony/screen/dashboardScreen.dart';
import 'package:matrimony/screen/loginSignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with waves
          Positioned.fill(
            child: CustomPaint(
              painter: BetterWavePainter(),
            ),
          ),
          // Splash content with logo and text
          Center(
            child: AnimatedSplashScreen(
              centered: true,
              animationDuration: Duration(seconds: 3, milliseconds: 520),
              splashIconSize: 400,
              splashTransition: SplashTransition.fadeTransition,
              splash: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: LottieBuilder.asset(
                          'assets/images/SplashScreen.json')),
                  SizedBox(height: 10),
                  Text(
                    'LOVE NEST',
                    style: TextStyle(
                      fontSize: 36,
                      color: Color.fromARGB(255, 255, 222, 164),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor:
                  Colors.transparent, // Keep transparent to see waves
              nextScreen: FutureBuilder(
                future: _checkLoginStatus(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return DashboardScreen();
                  } else {
                    return LoginPage();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }
}

// Improved wave design with gradients
class BetterWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // First wave - soft gradient
    var paint1 = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF594226), Color(0xFF594226).withOpacity(0.9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    var path1 = Path();

    path1.lineTo(0, size.height * 0.75);
    path1.quadraticBezierTo(
        size.width * 0.5, size.height * 1.05, size.width, size.height * 0.75);
    path1.lineTo(size.width, 0);
    path1.close();

    canvas.drawPath(path1, paint1);

    // Second wave - darker gradient for depth
    var paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFF594226).withOpacity(0.2),
          Color.fromARGB(255, 255, 222, 164).withOpacity(0.5)
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    var path2 = Path();

    path2.lineTo(0, size.height * 0.85);
    path2.quadraticBezierTo(
        size.width * 0.5, size.height * 1.10, size.width, size.height * 0.85);
    path2.lineTo(size.width, 0);
    path2.close();

    canvas.drawPath(path2, paint2);

    // Optional: Add a third wave for more depth
    var paint3 = Paint()
      ..color = Color(0xFF594226).withOpacity(0.2); // Soft shadow effect
    var path3 = Path();

    path3.lineTo(0, size.height * 0.65);
    path3.quadraticBezierTo(
        size.width * 0.5, size.height * 0.95, size.width, size.height * 0.65);
    path3.lineTo(size.width, 0);
    path3.close();

    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
