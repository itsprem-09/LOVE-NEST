import 'package:animate_do/animate_do.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:matrimony/api/apiService.dart';
import 'package:matrimony/model/user.dart';
import 'package:matrimony/screen/aboutUs.dart';
import 'package:matrimony/screen/addUserFormScreen.dart';
import 'package:matrimony/screen/dashboardScreen.dart';
import 'package:matrimony/screen/view_users.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:toastification/toastification.dart';
import '../db/db.dart';
import '../utils/constants.dart';

ApiService api = ApiService();

class Wishlist extends StatefulWidget {
  var userObject;

  Wishlist({super.key, this.userObject});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  TextEditingController searchDetails = TextEditingController();

  List wishList = [];
  List searchResult = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.userObject != null) {
      // fetchWishList();
      // fetchSearchList();
      fetchWishListWithApi();
      fetchSearchListWithApi();
    }
  }

  Future<void> fetchWishList() async {
    List temp = await widget.userObject.getWishList();
    setState(() {
      wishList = temp;
    });
  }

  Future<void> fetchWishListWithApi() async {
    List? temp = await api.getWishList();
    setState(() {
      wishList = temp!;
    });
  }

  Future<void> fetchSearchList() async {
    List temp =
    await widget.userObject.searchWishListedUser(searchData: searchDetails.text);
    setState(() {
      searchResult = temp;
    });
  }

  Future<void> fetchSearchListWithApi() async {
    List? temp = await api.searchWishListedUser(searchDetails.text);
    setState(() {
      searchResult = temp!;
    });
  }


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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(192.0), // Height of the AppBar
        child: AppBar(
          leadingWidth: 30,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_outlined,
                size: 28,
                color: Color.fromARGB(255, 255, 222, 164),
              )),
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
              // region SearchBar
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
                    ),
                  ),
                ),
              ),
              // endregion
            ],
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Favourite Users',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 222, 164),
                fontSize: 28,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          // AppBar background transparent
          elevation: 0, // No shadow
        ),
      ),
      body: FutureBuilder(future: api.getWishList(), builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }
        else if(snapshot.hasData && snapshot.data != null){
          return (searchDetails.text.isNotEmpty && searchResult.isEmpty) ||
              (searchDetails.text.isEmpty && wishList.isEmpty)
              ? Center(
            child: FadeInUp(
              duration: Duration(milliseconds: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.heart_broken_sharp,
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
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Column(
              children: [
                FutureBuilder(future: widget.userObject.getWishList(), builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null){
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          // return userList[index][ISWISHLIST]
                          //     ? (searchDetails.text.isNotEmpty &&
                          //     searchResultList.isNotEmpty)
                          //     ? userComponent(user: searchResultList[index], i: index, isSearch: true) : userComponent(user: userList[index], i: index)
                          //     : null;
                          if (searchDetails.text.isNotEmpty) {
                            return userComponent(
                                user: searchResult[index],
                                i: index,
                                isSearch: true);
                          } else {
                            return userComponent(user: wishList[index], i: index);
                          }
                        },
                        itemCount: searchDetails.text.isNotEmpty
                            ? searchResult.length
                            : wishList.length,
                      ),
                    );
                  }
                  else{
                    print('else block');
                    return CircularProgressIndicator();
                  }
                },)
              ],
            ),
          );
        }
        else{
          return Center(child: CircularProgressIndicator());
        }
      },)


    );
  }

  Widget userComponent({required user, i, bool isSearch = false}) {
    print('|||| user Component : ${user}');
    return Container(
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
                      shape: BoxShape.circle),
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
                              widget.userObject.updateUser(user : user);
                            });
                            fetchWishList();
                            fetchSearchList();
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
                        SizedBox(width: 4),
                        Text(
                          user[CITY],
                          style: TextStyle(
                            color: Color(0xFF594226).withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xFF594226).withOpacity(0.4),
                            ),
                          ),
                        ),
                        Text(
                          '${user[AGE]} years',
                          style: TextStyle(
                            color: Color(0xFF594226).withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EditUser(
                              fName: user[FNAME],
                              lName: user[LNAME],
                              email: user[EMAIL],
                              phone: user[PHONE],
                              dob: user[DOB],
                              hobbies: user[HOBBIES],
                              city: user[CITY],
                              gender: user[GENDER],
                              userObject: widget.userObject,
                              isWishList: user[ISWISHLIST],
                            );
                          },
                        );
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: Colors.red,
                      label: 'Delete',
                      onTap: () {
                        _showDeleteConfirmation(user, isSearch);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

  void _showDeleteConfirmation(user, bool isSearch) {
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
      onTapConfirm: () {
        if (isSearch) {
          setState(() {
            // widget.userObject.deleteUserFromSearchResultList(
            //   id: user[MyDatabase.USER_ID],
            // );
            // fetchWishList();
            // fetchSearchList();

            api.deleteUser(user[MyDatabase.USER_ID].toString());
          });
          fetchSearchListWithApi();
          fetchWishListWithApi();

        } else {
          setState(() {
            // widget.userObject.deleteUserFromTblUser(
            //   id: user[MyDatabase.USER_ID],
            // );
            // fetchWishList();
            // fetchSearchList();


            api.deleteUser(user[MyDatabase.USER_ID].toString());
            fetchWishListWithApi();
            fetchSearchListWithApi();

          });
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
