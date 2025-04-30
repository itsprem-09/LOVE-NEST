import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:matrimony/model/loginDetailsDb.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../db/db.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _msgController = TextEditingController();
  List<String> selectedUsers = [];

  List<String> users = [];
  List<Map<String, dynamic>> notifications = [];
  int? loggedUserId; // Variable to store the logged-in user ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLoggedUserId(); // Fetch logged-in user ID
    _fetchUsers();
    _fetchNotifications();
  }

  // Fetch logged-in user ID from SharedPreferences
  Future<int?> _fetchLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('loggedUserId');
    setState(() {
      loggedUserId = id;
    });
    print('Fetched loggedUserId: $id'); // Add this to check the value
    return id;
  }

  // Fetch users from the Tbl_User table to populate dropdown
  Future<void> _fetchUsers() async {
    Database db = await MyDatabase().initDatabase();
    List<Map<String, dynamic>> userList = await db.query(MyDatabase.TBL_USER);
    setState(() {
      users = userList
          .map((user) => '${user[MyDatabase.FNAME]} ${user[MyDatabase.LNAME]}')
          .toList();
      users.insert(0, 'Select All Users');
    });
  }

  // Fetch notifications with user names from Tbl_Notification and Tbl_User
  Future<void> _fetchNotifications() async {
    Database db = await MyDatabase().initDatabase();
    List<Map<String, dynamic>> notificationList = await db.rawQuery('''
      SELECT n.*, u.${MyDatabase.FNAME}, u.${MyDatabase.LNAME}
      FROM ${MyDatabase.TBL_NOTIFICATION} n
      LEFT JOIN ${MyDatabase.TBL_USER} u ON n.${MyDatabase.USER_ID} = u.${MyDatabase.USER_ID}
    ''');
    setState(() {
      notifications = notificationList;
    });
  }

  // Insert notification into Tbl_Notification
  Future<void> _sendNotification() async {
    String msg = _msgController.text;

    if (selectedUsers.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please select at least one user and enter a message.')),
      );
      return;
    }

    if (loggedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged-in user ID not found.')),
      );
      return;
    }

    Database db = await MyDatabase().initDatabase();

    String currentTime = DateTime.now().toIso8601String();

    for (String user in selectedUsers) {
      if (user != 'Select All') {
        List<Map<String, dynamic>> userRecord = await db.query(
          MyDatabase.TBL_USER,
          where: "${MyDatabase.FNAME} || ' ' || ${MyDatabase.LNAME} = ?",
          whereArgs: [user],
        );

        if (userRecord.isNotEmpty) {
          int userId = userRecord.first[MyDatabase.USER_ID];
          await db.insert(MyDatabase.TBL_NOTIFICATION, {
            MyDatabase.LOGIN_ID: loggedUserId, // Use fetched logged-in user ID
            MyDatabase.USER_ID: userId,
            MyDatabase.MSG: msg,
            MyDatabase.RECEIVED_TIME : currentTime,
          });
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification sent successfully!')),
    );

    _msgController.clear();
    setState(() {
      selectedUsers.clear();
    });
    _fetchNotifications(); // Refresh notifications
  }

  @override
  void dispose() {
    _tabController.dispose();
    _msgController.dispose();
    selectedUsers = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // region claude

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: Color(0xFF594226),
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 222, 164),
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Increased font size
                  shadows: [ // Added text shadow for better visibility
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              centerTitle: true, // Center the title
              titleSpacing: 16, // Add padding to avoid overlap
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF594226),
                        Color(0xFF8B6B42),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(65),
                child: FadeInDown(
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Color(0xFF594226),
                      unselectedLabelColor: Colors.grey[400],
                      indicatorColor: Color(0xFF594226),
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        FadeIn(
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded),
                                SizedBox(width: 8),
                                Text('Send'),
                              ],
                            ),
                          ),
                        ),
                        FadeIn(
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_active),
                                SizedBox(width: 8),
                                Text('View'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.grey[100],
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSendNotificationTab(),
              _buildViewNotificationTab(),
            ],
          ),
        ),
      ),
    );

    // endregion

    // region DeepSeek


    // endregion
  }

  // region DeepSeek

  // endregion

  // region Claude

  Widget _buildSendNotificationTab() {
    if (loggedUserId == null) {
      return Center(
        child: FadeIn(
          child: Text(
            'Please log in to send notifications.',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: FadeInUp(
        duration: Duration(milliseconds: 500),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Recipients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF594226),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomDropdown.multiSelectSearch(
                        items: users,
                        hintText: 'Choose users',
                        initialItems: selectedUsers,
                        onListChanged: (value) {
                          setState(() {
                            if (value.contains('Select All Users')) {
                              selectedUsers = value.contains('Select All Users') && !selectedUsers.contains('Select All Users')
                                  ? users.where((user) => user != 'Select All Users').toList()
                                  : [];
                            } else {
                              selectedUsers = value ?? [];
                            }
                          });
                        },
                        decoration: CustomDropdownDecoration(
                          closedFillColor: Colors.grey[50],
                          expandedFillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          headerStyle: TextStyle(color: Color(0xFF594226)),
                          listItemStyle: TextStyle(color: Color(0xFF594226)),
                          closedBorderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compose Message',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF594226),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _msgController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Type your message here...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _sendNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF594226),
                    foregroundColor: Color.fromARGB(255, 255, 222, 164),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, color: Color.fromARGB(255, 255, 222, 164),),
                      SizedBox(width: 8),
                      Text(
                        'Send Notification',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // endregion

  // region DeepSeek

  // endregion

  // region Claude

  Widget _buildViewNotificationTab() {
    if (notifications.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return FadeInLeft(
          delay: Duration(milliseconds: 100 * index),
          child: _buildNotificationCard(notifications[index]),
        );
      },
    );
  }

  // endregion

  // Enhanced Notification Card

  // region DeepSeek

  // endregion

  // region Claude

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    String userName = '${notification[MyDatabase.FNAME]} ${notification[MyDatabase.LNAME]}';
    String message = notification[MyDatabase.MSG];
    String receivedTimeStr = notification[MyDatabase.RECEIVED_TIME];
    int loginId = notification[MyDatabase.LOGIN_ID] as int;

    DateTime receivedTime = DateTime.parse(receivedTimeStr);
    String formattedDate = "${receivedTime.day} ${_getMonthName(receivedTime.month)} ${receivedTime.year} at ${_formatTime(receivedTime)}";

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: 120,
                      right: 20,
                      top: 25,
                      bottom: 15
                  ),
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF594226),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 20,
                        color: Color(0xFF594226).withOpacity(0.7),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Received at',
                        style: TextStyle(
                          color: Color(0xFF594226).withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: Color(0xFF594226),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: FutureBuilder<String>(
                    future: LoginDetails().getUsernameByLoginId(loginId),
                    builder: (context, snapshot) {
                      return Row(
                        children: [
                          Icon(
                            Icons.person_outline_sharp,
                            size: 20,  // Increased icon size
                            color: Color(0xFF594226).withOpacity(0.7),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Received from',
                            style: TextStyle(
                              color: Color(0xFF594226).withOpacity(0.7),
                              fontSize: 15,  // Increased font size
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),  // Slightly increased spacing
                          Expanded(
                            child: Text(
                              snapshot.data ?? 'Loading...',
                              style: TextStyle(
                                color: Color(0xFF594226),
                                fontSize: 16,  // Increased font size
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF594226),
                child: Text(
                  userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get month name
  String _getMonthName(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Helper function to format time
  String _formatTime(DateTime time) {
    String hour = time.hour > 12 ? (time.hour - 12).toString() : time.hour.toString();
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  // endregion
}
