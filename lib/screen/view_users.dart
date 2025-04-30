import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:matrimony/api/apiService.dart';
import 'package:matrimony/db/db.dart';
import 'package:matrimony/model/userDb.dart';
import 'package:matrimony/screen/aboutUs.dart';
import 'package:matrimony/screen/addUserFormScreen.dart';
import 'package:matrimony/screen/dashboardScreen.dart';
import 'package:matrimony/screen/userDetails.dart';
import 'package:matrimony/screen/wishlist.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:toastification/toastification.dart';
import '../model/user.dart';
import '../utils/constants.dart';

ApiService api = ApiService();

class ViewUsers extends StatefulWidget {
  var userObject;

  ViewUsers({
    super.key,
    this.userObject,
  });

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  TextEditingController searchDetails = TextEditingController();

  bool isFilterCalled = false;

  String filteredCity = '';
  String filteredGender = '';
  String filteredMinAge = '';
  String filteredMaxAge = '';

  Color darkBrown = Color(0xFF594226);
  Color goldenAmber = Color.fromARGB(255, 255, 222, 164);

  List userList = [];
  List searchResult = [];
  List filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    // fetchUserList();
    // fetchSearchList();
    // fetchFilterList();
    fetchUserListWithApi();
    fetchSearchListWithApi();
    // fetchFilterListWithApi();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchUserList() async {
    List temp = await widget.userObject.getUserList();
    print(temp);
    setState(() {
      userList = temp;
      _sortUsers(selectedSort);
    });
  }

  Future<void> fetchUserListWithApi() async {
    List? temp = await api.getUsers();
    setState(() {
      userList = temp!;
      _sortUsers(selectedSort);
    });
  }

  Future<void> fetchSearchList() async {
    List temp =
        await widget.userObject.searchDetail(searchData: searchDetails.text);
    setState(() {
      searchResult = temp;
    });
  }

  Future<void> fetchSearchListWithApi() async {
    List? temp = await api.searchDetail(searchDetails.text);

    setState(() {
      searchResult = temp!;
      _sortUsers(selectedSort);
    });
  }


  Future<void> fetchFilterList() async {
    List temp = await widget.userObject.applyFilters({
      CITY: filteredCity,
      GENDER: filteredGender,
      MINAGE: filteredMinAge,
      MAXAGE: filteredMaxAge
    }, searchDetails.text);
    setState(() {
      filteredUsers = temp;
      _sortUsers(selectedSort);
    });
  }

  Future<void> fetchFilterListWithApi() async {
    List? temp = await api.applyFilters({
      CITY: filteredCity,
      GENDER: filteredGender,
      MINAGE: filteredMinAge,
      MAXAGE: filteredMaxAge
    }, searchDetails.text);

    setState(() {
      filteredUsers = temp!;
      _sortUsers(selectedSort);
    });
  }

  String selectedSort = 'UserIDDesc';

  void _sortUsers(String sortBy) {
    print('-=-==-=-==-=-=-=---=-=-= $sortBy -==-=-=-=-=-=--=');
    setState(() {
      if (sortBy == "Name") {
        userList.sort((a, b) {
          String nameA = (a[FNAME] + " " + a[LNAME]).toLowerCase();
          String nameB = (b[FNAME] + " " + b[LNAME]).toLowerCase();
          return nameA.compareTo(nameB); // Ascending order (A-Z)
        });
      } else if (sortBy == "NameDesc") {
        userList.sort((a, b) {
          String nameA = (a[FNAME] + " " + a[LNAME]).toLowerCase();
          String nameB = (b[FNAME] + " " + b[LNAME]).toLowerCase();
          return nameB.compareTo(nameA); // Descending order (Z-A)
        });
      }

      else if (sortBy == "Age") {
        userList.sort((a, b) => a[AGE].compareTo(b[AGE]));
      } else if (sortBy == "Age desc") {
        userList.sort((a, b) => b[AGE].compareTo(a[AGE]));
      }

      else if (sortBy == "City") {
        userList.sort((a, b) {
          String cityA = a[CITY].toLowerCase();
          String cityB = b[CITY].toLowerCase();
          return cityA.compareTo(cityB); // Ascending order (A-Z)
        });
      } else if (sortBy == "CityDesc") {
        userList.sort((a, b) {
          String cityA = a[CITY].toLowerCase();
          String cityB = b[CITY].toLowerCase();
          return cityB.compareTo(cityA); // Descending order (Z-A)
        });
      }

      else if(sortBy == 'UserIDDesc'){
        userList.sort((a, b) => b[MyDatabase.USER_ID].compareTo(a[MyDatabase.USER_ID]));
      }

      // Sort filteredUsers if a filter is applied
      if (isFilterCalled) {
        if (sortBy == "Name") {
          filteredUsers.sort((a, b) {
            String nameA = (a[FNAME] + " " + a[LNAME]).toLowerCase();
            String nameB = (b[FNAME] + " " + b[LNAME]).toLowerCase();
            return nameA.compareTo(nameB); // Ascending order (A-Z)
          });
        } else if (sortBy == "NameDesc") {
          filteredUsers.sort((a, b) {
            String nameA = (a[FNAME] + " " + a[LNAME]).toLowerCase();
            String nameB = (b[FNAME] + " " + b[LNAME]).toLowerCase();
            return nameB.compareTo(nameA); // Descending order (Z-A)
          });
        }

        else if (sortBy == "Age") {
          filteredUsers.sort((a, b) => a[AGE].compareTo(b[AGE]));
        } else if (sortBy == "AgeDesc") {
          filteredUsers.sort((a, b) => b[AGE].compareTo(a[AGE]));
        }

        else if (sortBy == "City") {
          filteredUsers.sort((a, b) {
            String cityA = a[CITY].toLowerCase();
            String cityB = b[CITY].toLowerCase();
            return cityA.compareTo(cityB); // Ascending order (A-Z)
          });
        } else if (sortBy == "CityDesc") {
          filteredUsers.sort((a, b) {
            String cityA = a[CITY].toLowerCase();
            String cityB = b[CITY].toLowerCase();
            return cityB.compareTo(cityA); // Descending order (Z-A)
          });
        }

        else if(sortBy == 'UserIDDesc'){

          filteredUsers.sort((a, b) => b[MyDatabase.USER_ID].toString().compareTo(a[MyDatabase.USER_ID].toString()));
        }

      }
    });
  }

  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    List pages = [
      Wishlist(
        userObject: widget.userObject,
      ),
      AddUserFormScreen(
        userObject: widget.userObject,
      ),
      DashboardScreen(
        userObject: widget.userObject,
      ),
      ViewUsers(
        userObject: widget.userObject,
      ),
      AboutUs(
        userObject: widget.userObject,
      )
    ];

    void _showFilterModal() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Color(0xFF594226),
        builder: (BuildContext context) {
          print('Filter called : $isFilterCalled');
          return FilterWidget(
            onFilter: (filters) {
              setState(() {

                isLoading = true;

                // Update the filter state so that the previously selected filters are retained
                filteredCity = filters[CITY] ?? '';
                filteredGender = filters[GENDER] ?? '';
                filteredMinAge = filters[MINAGE] ?? '';
                filteredMaxAge = filters[MAXAGE] ?? '';
                // fetchUserList();
                // fetchFilterList();

                fetchUserListWithApi().then((_) {
                  fetchFilterListWithApi().then((_) {
                    setState(() {
                      // Hide loading indicator after fetching
                      isLoading = false;
                    });
                  });
                });

              });
              Navigator.pop(context);
            },
            onClear: () {
              setState(() {
                // Reset filter state and show full user list
                filteredCity = '';
                filteredGender = '';
                filteredMinAge = '';
                filteredMaxAge = '';
                isFilterCalled = false; // Reset filter state
                UserDb.filteredUserList.clear(); // Clear the filtered list
                filteredUsers.clear();
                isFilterCalled = false;
              });
            },
            selectedCity: filteredCity,
            selectedGender: filteredGender,
            minAge: filteredMinAge,
            maxAge: filteredMaxAge,
          );
        },
      );
    }


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(192.0), // Height of the AppBar
        child: AppBar(
          leadingWidth: 30,
          actions: [
            // Add sorting icon with options
            PopupMenuButton<String>(
              onSelected: (String sortBy) {
                setState(() {
                  // Ensure this is wrapped in setState
                  selectedSort = sortBy;
                  print('Sort by : $sortBy');
                });
                _sortUsers(sortBy);
              },
              icon: Icon(
                Icons.sort_by_alpha_sharp,
                size: 32,
                color: goldenAmber,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              color: darkBrown,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                // Name Section
                _buildSectionHeader('Name'),
                _buildMenuItem(
                  value: "Name",
                  icon: Icons.arrow_upward,
                  label: 'Ascending (A-Z)',
                  isSelected: selectedSort == "Name",
                ),
                _buildMenuItem(
                  value: "NameDesc",
                  icon: Icons.arrow_downward,
                  label: 'Descending (Z-A)',
                  isSelected: selectedSort == "NameDesc",
                ),
                const PopupMenuDivider(height: 16),
                // Age Section
                _buildSectionHeader('Age'),
                _buildMenuItem(
                  value: "Age",
                  icon: Icons.arrow_upward,
                  label: 'Youngest First',
                  isSelected: selectedSort == "Age",
                ),
                _buildMenuItem(
                  value: "AgeDesc",
                  icon: Icons.arrow_downward,
                  label: 'Oldest First',
                  isSelected: selectedSort == "AgeDesc",
                ),
                const PopupMenuDivider(
                  height: 16,
                ),

                // City Section
                _buildSectionHeader('City'),
                _buildMenuItem(
                  value: "City",
                  icon: Icons.arrow_upward,
                  label: 'A-Z Order',
                  isSelected: selectedSort == "City",
                ),
                _buildMenuItem(
                  value: "CityDesc",
                  icon: Icons.arrow_downward,
                  label: 'Z-A Order',
                  isSelected: selectedSort == "CityDesc",
                ),
              ],
            ),
          ],
          iconTheme: IconThemeData(
              color: Color.fromARGB(255, 255, 222, 164), size: 28),
          flexibleSpace: Stack(
            children: [
              ClipPath(
                clipper: WaveClipper1(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF594226), // Larger wave color
                  ),
                  height: 230,
                ),
              ),
              ClipPath(
                clipper: WaveClipper2(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF5A442E), // Smaller wave color
                  ),
                  height: 210,
                ),
              ),
              Positioned(
                top: 100, // Adjust the position of the search bar
                left: 20,
                right: 20,
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 49,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: searchDetails,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          // widget.userObject.searchDetail(searchData: value);
                        });
                        // fetchSearchList();
                        fetchSearchListWithApi();
                        fetchFilterList();
                      }
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Here',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 20,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 25,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          size: 25,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          isFilterCalled = true;
                          _showFilterModal();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'User List',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 222, 164),
                fontSize: 26,
              ),
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0),
          // AppBar background transparent
          elevation: 0, // No shadow
        ),
      ),
      body: FutureBuilder(
        // future: widget.userObject.getUserList(),
        future: api.getUsers(),
        builder: (context, snapshot) {


          if(snapshot.connectionState == ConnectionState.waiting || isLoading){
          return Center(child: CircularProgressIndicator(
            color: Color(0xFF594226),
          ),);
          }

          else if (snapshot.hasData && snapshot.data != null) {
            return userList.isEmpty ||
                    (searchDetails.text != '' && searchResult.isEmpty) ||
                    (isFilterCalled && filteredUsers.isEmpty)
                ? Center(
                    child: FadeInUp(
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Users Found!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return FadeInUp(
                                delay: Duration(milliseconds: index * 100),
                                duration: Duration(milliseconds: 500),
                                child: isFilterCalled
                                    ? userComponent(
                                        user: filteredUsers[index],
                                        i: index,
                                        isFilter: true)
                                    : (searchDetails.text.isNotEmpty &&
                                            searchResult.isNotEmpty)
                                        ? userComponent(
                                            user: searchResult[index],
                                            i: index,
                                            isSearch: true)
                                        : userComponent(
                                            user: userList[index], i: index),
                              );
                            },
                            itemCount: isFilterCalled
                                ? filteredUsers.length
                                : searchDetails.text.isEmpty
                                    ? userList.length
                                    : searchResult.length,
                          ),
                        ),
                      ],
                    ),
                  );
          }

          else {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF594226),
              ),
            );
          }
        },
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    print('Is selected for $value is $isSelected');
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? goldenAmber.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? goldenAmber : goldenAmber.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color:
                        isSelected ? goldenAmber : goldenAmber.withOpacity(0.9),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15),
              ),
            ),
            isSelected
                ? Icon(Icons.check_rounded, color: goldenAmber, size: 18)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildSectionHeader(String title) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 40,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            color: goldenAmber,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget userComponent({
    required user,
    required int i,
    bool isSearch = false,
    bool isFilter = false,
  }) {

    print('User name : ${user[FNAME]}  -->  ${user[MyDatabase.USER_ID]}  ${user[MyDatabase.USER_ID].runtimeType}');

    int calculateAge(String date) {

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

    return InkWell(
      onTap: ()  {
            Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfilePage(
                    userId: user[MyDatabase.USER_ID],
                    gender: user[GENDER],
                    city: user[CITY],
                    dob: user[DOB],
                    phone: user[PHONE],
                    email: user[EMAIL],
                    // age: user[AGE],
                    age: calculateAge(user[DOB]),
                    firstName: user[FNAME],
                    isWishlisted: user[ISWISHLIST],
                    lastName: user[LNAME]),
            ),
        ).then((value) {
          setState(() {
            fetchUserListWithApi();
          });
        },);


        // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(),));
      },
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Color(0xFF594226).withOpacity(0.15),
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Shadow color
                          spreadRadius: 1, // How much the shadow spreads
                          blurRadius: 5, // How blurred the shadow is
                          offset: Offset(0, 2), // Shadow position (horizontal, vertical)
                        ),
                      ],

                    ),
                    child: CircleAvatar(
                      child: Text(
                        '${user[FNAME].toString().toUpperCase()[0]}',
                        style: TextStyle(
                            fontSize: 37,
                            color: Color.fromARGB(255, 255, 222, 164)),
                      ),
                      backgroundColor: Color(0xFF594226),
                    )),
                SizedBox(width: 16),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Wishlist
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${user[FNAME]} ${user[LNAME]}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF594226),
                                height: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // widget.userObject
                                //     .updateUserToWishList(user: user);
                                int isWishlist = user[ISWISHLIST];
                                if(isWishlist == 0){
                                  isWishlist = 1;
                                }
                                else{
                                  isWishlist = 0;
                                }
                                api.updateUser(user[MyDatabase.USER_ID].toString(), {ISWISHLIST : isWishlist});
                              });
                              setState(() {

                              });
                              // fetchUserList();
                              // fetchSearchList();
                              // fetchFilterList();

                              fetchUserListWithApi();
                              fetchSearchListWithApi();
                              fetchFilterListWithApi();
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: user[ISWISHLIST] == 1
                                    ? Colors.red.shade50
                                    : Colors.grey.shade50,
                              ),
                              child: Icon(
                                user[ISWISHLIST] == 1
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: user[ISWISHLIST] == 1
                                    ? Colors.red
                                    : Colors.grey.shade400,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Gender Tag
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFF594226).withOpacity(0.08),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user[GENDER].toLowerCase() == 'male'
                                  ? Icons.male_rounded
                                  : Icons.female_rounded,
                              size: 18,
                              color: Color(0xFF594226),
                            ),
                            SizedBox(width: 4),
                            Text(
                              user[GENDER],
                              style: TextStyle(
                                color: Color(0xFF594226),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Location and Age
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: Color(0xFF594226).withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: Text(
                              user[CITY],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF594226).withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: Color(0xFF594226).withOpacity(0.4),
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${calculateAge(user[DOB])} years',
                              // '${user[AGE]} years',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF594226).withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Divider
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Container(
                height: 1,
                color: Color(0xFF594226).withOpacity(0.08),
              ),
            ),
            // Contact Info and Actions
            Row(
              children: [
                // Phone Number
                Expanded(
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        color: Color(0xFF4CAF50),
                        label: 'Edit',
                        onTap: () async {
                          await showDialog(
                            context: context,

                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return EditUser(
                                    fName: user[FNAME],
                                    lName: user[LNAME],
                                    email: user[EMAIL],
                                    phone: user[PHONE],
                                    dob: user[DOB].toString(),
                                    hobbies: user[HOBBIES],
                                    city: user[CITY],
                                    gender: user[GENDER],
                                    userObject: widget.userObject,
                                    isWishList: user[ISWISHLIST],
                                    id: user[MyDatabase.USER_ID],
                                  );
                                },
                              );
                            },
                          );
                          setState(() {
                            // fetchUserList();
                            // fetchSearchList();
                            // fetchFilterList();


                          });
                          fetchUserListWithApi();
                          fetchSearchListWithApi();
                          // fetchFilterListWithApi();
                        },
                      ),
                      SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.delete_rounded,
                        color: Colors.red,
                        label: 'Delete',
                        onTap: () {
                          _showDeleteConfirmation(user, isFilter, isSearch);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(user, bool isFilter, bool isSearch) {
    PanaraConfirmDialog.show(
      context,
      title: "Delete User",
      message:
          "Are you sure you want to delete this user? This action cannot be undone.",
      confirmButtonText: "Delete",
      cancelButtonText: "Cancel",
      onTapCancel: () {
        Navigator.pop(context);
      },
      onTapConfirm: () async{
        if (isFilter) {
          await api.deleteUser(user[MyDatabase.USER_ID].toString());
          // setState(() {
            // widget.userObject.deleteUserFromFilteredUserList(
            //   email: user[EMAIL],
            //   phone: user[PHONE],
            // );
            // widget.userObject.deleteUserFromSearchResultList(
            //   id: user[MyDatabase.USER_ID],
            // );
            // fetchUserList();
            // fetchSearchList();
          // });

          fetchUserListWithApi();
          fetchFilterListWithApi();
          fetchSearchListWithApi();
          setState(() {

          });
        } else if (isSearch) {
          // setState(() {
            // widget.userObject.deleteUserFromSearchResultList(
            //   id: user[MyDatabase.USER_ID],
            // );
            // fetchUserList();
            // fetchSearchList();
          // });
          await api.deleteUser(user[MyDatabase.USER_ID].toString());
          fetchUserListWithApi();
          fetchSearchListWithApi();
        } else {
          // setState(() {
            // widget.userObject.deleteUserFromTblUser(
            //   id: user[MyDatabase.USER_ID],
            // );
            // fetchUserList();
            // fetchSearchList();
          // });
          await api.deleteUser(user[MyDatabase.USER_ID].toString());
          fetchUserListWithApi();
          fetchSearchListWithApi();
        }
        Navigator.pop(context);
        _showDeleteSuccessToast();
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

  void _showDeleteSuccessToast() {
    toastification.show(
      context: context,
      title: Text('User Deleted Successfully'),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: Duration(seconds: 3),
      showProgressBar: true,
      icon: Icon(Icons.delete_forever, color: Colors.white),
      primaryColor: Colors.red,
      backgroundColor: Colors.red.shade600,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      closeOnClick: true,
    );
  }
}

class EditUser extends StatefulWidget {
  final dynamic fName;
  final dynamic lName;
  final dynamic email;
  final dynamic phone;
  final dynamic dob;
  final dynamic hobbies;
  final dynamic city;
  final dynamic gender;
  final dynamic userObject;
  final dynamic isWishList;
  final dynamic id;
  const EditUser(
      {Key? key,
      this.fName,
      this.lName,
      this.email,
      this.phone,
      this.dob,
      this.gender,
      this.hobbies,
      this.city,
      this.userObject,
      this.isWishList,
      this.id})
      : super(key: key);

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController fName = TextEditingController();
  final TextEditingController lName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  List<String> cities = [
    'Select City',
    'Agartala',
    'Agra',
    'Ahmedabad',
    'Aizawl',
    'Ajmer',
    'Aligarh',
    'Allahabad',
    'Amritsar',
    'Aurangabad',
    'Bangalore',
    'Bareilly',
    'Bhopal',
    'Bhubaneswar',
    'Bilaspur',
    'Chandigarh',
    'Chennai',
    'Coimbatore',
    'Cuttack',
    'Dehradun',
    'Delhi',
    'Dhanbad',
    'Dibrugarh',
    'Durgapur',
    'Faridabad',
    'Gandhinagar',
    'Ghaziabad',
    'Gorakhpur',
    'Gurgaon',
    'Guwahati',
    'Gwalior',
    'Haridwar',
    'Hisar',
    'Hyderabad',
    'Imphal',
    'Indore',
    'Jabalpur',
    'Jaipur',
    'Jalandhar',
    'Jammu',
    'Jamnagar',
    'Jamshedpur',
    'Jhansi',
    'Jodhpur',
    'Kanpur',
    'Karnal',
    'Kochi',
    'Kohima',
    'Kolkata',
    'Kollam',
    'Kota',
    'Kozhikode',
    'Kurnool',
    'Ludhiana',
    'Lucknow',
    'Madurai',
    'Mangalore',
    'Meerut',
    'Mumbai',
    'Mysore',
    'Nagpur',
    'Nashik',
    'Noida',
    'Panaji',
    'Patiala',
    'Patna',
    'Pondicherry',
    'Pune',
    'Raipur',
    'Rajahmundry',
    'Rajkot',
    'Ranchi',
    'Rourkela',
    'Salem',
    'Siliguri',
    'Shimla',
    'Srinagar',
    'Surat',
    'Thane',
    'Thiruvananthapuram',
    'Thrissur',
    'Tiruchirappalli',
    'Tirupati',
    'Udaipur',
    'Ujjain',
    'Vadodara',
    'Varanasi',
    'Vellore',
    'Vijayawada',
    'Visakhapatnam',
    'Warangal'
  ];

  String? gender = 'Male';
  String? selectedCity;
  bool isReading = false;
  bool isTraveling = false;
  bool isGaming = false;
  bool isMusic = false;

  DateTime? dobDate;
  int? _pickedYear;

  List hobbies = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  List getHobbiesList(String inputString) {
    // Step 1: Remove the square brackets
    inputString = inputString.replaceAll('[', '').replaceAll(']', '');

    // Step 2: Split the string by comma (if there are multiple items)
    List<String> resultList =
        inputString.split(',').map((e) => e.trim()).toList();

    // Step 3: Print or use the result list
    print(resultList);
    return resultList;
  }

  void _initializeData() {
    fName.text = widget.fName;
    lName.text = widget.lName;
    email.text = widget.email;
    phone.text = widget.phone;
    dobDate = DateTime.parse(widget.dob);
    _pickedYear = dobDate!.year;
    dobController.text = DateFormat('dd-MM-yyyy').format(dobDate!);
    selectedCity = widget.city;
    gender = widget.gender;
    hobbies = getHobbiesList(widget.hobbies);
    isReading = hobbies.contains('Reading');
    isTraveling = hobbies.contains('Traveling');
    isGaming = hobbies.contains('Gaming');
    isMusic = hobbies.contains('Music');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,

      child: Container(

        margin: EdgeInsets.all(0),
        // width: MediaQuery.of(context).size.width * 1,
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPersonalInfo(),
                  const SizedBox(height: 24),
                  _buildContactInfo(),
                  const SizedBox(height: 24),
                  _buildLocationInfo(),
                  const SizedBox(height: 24),
                  _buildHobbies(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF594226),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Update your information",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Personal Information"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: fName,
                label: "First Name",
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (!RegExp(r"^[a-zA-Z\s'-]{3,50}$").hasMatch(value)) {
                    return 'Invalid name';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: lName,
                label: "Last Name",
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (!RegExp(r"^[a-zA-Z\s'-]{3,50}$").hasMatch(value)) {
                    return 'Invalid name';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildGenderSelector(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Contact Information"),
        const SizedBox(height: 16),
        _buildTextField(
          controller: email,
          label: "Email Address",
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) return 'Required';
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) {
              return 'Invalid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: phone,
          label: "Phone Number",
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: (value) {
            if (value!.isEmpty) return 'Required';
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
              return 'Invalid number';
            }
            return null;
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Location"),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: CustomDropdown<String>.search(
            hintText: 'Select City',
            items: cities,
            excludeSelected: false,
            initialItem: selectedCity ?? 'Select City',
            decoration: CustomDropdownDecoration(
              closedFillColor: Colors.grey[50],
              closedBorderRadius: BorderRadius.circular(12),
              searchFieldDecoration: SearchFieldDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() => selectedCity = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHobbies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Hobbies & Interests"),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildHobbyTile(
                title: "Reading",
                value: isReading,
                onChanged: (value) {
                  setState(() {
                    isReading = value!;
                    _updateHobbies('Reading', value);
                  });
                },
              ),
              _buildDivider(),
              _buildHobbyTile(
                title: "Traveling",
                value: isTraveling,
                onChanged: (value) {
                  setState(() {
                    isTraveling = value!;
                    _updateHobbies('Traveling', value);
                  });
                },
              ),
              _buildDivider(),
              _buildHobbyTile(
                title: "Gaming",
                value: isGaming,
                onChanged: (value) {
                  setState(() {
                    isGaming = value!;
                    _updateHobbies('Gaming', value);
                  });
                },
              ),
              _buildDivider(),
              _buildHobbyTile(
                title: "Music",
                value: isMusic,
                onChanged: (value) {
                  setState(() {
                    isMusic = value!;
                    _updateHobbies('Music', value);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF594226),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF594226),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF594226)),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Date of Birth",
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        suffixIcon: Icon(Icons.calendar_today_rounded),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dobDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF594226),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            dobDate = picked;
            _pickedYear = picked.year;
            dobController.text = DateFormat('dd-MM-yyyy').format(picked);
          });
        }
      },
      validator: (value) {
        if (value!.isEmpty) return 'Required';
        if ((DateTime.now().year - _pickedYear!) < 18) {
          return 'Must be 18 or older';
        }
        if ((DateTime.now().year - _pickedYear!) > 80) {
          return 'Invalid age';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildGenderOption(
            title: "Male",
            value: "Male",
            icon: Icons.male_rounded,
          ),
          const SizedBox(width: 16),
          _buildGenderOption(
            title: "Female",
            value: "Female",
            icon: Icons.female_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = gender == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => gender = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF594226).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Color(0xFF594226) : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Color(0xFF594226) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHobbyTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF594226),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xFF594226),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  void _updateHobbies(String hobby, bool value) {
    if (value) {
      hobbies.add(hobby);
    } else {
      hobbies.remove(hobby);
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // await widget.userObject.updateUserInTblUser(
      //     FName: fName.text,
      //     LName: lName.text,
      //     phone: phone.text,
      //     email: email.text,
      //     city: selectedCity,
      //     dob: dobDate.toString(),
      //     gender: gender,
      //     hobbies: hobbies.toString(),
      //     isWishList: widget.isWishList,
      //     id: widget.id);

      Map<String, dynamic> map = {};
      map[FNAME] = fName.text;
      map[LNAME] = lName.text;
      map[PHONE] = phone.text;
      map[EMAIL] = email.text;
      map[CITY] = selectedCity;
      map[DOB] = dobDate.toString();
      map[GENDER] = gender;
      map[HOBBIES] = hobbies.toString();
      map[ISWISHLIST] = widget.isWishList;
      map[MyDatabase.USER_ID] = widget.id;

      await api.updateUser(map[MyDatabase.USER_ID].toString(), map);

      Navigator.pop(context);
    }
  }
}

class FilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilter;
  final Function() onClear;
  final String selectedCity;
  final String selectedGender;
  final String minAge;
  final String maxAge;

  FilterWidget({
    required this.onFilter,
    required this.onClear,
    required this.selectedCity,
    required this.selectedGender,
    required this.minAge,
    required this.maxAge,
  });

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late String selectedCity;
  late String selectedGender;
  late TextEditingController minAgeController;
  late TextEditingController maxAgeController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Constants for colors
  static const Color primaryColor = Color(0xFF594226);
  static const Color accentColor = Color(0xFFFFDEA4);
  static const Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    selectedCity = widget.selectedCity;
    selectedGender = widget.selectedGender;
    minAgeController = TextEditingController(text: widget.minAge);
    maxAgeController = TextEditingController(text: widget.maxAge);
    print('Selected City : $selectedCity');
  }

  @override
  void dispose() {
    minAgeController.dispose();
    maxAgeController.dispose();
    super.dispose();
  }

  List<String> cities = [
    'Select City',
    'Agartala',
    'Agra',
    'Ahmedabad',
    'Aizawl',
    'Ajmer',
    'Aligarh',
    'Allahabad',
    'Amritsar',
    'Aurangabad',
    'Bangalore',
    'Bareilly',
    'Bhopal',
    'Bhubaneswar',
    'Bilaspur',
    'Chandigarh',
    'Chennai',
    'Coimbatore',
    'Cuttack',
    'Dehradun',
    'Delhi',
    'Dhanbad',
    'Dibrugarh',
    'Durgapur',
    'Faridabad',
    'Gandhinagar',
    'Ghaziabad',
    'Gorakhpur',
    'Gurgaon',
    'Guwahati',
    'Gwalior',
    'Haridwar',
    'Hisar',
    'Hyderabad',
    'Imphal',
    'Indore',
    'Jabalpur',
    'Jaipur',
    'Jalandhar',
    'Jammu',
    'Jamnagar',
    'Jamshedpur',
    'Jhansi',
    'Jodhpur',
    'Kanpur',
    'Karnal',
    'Kochi',
    'Kohima',
    'Kolkata',
    'Kollam',
    'Kota',
    'Kozhikode',
    'Kurnool',
    'Ludhiana',
    'Lucknow',
    'Madurai',
    'Mangalore',
    'Meerut',
    'Mumbai',
    'Mysore',
    'Nagpur',
    'Nashik',
    'Noida',
    'Panaji',
    'Patiala',
    'Patna',
    'Pondicherry',
    'Pune',
    'Raipur',
    'Rajahmundry',
    'Rajkot',
    'Ranchi',
    'Rourkela',
    'Salem',
    'Siliguri',
    'Shimla',
    'Srinagar',
    'Surat',
    'Thane',
    'Thiruvananthapuram',
    'Thrissur',
    'Tiruchirappalli',
    'Tirupati',
    'Udaipur',
    'Ujjain',
    'Vadodara',
    'Varanasi',
    'Vellore',
    'Vijayawada',
    'Visakhapatnam',
    'Warangal'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar at the top
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Filter Options',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // City Dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomDropdown<String>.search(
                    hintText: 'Select City',
                    items: cities,
                    excludeSelected: false,
                    initialItem:
                        selectedCity.isEmpty ? 'Select City' : selectedCity,
                    decoration: CustomDropdownDecoration(
                      listItemStyle: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle:
                          TextStyle(color: primaryColor.withOpacity(0.5)),
                      prefixIcon: const Icon(
                        Icons.location_on_rounded,
                        color: primaryColor,
                      ),
                      closedFillColor: accentColor.withOpacity(0.15),
                      closedBorder: Border.all(
                        width: 1.5,
                        color: primaryColor.withOpacity(0.2),
                      ),
                      closedBorderRadius: BorderRadius.circular(16),
                    ),
                    onChanged: (value) => setState(() => selectedCity = value!),
                  ),
                ),
                const SizedBox(height: 16),
                // Gender Dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomDropdown<String>(
                    hintText: 'Select Gender',
                    items: const ['Select Gender', 'Male', 'Female'],
                    excludeSelected: false,
                    initialItem: selectedGender.isEmpty
                        ? 'Select Gender'
                        : selectedGender,
                    decoration: CustomDropdownDecoration(
                      listItemStyle: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle:
                          TextStyle(color: primaryColor.withOpacity(0.5)),
                      prefixIcon: const Icon(
                        Icons.person_rounded,
                        color: primaryColor,
                      ),
                      closedFillColor: accentColor.withOpacity(0.15),
                      closedBorder: Border.all(
                        width: 1.5,
                        color: primaryColor.withOpacity(0.2),
                      ),
                      closedBorderRadius: BorderRadius.circular(16),
                    ),
                    onChanged: (value) =>
                        setState(() => selectedGender = value!),
                  ),
                ),
                const SizedBox(height: 17),
                // Age Range
                Text(
                  'Age Range',
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: minAgeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Min Age',
                            labelStyle: TextStyle(
                              color: primaryColor.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: accentColor.withOpacity(0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final age = int.tryParse(value);
                            if (age == null) return 'Invalid';
                            if (age < 18) return 'Min: 18';
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: maxAgeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Max Age',
                            labelStyle: TextStyle(
                              color: primaryColor.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: accentColor.withOpacity(0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final age = int.tryParse(value);
                            if (age == null) return 'Invalid';
                            if (age > 80) return 'Max: 80';
                            if (age < int.parse(minAgeController.text)) {
                              return '≥ Min Age';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onFilter({
                              CITY: selectedCity,
                              GENDER: selectedGender,
                              MINAGE: minAgeController.text,
                              MAXAGE: maxAgeController.text,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          widget.onClear();
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: primaryColor,
                        ),
                        tooltip: 'Clear Filters',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(
        0.0, size.height - 40); // Start the larger wave at a higher position

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(
        0.0, size.height - 20); // Start the smaller wave lower than the first

    var firstControlPoint = Offset(size.width / 4, size.height - 40);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 20);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
