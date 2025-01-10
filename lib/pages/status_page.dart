import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_model_flask_app/pages/database_service.dart';
import 'package:skin_disease_model_flask_app/pages/skin_disease_list.dart';
import 'http.dart';
import 'package:skin_disease_model_flask_app/pages/home_page.dart';
import 'package:skin_disease_model_flask_app/pages/login_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  int selectedIndex = 3;

  final DatabaseService _dbService = DatabaseService();
  late Future<List<DiseaseData>> _detectionData;

  @override
  void initState() {
    super.initState();
    _detectionData = _retrieveDetections();
  }

  _StatusPageState() {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Future<List<DiseaseData>> _retrieveDetections() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      return await _dbService.retrieveSkinDiseaseDetections();
    }
    return []; // Return an empty list if there is no user
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.brown,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: Align(
        alignment: AlignmentDirectional(0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 140,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.brown,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/images/design.jpg',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the page where the user can change their profile picture
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Add a SizedBox for spacing
            Expanded(
              child: Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x33000000),
                      offset: Offset(0, -1),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.week,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay =
                                focusedDay; // Update _focusedDay as well if you want to change the focused day
                          });
                        },
                        onPageChanged: (focusedDay) {
                          // Update _focusedDay here to change which day is currently visible in the calendar
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                      FutureBuilder<List<DiseaseData>>(
                        future: _detectionData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text(' ');
                          }
                          List<DiseaseData> detections = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: detections.length,
                            itemBuilder: (context, index) {
                              DiseaseData data = detections[index];
                              return Card(
                                margin: EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          data.imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Disease: ${data.prediction}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                                height:
                                                    5), // Spacer between lines
                                            Text(
                                              'Date: ${DateFormat('yyyy-MM-dd').format(data.date)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.brown,
        margin: EdgeInsets.only(bottom: 5),
        child: GNav(
          rippleColor: Colors.grey[800]!, // When pressed
          hoverColor: Colors.grey[700]!,
          gap: 8,
          color: Colors.white,
          activeColor: Colors.white,
          iconSize: 24,
          tabBackgroundColor: Color(0xFFE6C68E),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          duration: Duration(milliseconds: 700),
          tabs: [
            GButton(
              icon: LineIcons.home,
              text: 'Home',
            ),
            GButton(
              icon: LineIcons.search,
              text: 'Detect',
            ),
            GButton(
              icon: LineIcons.book,
              text: 'Library',
            ),
            GButton(
              icon: LineIcons.user,
              text: 'Status',
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: (index) {
            setState(() {
              selectedIndex = index;
            });

            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetectPage()),
              );
            }

            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SkinDiseaseListWidget()),
              );
            }

            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatusPage()),
              );
            }
          },
        ),
      ),
    );
  }
}
