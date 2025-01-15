import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'database_service.dart';
import 'skin_disease_list.dart';
import 'status_page.dart';
import 'http.dart';
import 'skin_disease_info_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePageModel {
  CarouselController carouselController = CarouselController();
  int carouselCurrentIndex = 0;
  int selectedIndex = 0;

  DateTime currentDate;
  String skinDisease;
  // List to store carousel items, each containing an image URL and a document ID
  List<Map<String, String>> carouselItems = [];

  HomePageModel({
    required this.currentDate,
    required this.skinDisease,
  });

  Future<void> fetchData() async {
    skinDisease = '';

    // Fetch the image URLs and document IDs from the 'skinDiseases' collection
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('skinDiseases').get();

    carouselItems = snapshot.docs.map((doc) {
      String imageUrl =
          doc['imageUrl'] as String? ?? 'assets/images/placeholder.png';
      String documentId = doc.id;
      return {'imageUrl': imageUrl, 'documentId': documentId};
    }).toList();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageModel _model;
  int selectedIndex = 0;
  late DatabaseService _dbService;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _model = HomePageModel(
      currentDate: DateTime.now(),
      skinDisease: '',
    );

    _model.fetchData().then((_) {
      setState(() {
        // Ensure we're using carouselItems, not carouselImageUrls
        _model.carouselItems = _model.carouselItems.take(5).toList();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF1F4F8),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: AppBar(
            backgroundColor: Color(0xFFE6C68E),
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 23, 0, 0),
              child: Text(
                'Home Page',
                style: GoogleFonts.dmSerifDisplay(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            actions: [],
            centerTitle: false,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 8, 0, 0),
                    child: Text(
                      'Welcome',
                      style: GoogleFonts.dmSerifDisplay(
                        color: Color(0xFF14181B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Container to hold the image
                Container(
                    width: double.infinity,
                    height: 200, // Set a height for the container
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(
                              10)), // Adjust radius for desired curve
                          // If your image doesn't have a transparent background and you want a colored border:
                          color: Colors
                              .white, // Background color, match your app theme or set to transparent
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // Same radius used as above
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )),
                Container(
                  width: double.infinity,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
                    child: Text(
                      'Status of Skin Disease',
                      style: GoogleFonts.dmSerifDisplay(
                        color: Color(0xFF14181B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<Map<String, String>?>(
                  future: _dbService.retrieveLatestSkinDisease(
                      FirebaseAuth.instance.currentUser?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData ||
                        snapshot.data!['imageUrl']!.isEmpty) {
                      // If there's no data or the imageUrl is empty, use a default image
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/image.png'), // Use the default local image
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    10), // Add some space between the image and text
                            Expanded(
                              child: Text(
                                "No recent detections found.",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      var latestDetection = snapshot.data!;
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      latestDetection['imageUrl']!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 150,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Latest Detection:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    latestDetection['diseaseName']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),

                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 5, 0, 0),
                    child: Text(
                      'Categories of Skin Disease',
                      style: GoogleFonts.dmSerifDisplay(
                        color: Color(0xFF14181B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 175, // Adjust the container height as needed
                  child: CarouselSlider(
                    items: _model.carouselItems.map((item) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SkinDiseaseInfoWidget(
                                documentId: item['documentId']!,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(
                              5), // Add padding around each container
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.8), // Darker shadow color
                                  spreadRadius:
                                      5, // Increase spread radius for a larger shadow
                                  blurRadius:
                                      15, // Increase blur radius for a more prominent shadow
                                  offset: Offset(0,
                                      8), // Adjust the vertical offset of the shadow
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  8), // Container's borderRadius
                              child: Image.network(
                                item['imageUrl']!,
                                width: 175, // Set the width for square size
                                height: 175, // Set the height equal to width
                                fit: BoxFit
                                    .cover, // Cover to maintain aspect ratio within the square
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    carouselController: _model.carouselController,
                    options: CarouselOptions(
                      viewportFraction:
                          0.5, // Adjust how much of the viewport each image takes up
                      enlargeCenterPage:
                          true, // Optionally enlarge the central image
                      autoPlay:
                          false, // Set to true if you want the carousel to auto-play
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: GNav(
            rippleColor: Colors.grey[800]!, // When pressed
            hoverColor: Colors.grey[700]!,
            gap: 8,
            color: Colors.grey[800]!,
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
      ),
    );
  }
}
