import '../utils/constants.dart';

class User {
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

  void addUser(
      {required FName,
      required LName,
      required phone,
      required email,
      required city,
      required dob,
      required gender,
      required hobbies}) {
    Map<String, dynamic> map = {};
    map[FNAME] = FName;
    map[LNAME] = LName;
    map[PHONE] = phone;
    map[EMAIL] = email;
    map[CITY] = city;
    map[DOB] = dob;
    map[AGE] = calculateAge(dob);
    map[GENDER] = gender;
    map[HOBBIES] = hobbies;
    map[ISWISHLIST] = false;
    userList.add(map);
  }

  List<Map<String, dynamic>> getUserList() {
    return userList;
  }

  void updateUser(
      {required FName,
        required LName,
        required phone,
        required email,
        required city,
        required dob,
        required gender,
        required hobbies,
        required isWishList,
        required oldEmail,
        required oldPhone,
        index,}) {
    Map<String, dynamic> map = {};
    map[FNAME] = FName;
    map[LNAME] = LName;
    map[PHONE] = phone;
    map[EMAIL] = email;
    map[CITY] = city;
    map[DOB] = dob;
    map[AGE] = calculateAge(dob);
    map[GENDER] = gender;
    map[HOBBIES] = hobbies;
    map[ISWISHLIST] = isWishList;
    // userList[index] = map;

    void updateUserInList(List<Map<String, dynamic>> list) {
      int index = list.indexWhere((user) => user[EMAIL] == oldEmail && user[PHONE] == oldPhone);
      if (index != -1) {
        list[index] = map;
      }
    }

    // Update user in all lists
    updateUserInList(userList);
    print('USER LIST AFTER UPDATE : :  :    ::: ${userList}');
    updateUserInList(searchResultList);
    updateUserInList(filteredUserList);
    updateUserInList(searchedWishList);
    updateUserInList(wishList);
  }

  void deleteUser({required index}) {
    userList.removeAt(index);
  }

  List<Map<String, dynamic>> getWishList(){
    wishList = [];
    for (var user in userList) {
      if (user[ISWISHLIST]) {
        wishList.add(user);
      }
    }
    return wishList;
  }

  List<Map<String, dynamic>> searchDetail({required searchData}) {
    searchResultList = [];
    for (var ele in userList) {
      if (ele[FNAME]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[LNAME]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[PHONE]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[EMAIL]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[CITY]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase())) {
        searchResultList.add(ele);
      }
    }
    print('search called : ${searchResultList}');
    return searchResultList;
  }

  List<Map<String, dynamic>> searchWishListedUser({required searchData}) {
    searchedWishList = [];
    for (var ele in wishList) {
      if (ele[FNAME]
          .toString()
          .toLowerCase()
          .contains(searchData.toString().toLowerCase()) ||
          ele[LNAME]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[PHONE]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[EMAIL]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase()) ||
          ele[CITY]
              .toString()
              .toLowerCase()
              .contains(searchData.toString().toLowerCase())) {
        searchedWishList.add(ele);
      }
    }
    print('search called : ${searchedWishList}');
    return searchedWishList;
  }

  void deleteUserFromSearchResultList({required String email, required String phone}) {
    // Find the index of the user in the userList
    int? userIndexInUserList = userList.indexWhere((user) =>
    user[EMAIL] == email && user[PHONE] == phone);

    // If the user exists in the userList, proceed to delete
    if (userIndexInUserList != -1) {
      // Delete the user from the userList
      userList.removeAt(userIndexInUserList);

      // Now, find the index in the searchResultList
      int? userIndexInSearchResultList = searchResultList.indexWhere((user) =>
      user[EMAIL] == email && user[PHONE] == phone);

      // If the user is found in searchResultList, remove it
      if (userIndexInSearchResultList != -1) {
        searchResultList.removeAt(userIndexInSearchResultList);
      }
    }
  }

  void deleteUserFromFilteredUserList({required String email, required String phone}) {
    // Find the index of the user in the userList
    int? userIndexInUserList = userList.indexWhere((user) =>
    user[EMAIL] == email && user[PHONE] == phone);

    // If the user exists in the userList, proceed to delete
    if (userIndexInUserList != -1) {
      // Delete the user from the userList
      userList.removeAt(userIndexInUserList);

      // Now, find the index of the user in the filteredUserList
      int? userIndexInFilteredUserList = filteredUserList.indexWhere((user) =>
      user[EMAIL] == email && user[PHONE] == phone);

      // If the user is found in filteredUserList, remove it
      if (userIndexInFilteredUserList != -1) {
        filteredUserList.removeAt(userIndexInFilteredUserList);
      }
    }
  }

  List applyFilters(Map<String, dynamic> filters, String searchQuery) {
    var selectedCity = filters[CITY];
    var selectedGender = filters[GENDER];
    var minAge = filters[MINAGE];
    var maxAge = filters[MAXAGE];

    int? minAgeInt = int.tryParse(minAge);
    int? maxAgeInt = int.tryParse(maxAge);

    filteredUserList = userList.where((user) {
      final matchesCity = selectedCity.isEmpty || user[CITY] == selectedCity;
      final matchesGender =
          selectedGender.isEmpty || user[GENDER] == selectedGender;

      final matchesAge = (minAgeInt == null || user[AGE] >= minAgeInt) &&
          (maxAgeInt == null || user[AGE] <= maxAgeInt);

      final matchesSearch = searchQuery.isEmpty ||
          user[FNAME]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase()) ||
          user[LNAME]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase()) ||
          user[PHONE]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase()) ||
          user[EMAIL]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase()) ||
          user[CITY]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase());

      return matchesCity && matchesGender && matchesAge && matchesSearch;
    }).toList();
    print('filter called backend: ${filteredUserList}');
    return filteredUserList;
  }
}
