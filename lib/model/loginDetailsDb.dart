import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/constants.dart';
import '../db/db.dart';

class LoginDetails {
  static List<Map<String, dynamic>> userDataList = [];

  Database db = MyDatabase.db!;

  Future<void> addUserInTblLogin(
      {required userName,
      required lastLogin,
      required Uint8List profilePicture,
      required password, required email}) async {
    Map<String, dynamic> map = {};
    map[MyDatabase.USERNAME] = userName;
    map[MyDatabase.LAST_LOGIN] = lastLogin;
    map[MyDatabase.PROFILE_PICTURE] = profilePicture;
    map[MyDatabase.PASSWORD] = password;
    map[MyDatabase.LOGIN_EMAIL] = email;

    db = await MyDatabase().initDatabase();
    int num = await db.insert(MyDatabase.TBL_LOGIN, map);
    await getUserDataList();
    print(num);
  }

  Future<List<Map<String, dynamic>>> getUserDataList() async {
    db = await MyDatabase().initDatabase();
    userDataList = [];
    userDataList
        .addAll(await db.rawQuery('SELECT * FROM ${MyDatabase.TBL_LOGIN}'));
    return userDataList;
  }

  Future<Map<String, dynamic>?> getLoggedInUserByLoginId(int loginId) async {
    db = await MyDatabase().initDatabase();

    // Query the database to get user details by LoginId
    var result = await db.query(
      MyDatabase.TBL_LOGIN,
      where: '${MyDatabase.LOGIN_ID} = ?',
      whereArgs: [loginId],
    );

    // Check if the result is not empty, meaning user exists
    if (result.isNotEmpty) {
      return result.first; // Return the first result as a map of user data
    } else {
      return null; // Return null if no match found
    }
  }

  Future<String> getUsernameByLoginId(int loginId) async {
    db = await MyDatabase().initDatabase();
    var result = await db.query(
      MyDatabase.TBL_LOGIN,
      columns: [MyDatabase.USERNAME],
      where: '${MyDatabase.LOGIN_ID} = ?',
      whereArgs: [loginId],
    );

    if (result.isNotEmpty) {
      return result.first[MyDatabase.USERNAME] as String;
    }
    return 'Unknown User';
  }

  Future<void> updateLastLogin(int id) async {
    db = await MyDatabase().initDatabase();
    String currentDate = DateTime.now().toString(); // Get current date

    await db.update(
      MyDatabase.TBL_LOGIN,
      {MyDatabase.LAST_LOGIN: currentDate}, // Update with current date
      where: '${MyDatabase.LOGIN_ID} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> validateUser({required email, required pass}) async {
    db = await MyDatabase().initDatabase();

    var data = await db.query(
      MyDatabase.TBL_LOGIN,
      where: '${MyDatabase.LOGIN_EMAIL} = ? AND ${MyDatabase.PASSWORD} = ?',
      whereArgs: [email, pass],
    );

    if (data.isNotEmpty) {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // int id = prefs.getInt('loggedUserId')!;
      // await updateLastLogin(id);
      return true;
    }

    return false;

  }

  Future<void> updateLastLoginOnAppStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      int id = prefs.getInt('loggedUserId')!;
      print('id : $id');

      await updateLastLogin(id);
    }
  }

  Future<int> getLoggedInUserId({required String email, required String password}) async {
    db = await MyDatabase().initDatabase();

    // Query the database for the email and password
    var result = await db.query(
      MyDatabase.TBL_LOGIN,
      columns: [MyDatabase.LOGIN_ID], // We only need the LoginId column
      where: '${MyDatabase.LOGIN_EMAIL} = ? AND ${MyDatabase.PASSWORD} = ?',
      whereArgs: [email, password],
    );

    // Check if the result is not empty, meaning user exists
    if (result.isNotEmpty) {
      return result.first[MyDatabase.LOGIN_ID] as int; // Return the LoginId
    } else {
      return -1; // Return -1 if no match found
    }
  }

  Future<bool> checkIfEmailExists(String email) async {
    db = await MyDatabase().initDatabase();
    var result = await db.query(
      MyDatabase.TBL_LOGIN,
      where: '${MyDatabase.LOGIN_EMAIL} = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<bool> checkIfUsernameExists(String username) async {
    db = await MyDatabase().initDatabase();
    var result = await db.query(
      MyDatabase.TBL_LOGIN,
      where: '${MyDatabase.USERNAME} = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

}
