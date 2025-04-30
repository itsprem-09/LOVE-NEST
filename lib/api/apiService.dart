import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:matrimony/db/db.dart';
import 'package:matrimony/utils/constants.dart';

class ApiService {
  String baseUrl = "https://67b41a9e392f4aa94fa95535.mockapi.io/matrimony_user";

  Future<List?> getUsers() async {
    var res = await http.get(Uri.parse(baseUrl));
    print(res.body);
    if (res.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(res.body);
      _parseUserId(jsonData);
      return jsonData;
    }
    return null;
  }

  void _parseUserId(List userList){
    for(var user in userList){
      if(user[MyDatabase.USER_ID] is String){
        user[MyDatabase.USER_ID] = int.parse(user[MyDatabase.USER_ID]);
      }
    }
  }

  Future<void> addUser(
      {required String FName,
      required String LName,
      required String phone,
      required String email,
      required String city,
      required String dob,
      required String gender,
      required String hobbies}) async {

    Map<String, dynamic> map = {};
    map[FNAME] = FName;
    map[LNAME] = LName;
    map[PHONE] = phone;
    map[EMAIL] = email;
    map[CITY] = city;
    map[DOB] = dob;
    map[AGE] = _calculateAge(dob);
    map[GENDER] = gender;
    map[HOBBIES] = hobbies;
    map[ISWISHLIST] = 0;

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(map),
    );
    if (response.statusCode == 201) {
      print('Post successful');
      getUsers();
    } else {
      print('Failed to post');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if(response.statusCode==200){
      print("delete succfully");
    }else{
      print("error :: :");
    }
    getUsers();
    getWishList();
  }

  Future<List?> searchDetail(String searchData) async {
    var res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(res.body);

      List searchResultList = [];

      for (var ele in jsonData) {
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

      return searchResultList;
    }
    return null;
  }

  Future<void> updateUser(String id, Map<String, dynamic> map) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        print('Update successful');
        getUsers();
        getWishList();
      } else {
        print('Failed to update: ${response.reasonPhrase}\n${response.body}');
      }
    } catch (error) {
      print('Error updating data: $error');
    }
  }

  int _calculateAge(String date) {
    DateTime dob = DateTime.parse(date);
    DateTime today = DateTime.now();
    int age = today.year - dob.year;

    // Adjust age if birthday hasn't occurred yet this year
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<List?> applyFilters(
      Map<String, dynamic> filters, String searchQuery) async {
    var res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(res.body);

      var selectedCity = filters[CITY];
      var selectedGender = filters[GENDER];
      var minAge = filters[MINAGE];
      var maxAge = filters[MAXAGE];


      print('${minAge.runtimeType}, ${maxAge.runtimeType}');
      print('min age  : :  : $minAge');

      int? minAgeInt;
      int? maxAgeInt;

      if(minAge.toString().isNotEmpty && maxAge.toString().isNotEmpty){
        minAgeInt = int.parse(minAge);
        maxAgeInt = int.parse(maxAge);
      }

      print('${minAgeInt.runtimeType}, ${maxAgeInt.runtimeType}');

      List filteredUserList = [];

      filteredUserList = jsonData.where((user) {
        final matchesCity = selectedCity.isEmpty || user[CITY] == selectedCity;
        final matchesGender =
            selectedGender.isEmpty || user[GENDER] == selectedGender;

        int userAge = _calculateAge(user[DOB]);

        final matchesAge = (userAge >= minAgeInt!) && (userAge <= maxAgeInt!);

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

      return filteredUserList;
    }
    return null;
  }

  Future<List?> getWishList() async {
    var res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(res.body);

      List wishList = [];
      for (var user in jsonData) {
        if (user[ISWISHLIST] == 1) {
          wishList.add(user);
        }
      }

      return wishList;
    }
    return null;
  }

  Future<List?> searchWishListedUser(String searchData) async {
    List? wishlist = await getWishList();

    List searchResultList = [];

    for (var ele in wishlist!) {
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

    return searchResultList;
  }
}
