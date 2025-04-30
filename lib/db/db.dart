import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  static const String TBL_USER = 'Tbl_User';
  static const String USER_ID = 'UserID';
  static const String FNAME = 'FName';
  static const String LNAME = 'LName';
  static const String EMAIL = 'Email';
  static const String PHONE = 'Phone';
  static const String DOB = 'DOB';
  static const String AGE = 'Age';
  static const String CITY = 'City';
  static const String GENDER = 'Gender';
  static const String HOBBIES = 'Hobbies';
  static const String ISWISHLIST = 'isWishlist';

  static const String TBL_LOGIN = 'Tbl_Login';
  static const String LOGIN_ID = 'LoginId';
  static const String USERNAME = 'username';
  static const String LAST_LOGIN = 'lastLogin';
  static const String PROFILE_PICTURE = 'profilePicture';
  static const String PASSWORD = 'password';
  static const String LOGIN_EMAIL = 'Email';

  static const String TBL_NOTIFICATION = 'Tbl_Notification';
  static const String NOTIFICATION_ID = 'NotificationId';
  static const String MSG = 'Msg';
  static const String RECEIVED_TIME = 'ReceivedTime';

  int DB_VERSION = 3;

  static Database? db;

  Future<Database> initDatabase() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'matrimony.db'),
      onCreate: (db, version) {
        // Create the original table
        db.execute(
            'CREATE TABLE $TBL_USER($USER_ID INTEGER PRIMARY KEY AUTOINCREMENT, $FNAME TEXT, $LNAME TEXT, $EMAIL TEXT, $PHONE TEXT , $AGE INTEGER, $CITY TEXT, $GENDER TEXT, $ISWISHLIST INTEGER NOT NULL, $DOB TEXT, $HOBBIES TEXT)'
        );
        // Create the new Tbl_Login table
        db.execute(
            'CREATE TABLE $TBL_LOGIN($LOGIN_ID INTEGER PRIMARY KEY AUTOINCREMENT, $USERNAME TEXT, $LAST_LOGIN TEXT, $PROFILE_PICTURE BLOB, $PASSWORD TEXT, $LOGIN_EMAIL TEXT)'
        );
        db.execute(
            'CREATE TABLE $TBL_NOTIFICATION($NOTIFICATION_ID INTEGER PRIMARY KEY AUTOINCREMENT, $LOGIN_ID INTEGER, $USER_ID INTEGER, $MSG TEXT, '
                'FOREIGN KEY($LOGIN_ID) REFERENCES $TBL_LOGIN($LOGIN_ID), '
                'FOREIGN KEY($USER_ID) REFERENCES $TBL_USER($USER_ID))'
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if(newVersion < 4){
          db.execute(
              'ALTER TABLE $TBL_NOTIFICATION ADD COLUMN $RECEIVED_TIME TEXT'
          );
        }
        if(newVersion < 3){
          db.execute(
              'CREATE TABLE $TBL_NOTIFICATION($NOTIFICATION_ID INTEGER PRIMARY KEY AUTOINCREMENT, $LOGIN_ID INTEGER, $USER_ID INTEGER, $MSG TEXT, '
                  'FOREIGN KEY($LOGIN_ID) REFERENCES $TBL_LOGIN($LOGIN_ID), '
                  'FOREIGN KEY($USER_ID) REFERENCES $TBL_USER($USER_ID))'
          );
        }
      },
      version: DB_VERSION,
    );
    return db!;
  }
}
