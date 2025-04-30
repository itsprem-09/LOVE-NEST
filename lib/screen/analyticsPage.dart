import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:matrimony/api/apiService.dart';
import '../db/db.dart';
import '../model/userDb.dart';

class AdminAnalyticsPage extends StatefulWidget {
  @override
  _AdminAnalyticsPageState createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  // Existing state variables and initState remain same

  int totalUsers = 0;
  Map<String, int> genderDistribution = {'Male': 0, 'Female': 0};
  Map<String, int> cityDistribution = {};
  Map<String, int> ageDistribution = {};
  Map<String, int> hobbyDistribution = {}; // No fixed values, it will be dynamic

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  // Add loading state
  bool _isLoading = true;

  Future<void> _loadAnalytics() async {
    // Existing data loading logic...

    setState(() => _isLoading = true);

    // UserDb userDb = UserDb();
    // List<Map<String, dynamic>> users = await userDb.getUserList();

    ApiService api = ApiService();
    List? users = await api.getUsers();

    setState(() {
      totalUsers = users!.length;
    });

    List getHobbiesList(String inputString){
      // Step 1: Remove the square brackets
      inputString = inputString.replaceAll('[', '').replaceAll(']', '');

      // Step 2: Split the string by comma (if there are multiple items)
      List<String> resultList = inputString.split(',').map((e) => e.trim()).toList();

      // Step 3: Print or use the result list
      print(resultList);
      return resultList;
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

    for (var user in users!) {
      // Gender Distribution
      genderDistribution[user[MyDatabase.GENDER]] =
          (genderDistribution[user[MyDatabase.GENDER]] ?? 0) + 1;

      // City Distribution
      cityDistribution[user[MyDatabase.CITY]] =
          (cityDistribution[user[MyDatabase.CITY]] ?? 0) + 1;

      // Age Distribution

      // int age = user[MyDatabase.DOB];
      int age = _calculateAge(user[MyDatabase.DOB]);

      String ageRange =
          (age ~/ 10 * 10).toString() + '-' + ((age ~/ 10 * 10) + 9).toString();
      ageDistribution[ageRange] = (ageDistribution[ageRange] ?? 0) + 1;

      // Hobby Distribution (Dynamic)
      String hobbies = user[MyDatabase.HOBBIES];
      List hobbyList = getHobbiesList(hobbies);

      for (String hobby in hobbyList) {
        if (hobbyDistribution.containsKey(hobby)) {
          hobbyDistribution[hobby] = hobbyDistribution[hobby]! + 1;
        } else {
          hobbyDistribution[hobby] = 1; // Initialize hobby if not present
        }
      }
    }

    setState(() {});

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F5F1),
      appBar: AppBar(
        title: Text(
          'Analytics',
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF594226)))
          : Column(
        children: [
          SizedBox(height: 25),
          _buildHeader(),
          SizedBox(height: 25),
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.6,
                enlargeCenterPage: true,
                autoPlay: true,
                viewportFraction: 0.8,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                enableInfiniteScroll: true,
                onPageChanged: (index, _) => setState(() => _currentIndex = index),
              ),
              items: [
                _buildChartCard('Gender', genderDistribution, [Colors.blueAccent, Colors.pinkAccent]),
                _buildChartCard('City', cityDistribution, [Colors.green, Colors.teal]),
                _buildChartCard('Age Group', ageDistribution, [Colors.amber, Colors.orange]),
                _buildChartCard('Hobbies', hobbyDistribution, [Colors.purple, Colors.deepPurple]),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildDotsIndicator(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  int _currentIndex = 0;

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF594226), Color(0xFF8C6B4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF594226).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_rounded, color: Color(0xFFFFDEA4), size: 34),
            SizedBox(width: 15),
            Column(
              children: [
                Text(
                  'Total Users',
                  style: TextStyle(
                    color: Color(0xFFFFDEA4).withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  totalUsers.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            width: _currentIndex == index ? 24 : 10,
            height: 10,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? Color(0xFF594226)
                  : Color(0xFF594226).withOpacity(0.4),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartCard(String title, Map<String, int> data, List<Color> colors) {
    final total = data.values.fold(0, (a, b) => a + b);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "$title Distribution",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF594226),
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _buildSections(data, colors, total),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          _buildLegend(data, colors),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(Map<String, int> data, List<Color> colors, int total) {
    int colorIndex = 0;
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final section = PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n($percentage%)',
        color: colors[colorIndex % colors.length],
        radius: 75,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.2,
        ),
      );
      colorIndex++;
      return section;
    }).toList();
  }

  // region Another Style to show text

  // List<PieChartSectionData> _buildSections(Map<String, int> data, List<Color> colors, int total) {
  //   int colorIndex = 0;
  //   return data.entries.map((entry) {
  //     final percentage = (entry.value / total * 100);
  //     final displayText = percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '';  // Hide text for small sections
  //     final section = PieChartSectionData(
  //       value: entry.value.toDouble(),
  //       title: displayText,  // Only display text if the percentage is large enough
  //       color: colors[colorIndex % colors.length],
  //       radius: 75,
  //       titleStyle: TextStyle(
  //         fontSize: 14,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.white,
  //         height: 1.2,
  //       ),
  //       titlePositionPercentageOffset: 0.6,  // Adjust the position of the text
  //     );
  //     colorIndex++;
  //     return section;
  //   }).toList();
  // }

  //endregion


  Widget _buildLegend(Map<String, int> data, List<Color> colors) {
    int colorIndex = 0;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: data.entries.map((entry) {
        final widget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[colorIndex % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              entry.key,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        );
        colorIndex++;
        return widget;
      }).toList(),
    );
  }
}