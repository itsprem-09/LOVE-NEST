import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:matrimony/api/apiService.dart';
import 'package:matrimony/model/user.dart';
import 'package:matrimony/model/userDb.dart';
import 'package:matrimony/screen/aboutUs.dart';
import 'package:matrimony/screen/dashboardScreen.dart';
import 'package:matrimony/screen/view_users.dart';
import 'package:matrimony/screen/wishlist.dart';
import 'package:matrimony/utils/constants.dart';
import 'package:toastification/toastification.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'dart:developer';

ApiService api = ApiService();

class AddUserFormScreen extends StatefulWidget {
  var userObject;
  AddUserFormScreen({Key? key, this.userObject}) : super(key: key);

  @override
  State<AddUserFormScreen> createState() => _AddUserFormScreenState();
}

class _AddUserFormScreenState extends State<AddUserFormScreen> {
  TextEditingController fName = TextEditingController();
  TextEditingController lName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController dobController = TextEditingController();

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

  List hobbies = [];

  GlobalKey<FormState> _formKey = GlobalKey();

  DateTime? dobDate;
  int? _pickedYear;


  int pageIndex = 1;

  @override
  Widget build(BuildContext context) {

    var user = widget.userObject;

    List pages = [
      Wishlist(userObject: widget.userObject,),
      AddUserFormScreen(userObject: widget.userObject,),
      DashboardScreen(userObject: widget.userObject,),
      ViewUsers(userObject: widget.userObject,),
      AboutUs(userObject: widget.userObject,)
    ];

    return Scaffold(
      // bottomNavigationBar: CurvedNavigationBar(
      //   backgroundColor: Color.fromARGB(255, 255, 222, 164),
      //   color: Color(0xFF594226),
      //   animationCurve: Curves.ease,
      //   index: 1,
      //   animationDuration: Duration(seconds: 5),
      //   items: <Widget>[
      //     Icon(
      //       Icons.favorite_rounded,
      //       size: 30,
      //       color: Color.fromARGB(255, 255, 222, 164),
      //     ),
      //     Icon(
      //       Icons.person_add,
      //       size: 30,
      //       color: Color.fromARGB(255, 255, 222, 164),
      //     ),
      //     Icon(
      //       Icons.home_outlined,
      //       size: 30,
      //       color: Color.fromARGB(255, 255, 222, 164),
      //     ),
      //     Icon(
      //       Icons.assignment_ind_rounded,
      //       size: 30,
      //       color: Color.fromARGB(255, 255, 222, 164),
      //     ),
      //     Icon(
      //       Icons.info_outlined,
      //       size: 30,
      //       color: Color.fromARGB(255, 255, 222, 164),
      //     )
      //   ],
      //   onTap: (index) {
      //     setState(() {
      //       print('Index : ${index}');
      //         Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => pages[index],
      //             ),
      //         );
      //     });
      //   },
      //   letIndexChange: (index) => true,
      // ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 380.0,
              backgroundColor: Color.fromARGB(136, 89, 65, 57),
              floating: false,
              pinned: true,
              stretch: true,
              iconTheme: IconThemeData(
                color: Color.fromARGB(255, 255, 222, 164)
              ),
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: const Text(
                    "Join Us",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 222, 164),
                      fontSize: 29.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Image.asset(
                    "assets/images/logo1.png",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              color: Color.fromARGB(255, 255, 222, 164),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                              maxLength: 50,
                              controller: fName,
                            textCapitalization: TextCapitalization.words,

                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-z,A-Z]'))],
                              validator: (value) {
                                if (value!.length < 3 || value.length > 50) {
                                  return 'First Name Length Must be in Range of [3-50]';
                                }
                                if (!RegExp(r"^[a-zA-Z\s'-]{3,50}$")
                                    .hasMatch(value)) {
                                  return '"Enter a valid First Name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                counterText: '',
                                prefixIcon: Icon(
                                  Icons.account_circle_rounded,
                                  size: 25,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                        color: Color(0xFF594226), width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                        color: Color(0xFF594226), width: 3.0)),
                              ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.02,
                        ),
                        Expanded(
                          child: TextFormField(
                              maxLength: 50,
                              controller: lName,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-z,A-Z]'))],
                              validator: (value) {
                                if (value!.length < 3 || value.length > 50) {
                                  return 'Last Name Length Must be in Range of [3-50]';
                                }
                                if (!RegExp(r"^[a-zA-Z\s'-]{3,50}$")
                                    .hasMatch(value)) {
                                  return '"Enter a valid Last Name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                counterText: '',
                                prefixIcon: Icon(
                                  Icons.account_circle_rounded,
                                  size: 25,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                        color: Color(0xFF594226), width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                        color: Color(0xFF594226), width: 3.0)),
                              ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    TextFormField(
                      controller: phone,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Mobile No. Must be not Empty';
                        }
                        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                          return '"Enter a valid 10-digit mobile number.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Mobile No.',
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.call_rounded,
                          size: 25,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                                color: Color(0xFF594226), width: 1.0)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                                color: Color(0xFF594226), width: 3.0)),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email Must be not Empty';
                          }
                          if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            size: 25,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                  color: Color(0xFF594226), width: 1.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(9),
                              borderSide: BorderSide(
                                  color: Color(0xFF594226), width: 3.0)),
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton.icon(
                    //         style: ElevatedButton.styleFrom(elevation: 2,shape: RoundedRectangleBorder(), backgroundColor: Color(0xFF594226), foregroundColor: Color.fromARGB(255, 255, 222, 164), padding: EdgeInsets.all(3), minimumSize: Size.fromHeight(50)),
                    //         onPressed: () async {
                    //           dobDate = await showDatePicker(
                    //             errorInvalidText: 'Age must be in range 18-80',
                    //               errorFormatText: 'Age between 18 to 80',
                    //               context: context,
                    //               firstDate: DateTime(DateTime.now().year - 80),
                    //               lastDate:  DateTime(DateTime.now().year - 18),
                    //               initialDate: DateTime.now().isAfter(DateTime(DateTime.now().year - 18)) ? DateTime(DateTime.now().year - 18) : DateTime.now(),
                    //               helpText: "Select your date of birth"
                    //           );
                    //           if (dobDate != null) {
                    //             print(dobDate);
                    //             String formattedDate = DateFormat('dd/MM/yyyy').format(dobDate!);
                    //
                    //             if(RegExp(r"^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$").hasMatch(formattedDate)){
                    //               int age = DateTime.now().year - dobDate!.year;
                    //               if (DateTime.now().month < dobDate!.month ||
                    //                   (DateTime.now().month == dobDate!.month && DateTime.now().day < dobDate!.day)) {
                    //                 age--;
                    //               }
                    //               setState(() {
                    //                   dobController.text = formattedDate;
                    //               });
                    //             }
                    //           }
                    //         },
                    //         label: dobController.text == '' ? Text('Date of Birth') : Text('${dobController.text}'),
                    //         icon: Icon(Icons.date_range,size: 25,),
                    //       ),
                    //     ),
                    //     SizedBox(width: 15,),
                    //     Expanded(
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           border: Border.all(
                    //             color: Color(0xFF594226),
                    //             style: BorderStyle.solid,
                    //             width: 2,           // Set the border width
                    //           ),
                    //           borderRadius: BorderRadius.circular(12), // Optional: To give rounded corners
                    //         ),
                    //         child: DropdownButton(
                    //           value: selectedCity,
                    //           elevation: 12,
                    //           isExpanded: true,
                    //           padding: EdgeInsets.all(3),
                    //           hint: Text('City'),
                    //           items: cities.map((city) {
                    //             return DropdownMenuItem(
                    //               value: city,
                    //               child: Text(city.toString()),
                    //             );
                    //           }).toList(),
                    //           onChanged: (value) {
                    //             setState(() {
                    //               selectedCity = value;
                    //             });
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    TextFormField(
                      readOnly: true,
                      controller: dobController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        labelText: 'Date of Birth',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                                color: Color(0xFF594226), width: 1.0)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                                color: Color(0xFF594226), width: 3.0)),
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 222, 164),
                      ),
                      onTap: () async {
                        dobDate = await showDatePicker(
                          context: context,
                          initialDate: dobDate ?? DateTime.now().subtract(Duration(days: 365*18)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (dobDate != null) {
                          setState(() {
                            _pickedYear = dobDate!.year;
                            dobController.text =
                                DateFormat('dd-MM-yyyy').format(dobDate!);
                          });
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please select your date of birth';
                        }
                        if ((DateTime.now().year - _pickedYear!) < 18) {
                          return 'You are not younger enough to register!!';
                        }
                        if ((DateTime.now().year - _pickedYear!) > 80) {
                          return 'You are too old to register!!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    // DropdownButtonFormField<String>(
                    //   decoration: InputDecoration(
                    //     prefixIcon: Icon(Icons.location_city_rounded),
                    //     labelText: 'City',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(9),
                    //       borderSide:
                    //           BorderSide(color: Color(0xFF594226), width: 1),
                    //     ),
                    //     filled: true,
                    //     fillColor: Color.fromARGB(255, 255, 222, 164),
                    //     enabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(9),
                    //         borderSide: BorderSide(
                    //             color: Color(0xFF594226),
                    //             width: 1.0
                    //         )
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(9),
                    //         borderSide: BorderSide(
                    //             color: Color(0xFF594226), width: 3.0)),
                    //   ),
                    //   items: [
                    //     'Agartala',
                    //     'Agra',
                    //     'Ahmedabad',
                    //     'Aizawl',
                    //     'Ajmer',
                    //     'Aligarh',
                    //     'Allahabad',
                    //     'Amritsar',
                    //     'Aurangabad',
                    //     'Bangalore',
                    //     'Bareilly',
                    //     'Bhopal',
                    //     'Bhubaneswar',
                    //     'Bilaspur',
                    //     'Chandigarh',
                    //     'Chennai',
                    //     'Coimbatore',
                    //     'Cuttack',
                    //     'Dehradun',
                    //     'Delhi',
                    //     'Dhanbad',
                    //     'Dibrugarh',
                    //     'Durgapur',
                    //     'Faridabad',
                    //     'Gandhinagar',
                    //     'Ghaziabad',
                    //     'Gorakhpur',
                    //     'Gurgaon',
                    //     'Guwahati',
                    //     'Gwalior',
                    //     'Haridwar',
                    //     'Hisar',
                    //     'Hyderabad',
                    //     'Imphal',
                    //     'Indore',
                    //     'Jabalpur',
                    //     'Jaipur',
                    //     'Jalandhar',
                    //     'Jammu',
                    //     'Jamnagar',
                    //     'Jamshedpur',
                    //     'Jhansi',
                    //     'Jodhpur',
                    //     'Kanpur',
                    //     'Karnal',
                    //     'Kochi',
                    //     'Kohima',
                    //     'Kolkata',
                    //     'Kollam',
                    //     'Kota',
                    //     'Kozhikode',
                    //     'Kurnool',
                    //     'Ludhiana',
                    //     'Lucknow',
                    //     'Madurai',
                    //     'Mangalore',
                    //     'Meerut',
                    //     'Mumbai',
                    //     'Mysore',
                    //     'Nagpur',
                    //     'Nashik',
                    //     'Noida',
                    //     'Panaji',
                    //     'Patiala',
                    //     'Patna',
                    //     'Pondicherry',
                    //     'Pune',
                    //     'Raipur',
                    //     'Rajahmundry',
                    //     'Rajkot',
                    //     'Ranchi',
                    //     'Rourkela',
                    //     'Salem',
                    //     'Siliguri',
                    //     'Shimla',
                    //     'Srinagar',
                    //     'Surat',
                    //     'Thane',
                    //     'Thiruvananthapuram',
                    //     'Thrissur',
                    //     'Tiruchirappalli',
                    //     'Tirupati',
                    //     'Udaipur',
                    //     'Ujjain',
                    //     'Vadodara',
                    //     'Varanasi',
                    //     'Vellore',
                    //     'Vijayawada',
                    //     'Visakhapatnam',
                    //     'Warangal'
                    //   ]
                    //       .map(
                    //         (city) => DropdownMenuItem<String>(
                    //           value: city,
                    //           child: Text(city),
                    //         ),
                    //       )
                    //       .toList(),
                    //   onChanged: (value) {
                    //     selectedCity = value;
                    //   },
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please select your city';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    CustomDropdown<String>.search(
                      items: cities,
                      initialItem: selectedCity ?? 'Select City' ,
                      excludeSelected: false,
                      decoration: CustomDropdownDecoration(
                        prefixIcon: Icon(Icons.location_city_rounded),
                        closedFillColor: Color.fromARGB(255, 255, 222, 164),
                        closedBorder: Border.all(width: 1, color: Color(0xFF594226)),
                        closedBorderRadius: BorderRadius.circular(9),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your city';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    // Column(
                    //   children: [
                    //     Text("Gender : ", style: TextStyle(fontSize: 23, )),
                    //     Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Expanded(
                    //           child: RadioListTile<String>(
                    //             title: Text('Male', style: TextStyle(fontSize: 20),),
                    //             selected: true,
                    //             groupValue: gender,
                    //             value: 'Male',
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 gender = 'Male';
                    //               });
                    //             },
                    //           ),
                    //         ),
                    //         Expanded(
                    //           child: RadioListTile<String>(
                    //             title: Text('Female', style: TextStyle(fontSize: 20),),
                    //             value: 'Female',
                    //             groupValue: gender,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 gender = 'Female';
                    //               });
                    //             },
                    //           ),
                    //         )
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    FormField(
                      builder: (FormFieldState<String> state) {
                        return Column(
                          children: [
                            InputDecorator(
                              decoration: InputDecoration(
                                filled: true,
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.wc_outlined),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                        color: Color(0xFF594226), width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                        color: Color(0xFF594226), width: 3.0)),
                                fillColor: Color.fromARGB(255, 255, 222, 164),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Radio<String>(
                                    value: 'Male',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = 'Male';
                                        state.didChange(value);
                                      });
                                    },
                                  ),
                                  Text(
                                    'Male',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Radio<String>(
                                    value: 'Female',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = 'Female';
                                        state.didChange(value);
                                      });
                                    },
                                  ),
                                  Text(
                                    'Female',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    Column(
                      children: [
                        Text('Hoobies : ',
                            style: TextStyle(
                              fontSize: 23,
                            )),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  "Reading",
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: isReading,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isReading = value!;
                                    if (value == true) {
                                      hobbies.add('Reading');
                                    }
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  "Traveling",
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: isTraveling,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isTraveling = value!;
                                    if (value == true) {
                                      hobbies.add('Traveling');
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  "Gaming",
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: isGaming,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isGaming = value!;
                                    if (value == true) {
                                      hobbies.add('Gaming');
                                    }
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  "Music",
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: isMusic,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isMusic = value!;
                                    if (value == true) {
                                      hobbies.add('Music');
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      (isReading ||
                                          isMusic ||
                                          isTraveling ||
                                          isGaming)) {
                                    // widget.userObject.addUser(
                                    //     FName: fName.text,
                                    //     LName: lName.text,
                                    //     phone: phone.text,
                                    //     email: email.text,
                                    //     city: selectedCity,
                                    //     dob: dobDate,
                                    //     gender: gender,
                                    //     hobbies: hobbies);

                                    // setState(() {
                                    //   widget.userObject.addUserInTblUser(
                                    //       FName: fName.text,
                                    //       LName: lName.text,
                                    //       phone: phone.text,
                                    //       email: email.text,
                                    //       city: selectedCity,
                                    //       dob: dobDate.toString(),
                                    //       gender: gender,
                                    //       hobbies: hobbies.toString()
                                    //   );
                                    //   _formKey.currentState!.reset();
                                    //   fName.clear();
                                    //   lName.clear();
                                    //   email.clear();
                                    //   phone.clear();
                                    //   dobController.clear();
                                    //   gender = null;
                                    //   isMusic = false;
                                    //   isGaming = false;
                                    //   isTraveling = false;
                                    //   isReading = false;
                                    //   selectedCity = null;
                                    // });
                                    
                                    setState(() {
                                      api.addUser(
                                          FName: fName.text,
                                          LName: lName.text,
                                          phone: phone.text,
                                          email: email.text,
                                          city: selectedCity!,
                                          dob: dobDate.toString(),
                                          gender: gender!,
                                          hobbies: hobbies.toString()
                                      );

                                      _formKey.currentState!.reset();
                                      fName.clear();
                                      lName.clear();
                                      email.clear();
                                      phone.clear();
                                      dobController.clear();
                                      gender = null;
                                      isMusic = false;
                                      isGaming = false;
                                      isTraveling = false;
                                      isReading = false;
                                      selectedCity = null;

                                    });

                                    setState(() {

                                    });

                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewUsers(
                                            userObject: widget.userObject,
                                          ),
                                        ));

                                    toastification.show(
                                      context: context,
                                      title: Text('User Added Successfully'),
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.fillColored,
                                      autoCloseDuration: Duration(seconds: 3),
                                      showProgressBar: true,
                                      icon: Icon(Icons.check_box, color: Colors.white),
                                      primaryColor: Colors.green,
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      margin: EdgeInsets.all(16),
                                      borderRadius: BorderRadius.circular(12),
                                      closeOnClick: true,
                                    );

                                    setState(() {

                                    });

                                  } else {
                                    toastification.show(
                                      context:
                                          context, // optional if you use ToastificationWrapper
                                      title: Text('Please Fill Form Completly'),
                                      type: ToastificationType.error,
                                      icon: const Icon(Icons.error),
                                      style: ToastificationStyle.minimal,
                                      showIcon: true, // show or hide the icon
                                      primaryColor: Colors.red,
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      borderRadius: BorderRadius.circular(12),
                                      showProgressBar: true,
                                      applyBlurEffect: true,
                                      pauseOnHover: true,
                                      closeButtonShowType:
                                          CloseButtonShowType.onHover,

                                      autoCloseDuration:
                                          const Duration(seconds: 5),
                                    );
                                  }
                                },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF594226),
                                    foregroundColor:
                                        Color.fromARGB(255, 255, 222, 164),
                                    elevation: 3,
                                    fixedSize: Size.fromHeight(45)))),
                        SizedBox(
                          width: 40,
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _formKey.currentState!.reset();
                                  fName.clear();
                                  lName.clear();
                                  email.clear();
                                  phone.clear();
                                  dobController.clear();
                                  gender = null;
                                  isMusic = false;
                                  isGaming = false;
                                  isTraveling = false;
                                  isReading = false;
                                  selectedCity = null;
                                });
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF594226),
                                  foregroundColor:
                                      Color.fromARGB(255, 255, 222, 164),
                                  elevation: 3,
                                  fixedSize: Size.fromHeight(45))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
