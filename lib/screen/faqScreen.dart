import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQs',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              letterSpacing: 1.2,
              color: Color(0xFFFFDEA4)
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF594226),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFaqItem(
              'How do I log in as an admin?',
              'To log in, use the credentials provided by the system administrator. After logging in, you will have access to admin-specific features such as adding and managing users.',
            ),
            _buildFaqItem(
              'How do I add a new user?',
              'In the dashboard, tap on "Add User". Fill in all the required details such as name, age, city, and preferences. After filling in, tap "Submit" to add the user to the system.',
            ),
            _buildFaqItem(
              'How do I edit or delete a user?',
              'Go to the "Manage Users" section. Select the user you want to edit or delete. You can update the user’s details by tapping the "Edit" button or delete them from the system by tapping "Delete".',
            ),
            _buildFaqItem(
              'How do I view user analytics?',
              'In the admin dashboard, navigate to "Analytics". Here, you can view statistics such as total number of users, gender distribution, age group percentages, city-wise user distribution, and hobbies. The data is displayed through pie charts for easy analysis.',
            ),
            _buildFaqItem(
              'Can I add users to a favorite list?',
              'Yes, as an admin, you can mark users as favorites. Simply go to a user profile and tap on the "Add to Favorites" button to mark them as a favorite user.',
            ),
            _buildFaqItem(
              'How do I send notifications to users?',
              'To send notifications, go to the "Notifications" section in the admin dashboard. Select the user(s) or groups you want to notify, write your message, and tap "Send". Users will receive the notification instantly.',
            ),
            _buildFaqItem(
              'How do I log out as an admin?',
              'To log out, tap on your profile icon in the top-right corner of the admin dashboard. From the dropdown menu, select "Log Out". You will be redirected to the login screen.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      color: Color(0xFFFFDEA4), // Background color for FAQ items
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF594226), // Text color matching theme
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              answer,
              style: TextStyle(fontSize: 16, color: Color(0xFF594226)),
            ),
          ),
        ],
      ),
    );
  }
}
