import 'package:sqflite/sqflite.dart';
import '../utils/constants.dart';
import '../db/db.dart';

class UserDb {
  static List<Map<String, dynamic>> userList = [];
  static List<Map<String, dynamic>> searchResultList = [];
  static List<Map<String, dynamic>> filteredUserList = [];
  static List<Map<String, dynamic>> searchedWishList = [];
  static List<Map<String, dynamic>> wishList = [];

  int calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;

    // Adjust age if birthday hasn't occurred yet this year
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Database db = MyDatabase.db!;

  Future<void> addUserInTblUser(
      {required String FName,
      required String LName,
      required String phone,
      required String email,
      required String city,
      required String dob,
      required String gender,
      required String hobbies}) async {
    Map<String, dynamic> map = {};
    map[MyDatabase.FNAME] = FName;
    map[MyDatabase.LNAME] = LName;
    map[MyDatabase.PHONE] = phone;
    map[MyDatabase.EMAIL] = email;
    map[MyDatabase.CITY] = city;
    map[MyDatabase.DOB] = dob;
    map[MyDatabase.AGE] = calculateAge(DateTime.parse(dob));
    map[MyDatabase.GENDER] = gender;
    map[MyDatabase.HOBBIES] = hobbies;
    map[MyDatabase.ISWISHLIST] = 0;

    db = await MyDatabase().initDatabase();
    int num = await db.insert(MyDatabase.TBL_USER, map);
    await getUserList();
    print(num);
  }

  Future<List<Map<String, dynamic>>> getUserList() async {
    db = await MyDatabase().initDatabase();
    userList = [];
    userList.addAll(await db.rawQuery('SELECT * FROM ${MyDatabase.TBL_USER}'));
    return userList;
  }

  Future<void> updateUserInTblUser(
      {required FName,
        required LName,
        required phone,
        required email,
        required city,
        required dob,
        required gender,
        required hobbies,
        required isWishList,
        required id,}) async {
    Map<String, dynamic> map = {};
    map[FNAME] = FName;
    map[LNAME] = LName;
    map[PHONE] = phone;
    map[EMAIL] = email;
    map[CITY] = city;
    map[DOB] = dob;
    map[AGE] = calculateAge(DateTime.parse(dob));
    map[GENDER] = gender;
    print('hobbies - ${hobbies.runtimeType}');
    map[HOBBIES] = hobbies;
    print(isWishList);
    map[ISWISHLIST] = isWishList;
    // userList[index] = map;

    print('------------------------------- Update');

    db = await MyDatabase().initDatabase();

    db.update(MyDatabase.TBL_USER, map, where: '${MyDatabase.USER_ID} = ?', whereArgs: [id]);

    // Update user in all lists
    await getUserList();
    await getWishList();
  }

  Future<List<Map<String, dynamic>>> getWishList() async {
    db = await MyDatabase().initDatabase();
    wishList = [];
    wishList.addAll(await db.rawQuery('SELECT * FROM ${MyDatabase.TBL_USER} WHERE ${MyDatabase.ISWISHLIST} = 1'));
    return wishList;
  }

  Future<void> deleteUserFromTblUser({required id}) async {
    db = await MyDatabase().initDatabase();
    await db.delete(MyDatabase.TBL_USER,
        where: '${MyDatabase.USER_ID} = ?', whereArgs: [id]);
    await getUserList();
  }

  Future<List<Map<String, dynamic>>> searchDetail({required searchData}) async {
    db = await MyDatabase().initDatabase();
    searchResultList = [];
    var query =
        "SELECT * FROM ${MyDatabase.TBL_USER} WHERE LOWER(${MyDatabase.FNAME}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.LNAME}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.PHONE}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.EMAIL}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.CITY}) LIKE LOWER('%$searchData%')";
    searchResultList.addAll(await db.rawQuery(query));
    print('search called : ${searchResultList}');
    return searchResultList;
  }

  Future<void> deleteUserFromSearchResultList({required int id}) async {
    await deleteUserFromTblUser(id: id);

    // Find the index of the user in the userList
    int? userIndexInUserList =
        userList.indexWhere((user) => user[MyDatabase.USER_ID] == id);

    // If the user exists in the userList, proceed to delete
    if (userIndexInUserList != -1) {
      // Delete the user from the userList
      userList.removeAt(userIndexInUserList);

      // Now, find the index in the searchResultList
      int? userIndexInSearchResultList =
          searchResultList.indexWhere((user) => user[MyDatabase.USER_ID] == id);

      // If the user is found in searchResultList, remove it
      if (userIndexInSearchResultList != -1) {
        searchResultList.removeAt(userIndexInSearchResultList);
      }
    }
  }

  Future<void> updateUserToWishList({required user}) async{
    db = await MyDatabase().initDatabase();
    int cnt;
    if(user[ISWISHLIST] == 1){
      cnt = 0;
    }
    else{
      cnt = 1;
    }
    db.update(MyDatabase.TBL_USER, {'${MyDatabase.ISWISHLIST}' : '$cnt'}, where: '${MyDatabase.USER_ID} = ?', whereArgs: [user[MyDatabase.USER_ID]]);
    await getUserList();
  }

  Future<List<Map<String, dynamic>>> searchWishListedUser({required searchData}) async {
    db = await MyDatabase().initDatabase();
    searchedWishList = [];
    var query =
        "SELECT * FROM ${MyDatabase.TBL_USER} WHERE ${MyDatabase.ISWISHLIST} = 1 AND (LOWER(${MyDatabase.FNAME}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.LNAME}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.PHONE}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.EMAIL}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.CITY}) LIKE LOWER('%$searchData%'))";
    searchedWishList.addAll(await db.rawQuery(query));
    print('search called : ${searchedWishList}');
    return searchedWishList;
  }

  Future<List> applyFilters(Map<String, dynamic> filters, String searchData) async {
    db = await MyDatabase().initDatabase();

    var selectedCity = filters[CITY];
    var selectedGender = filters[GENDER];
    var minAge = filters[MINAGE];
    var maxAge = filters[MAXAGE];

    int? minAgeInt = int.tryParse(minAge);
    int? maxAgeInt = int.tryParse(maxAge);

    filteredUserList = [];

    String query = 'SELECT * FROM ${MyDatabase.TBL_USER} WHERE 1 = 1';

    if (selectedCity != null && selectedCity.isNotEmpty) {
      query += " AND (COALESCE('$selectedCity', '') = '' OR ${MyDatabase.CITY} = '$selectedCity')";
    }
    if (selectedGender != null && selectedGender.isNotEmpty) {
      query += " AND (COALESCE('$selectedGender', '') = '' OR ${MyDatabase.GENDER} = '$selectedGender')";
    }
    if (minAgeInt != null && minAge.isNotEmpty) {
      query += " AND (COALESCE($minAgeInt, NULL) IS NULL OR ${MyDatabase.AGE} >= $minAgeInt)";
    }
    if (maxAgeInt != null && maxAge.isNotEmpty) {
      query += " AND (COALESCE($maxAgeInt, NULL) IS NULL OR ${MyDatabase.AGE} <= $maxAgeInt)";
    }

    // Handle search text
    if (searchData.isNotEmpty) {
      query += " AND (LOWER(${MyDatabase.FNAME}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.LNAME}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.PHONE}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.EMAIL}) LIKE LOWER('%$searchData%') OR LOWER(${MyDatabase.CITY}) LIKE LOWER('%$searchData%'))";
    }

    filteredUserList.addAll(await db.rawQuery(query));
    await getUserList();
    print('filter called backend: ${filteredUserList}');
    return filteredUserList;
  }
}
