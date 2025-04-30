import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:matrimony/model/loginDetailsDb.dart';
import 'package:matrimony/screen/dashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

LoginDetails login = LoginDetails();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isHovered = false;
  bool isPasswordVisible = false;

  GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  // Future<void> logout() async {
  //   // Sign out from Firebase
  //   await FirebaseAuth.instance.signOut();
  //
  //   // Sign out from Google
  //   await GoogleSignIn().signOut();
  //
  //   // Optionally, you can also call `GoogleSignIn().disconnect()` to disconnect the user completely
  //   // await GoogleSignIn().disconnect();
  //
  //   // Reset login status and user ID
  //   await saveLoginStatus(isLoggedIn: false);
  //   await saveLoggedUserId(id: null);
  //
  //   // Redirect to the login page or show logout success message
  //   Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => LoginPage(),
  //       ));
  // }


  Future<void> _signInWithGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Sign out first to force account selection
    await googleSignIn.signOut();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication? googleAuth =
        await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          // 1. Check if the user exists in your local database
          bool userExistsLocally = await login.checkIfEmailExists(user.email!);

          if (!userExistsLocally) {
            // 2. Add user details to the local database
            Uint8List? profilePictureBytes; // Initialize to null

            if (user.photoURL != null) {
              // Fetch and convert profile picture to Uint8List
              try {
                final response = await http.get(Uri.parse(user.photoURL!)); // Import http package
                if (response.statusCode == 200) {
                  profilePictureBytes = response.bodyBytes as Uint8List?;
                } else {
                  print('Failed to load profile picture');
                }
              } catch (e) {
                print("Error fetching profile picture: $e");
              }
            }

            await login.addUserInTblLogin(
              userName: user.displayName ?? "User", // Provide a default username
              lastLogin: DateTime.now().toString(),
              profilePicture: profilePictureBytes ?? Uint8List(0),  // Provide empty list if null
              password: '', // You might not have a password for Google sign-in.  Consider how you want to handle this.  Perhaps leave it blank or use a placeholder.
              email: user.email!,
            );
          }
          await saveLoginStatus(isLoggedIn: true);
          int loggedUserId = await login.getLoggedInUserId(email: user.email!, password: ''); //Get the login id from local database
          await saveLoggedUserId(id: loggedUserId); // Assuming userId is stored as int
          toastification.show(
            context: context,
            title: Text('Logged in Successfully'),
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            autoCloseDuration: Duration(seconds: 3),
            showProgressBar: true,
            icon: Icon(Icons.check_box, color: Colors.white),
            primaryColor: Colors.green,
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(12),
            closeOnClick: true,
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(),
              ),
          );
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      // Handle error, e.g., show a snackbar
      toastification.show(
        context: context,
        title: Text('Google Sign In Failed!'),
        type: ToastificationType.error,
        icon: const Icon(Icons.error),
        style: ToastificationStyle.minimal,
        showIcon: true, // show or hide the icon
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
        applyBlurEffect: true,
        pauseOnHover: true,
        closeButtonShowType: CloseButtonShowType.onHover,

        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  void checkLogin(String email, String password) async {
    bool isValidUser = await login.validateUser(email: email, pass: password);
    int loggedUserId =
        await login.getLoggedInUserId(email: email, password: password);
    print('loggedUserid : $loggedUserId');

    if (isValidUser) {
      print("Login Successful");

      await saveLoginStatus(isLoggedIn: true);
      await saveLoggedUserId(id: loggedUserId);
      toastification.show(
        context: context,
        title: Text('Logged in Successfully'),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: Duration(seconds: 3),
        showProgressBar: true,
        icon: Icon(Icons.check_box, color: Colors.white),
        primaryColor: Colors.green,
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        closeOnClick: true,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
          ));
      // Navigate to the home screen or dashboard
    } else {
      print("Invalid Email or Password");
      toastification.show(
        context: context,
        title: Text('Incorrect Email or Password!'),
        type: ToastificationType.error,
        icon: const Icon(Icons.error),
        style: ToastificationStyle.minimal,
        showIcon: true, // show or hide the icon
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
        applyBlurEffect: true,
        pauseOnHover: true,
        closeButtonShowType: CloseButtonShowType.onHover,

        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> saveLoginStatus({bool isLoggedIn = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> saveLoggedUserId({int? id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('loggedUserId', id!);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF594226);
    final accentColor = Color.fromARGB(255, 255, 222, 164);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background Circles
            _buildAnimatedCircle(
              context,
              top: -100,
              left: -100,
              size: 250,
              color: accentColor.withOpacity(0.3),
            ),
            _buildAnimatedCircle(context,
                top: 50,
                right: -100,
                size: 200,
                isLeft: false,
                color: primaryColor.withOpacity(0.1)),
            _buildAnimatedCircle(
              context,
              bottom: -100,
              left: -100,
              size: 250,
              color: accentColor.withOpacity(0.3),
            ),
            _buildAnimatedCircle(
              context,
              bottom: -150,
              right: -100,
              size: 200,
              isLeft: false,
              color: primaryColor.withOpacity(0.1),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2),
                      // Logo with ZoomIn Effect
                      FadeInDown(
                        delay: Duration(milliseconds: 300),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: accentColor,
                            backgroundImage:
                                AssetImage('assets/images/logo1.png'),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Welcome Text with FadeInDown Effect
                      FadeInUp(
                        delay: Duration(milliseconds: 600),
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Email Field with FadeInUp Effect
                      FadeInDown(
                        delay: Duration(milliseconds: 900),
                        child: _buildTextField(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          controllerName: email,
                          validatorFunction: (value) {
                            if (value!.isEmpty) {
                              return 'Email Must be not Empty';
                            }
                            return null;
                          },
                          primaryColor: primaryColor,
                          accentColor: accentColor,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Password Field with FadeInUp Effect
                      FadeInDown(
                        delay: Duration(milliseconds: 1050),
                        child: _buildTextField(
                          icon: Icons.lock_outline,
                          label: 'Password',
                          isPassword: true,
                          validatorFunction: (value) {
                            if (value!.isEmpty) {
                              return 'Password must be not Empty';
                            }
                            return null;
                          },
                          controllerName: pass,
                          suffixIconData: isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          primaryColor: primaryColor,
                          accentColor: accentColor,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Login Button with ZoomIn Effect
                      ZoomIn(
                        delay: Duration(milliseconds: 1200),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                checkLogin(email.text, pass.text);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 18),
                          ),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),

                      ZoomIn(
                        delay: Duration(milliseconds: 1400),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _signInWithGoogle();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          icon: Icon(Icons.g_mobiledata, color: Colors.white, size: 35,),
                          label: Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25,),

                      // Sign Up Link with FadeIn Effect
                      FadeIn(
                        delay: Duration(milliseconds: 1500),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHovered = true),
                          onExit: (_) => setState(() => _isHovered = false),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()),
                              );
                            },
                            child: Column(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: 'Don\'t have an account? ',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: _isHovered ? 100 : 0,
                                  height: 2,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle(BuildContext context,
      {double? top,
      double? bottom,
      double? left,
      double? right,
      bool isLeft = true,
      required double size,
      required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: isLeft
          ? SlideInLeft(
              delay: Duration(milliseconds: 100),
              duration: Duration(seconds: 2),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : SlideInRight(
              delay: Duration(milliseconds: 100),
              duration: Duration(seconds: 2),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required TextEditingController controllerName,
    bool isPassword = false,
    required Color primaryColor,
    required Color accentColor,
    var suffixIconData,
    var validatorFunction,
  }) {
    print('IS Password : $isPassword');
    return TextFormField(
      controller: controllerName,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      obscureText: isPassword ? !isPasswordVisible : false,
      validator: validatorFunction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                icon: Icon(
                  suffixIconData,
                  color: primaryColor,
                ),
              )
            : null,
        filled: true,
        fillColor: accentColor.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  XFile? _image;
  dynamic _pickImageError;
  bool _isHovered = false;
  final ImagePicker _picker = ImagePicker();
  bool isPasswordVisible = false;
  bool isConPasswordVisible = false;

  Future<void> _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    if (context.mounted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        setState(() {
          _image = pickedFile;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController conPass = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF594226);
    final accentColor = Color.fromARGB(255, 255, 222, 164);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accentColor.withOpacity(0.1), Colors.white],
            ),
          ),
          child: Stack(
            children: [
              // Animated Background Elements
              Positioned(
                top: -100,
                left: -100,
                child: SlideInLeft(
                  duration: Duration(seconds: 1),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: -100,
                child: SlideInRight(
                  duration: Duration(seconds: 1),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: SlideInLeft(
                  duration: Duration(seconds: 1),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -100,
                child: SlideInRight(
                  duration: Duration(seconds: 1),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, bottom: 24, top: 0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 80),
                        FadeInDown(
                          delay: Duration(milliseconds: 300),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        FadeInUp(
                          delay: Duration(milliseconds: 600),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _onImageButtonPressed(
                                      ImageSource.gallery,
                                      context: context);
                                },
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: accentColor,
                                  backgroundImage: _image != null
                                      ? FileImage(File(_image!.path))
                                      : null,
                                  child: _image == null
                                      ? Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: primaryColor,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        FadeInDown(
                          delay: Duration(milliseconds: 900),
                          child: _buildTextField(
                            icon: Icons.person_outline,
                            label: 'Username',
                            validatorFunction: (value) {
                              if (value.isEmpty) {
                                return 'Username must be not empty';
                              }
                              return null;
                            },
                            controllerName: userName,
                            primaryColor: primaryColor,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeInDown(
                          delay: Duration(milliseconds: 1050),
                          child: _buildTextField(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            controllerName: email,
                            validatorFunction: (value) {
                              if (value!.isEmpty) {
                                return 'Email Must be not Empty';
                              }
                              if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            primaryColor: primaryColor,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeInDown(
                          delay: Duration(milliseconds: 1200),
                          child: _buildTextField(
                            icon: Icons.lock_outline,
                            label: 'Password',
                            isPassword: true,
                            validatorFunction: (value) {
                              if (value.isEmpty) {
                                return 'Password must be not empty';
                              }
                              if (!RegExp(
                                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$')
                                  .hasMatch(value)) {
                                return 'Password must contains atleast 1 lowercase character, 1 uppercase character, 1 special character and 1 digit';
                              }
                              return null;
                            },
                            controllerName: pass,
                            suffixIconData: isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            primaryColor: primaryColor,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeInDown(
                          delay: Duration(milliseconds: 1350),
                          child: _buildTextField(
                            icon: Icons.lock_outline,
                            label: 'Confirm Password',
                            isConPassword: true,
                            validatorFunction: (value) {
                              if (value.isEmpty) {
                                return 'Confirm Password must be not empty';
                              }
                              if (value != conPass.text) {
                                return 'Password and Confirm Password must be Same';
                              }
                              return null;
                            },
                            controllerName: conPass,
                            suffixIconData: isConPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            primaryColor: primaryColor,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        ZoomIn(
                          delay: Duration(milliseconds: 1500),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_image == null) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _showErrorDialog(
                                          context,
                                          "Please add a profile picture to continue."));
                                } else {
                                  bool usernameExists = await login
                                      .checkIfUsernameExists(userName.text);
                                  print('Username Exist  : $usernameExists');
                                  bool emailExists = await login
                                      .checkIfEmailExists(email.text);
                                  print('Email  Exist : $emailExists');

                                  if (usernameExists) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _showErrorDialog(
                                        context,
                                        "The username is already taken. Please choose a different one.",
                                      ),
                                    );
                                  } else if (emailExists) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _showErrorDialog(
                                        context,
                                        "The email is already registered. Please use a different email.",
                                      ),
                                    );
                                  } else {
                                    File imageFile = File(_image!.path);
                                    var img = await imageFile.readAsBytes();

                                    setState(() {
                                      login.addUserInTblLogin(
                                          userName: userName.text,
                                          lastLogin: DateTime.now().toString(),
                                          profilePicture: img,
                                          password: pass.text,
                                          email: email.text);
                                    });
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: primaryColor.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 18),
                            ),
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeIn(
                          delay: Duration(milliseconds: 1500),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _isHovered = true),
                            onExit: (_) => setState(() => _isHovered = false),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              child: Column(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Login',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: _isHovered ? 100 : 0,
                                    height: 2,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showErrorDialog(BuildContext context, String message) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.red.shade100, width: 2),
        ),
        backgroundColor: Colors.red[50],
        elevation: 10,
        title: Center(
          child: ElasticIn(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 600),
            child: Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red[800],
            ),
          ),
        ),
        content: FadeIn(
          delay: const Duration(milliseconds: 300),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FadeOut(
            delay: const Duration(milliseconds: 500),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                elevation: 5,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required controllerName,
    bool isPassword = false,
    bool isConPassword = false,
    required Color primaryColor,
    required Color accentColor,
    var suffixIconData,
    var validatorFunction,
  }) {
    print('IS Password : $isPassword');
    return TextFormField(
      controller: controllerName,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : isConPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
      obscureText: isPassword
          ? !isPasswordVisible
          : isConPassword
              ? !isConPasswordVisible
              : false,
      validator: validatorFunction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isPassword
                  ? isPasswordVisible = !isPasswordVisible
                  : isConPasswordVisible = !isConPasswordVisible;
            });
          },
          icon: Icon(suffixIconData, color: primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
