import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'skin_disease_info_page.dart';
import 'http.dart';
import 'home_page.dart';
import 'status_page.dart';
import 'database_service.dart';

class SkinDiseaseListWidget extends StatefulWidget {
  const SkinDiseaseListWidget({Key? key}) : super(key: key);

  @override
  State<SkinDiseaseListWidget> createState() => _SkinDiseaseListWidgetState();
}

class _SkinDiseaseListWidgetState extends State<SkinDiseaseListWidget> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  int selectedIndex = 2;
  List<Map<String, dynamic>> _allDiseases = [];
  List<Map<String, dynamic>> _filteredDiseases = [];

  @override
  void initState() {
    super.initState();
    _loadDiseases();
    searchController.addListener(_filterDiseases);
  }

  void _loadDiseases() async {
    var diseases = await DatabaseService().getSkinDiseaseNames();
    setState(() {
      _allDiseases = diseases;
      _filteredDiseases = diseases;
    });
  }

  void _filterDiseases() {
    String query = searchController.text.toLowerCase();
    setState(() {
      _filteredDiseases = _allDiseases.where((disease) {
        return disease['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xFFE6C68E),
            padding: EdgeInsetsDirectional.fromSTEB(16, 60, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skin Disease Library',
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Deep dive into the details of different skin disease',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: TextFormField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Search for skin disease...',
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black12, width: 2),
                          borderRadius: BorderRadius.circular(40)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black26, width: 2),
                          borderRadius: BorderRadius.circular(40)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(24, 24, 0, 24),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDiseases.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> disease = _filteredDiseases[index];
                String diseaseName = disease['name'];
                String documentId = disease['documentId'];

                return Padding(
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkinDiseaseInfoWidget(
                            documentId: documentId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 3,
                              color: Color(0x29000000),
                              offset: Offset(0, 1))
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          diseaseName,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: GNav(
          rippleColor: Colors.grey[800]!,
          hoverColor: Colors.grey[700]!,
          gap: 8,
          backgroundColor: Colors.white,
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
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            } else if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DetectPage()));
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SkinDiseaseListWidget()));
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StatusPage()));
            }
          },
        ),
      ),
    );
  }
}
