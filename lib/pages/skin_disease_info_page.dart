import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'skin_disease_list.dart';

class SkinDiseaseInfoWidget extends StatefulWidget {
  final String documentId;

  const SkinDiseaseInfoWidget({Key? key, required this.documentId})
      : super(key: key);

  @override
  State<SkinDiseaseInfoWidget> createState() => _SkinDiseaseInfo();
}

class _SkinDiseaseInfo extends State<SkinDiseaseInfoWidget> {
  late Future<DocumentSnapshot> skinDiseaseFuture;
  bool isDescriptionExpanded = false;
  bool isSymptomsExpanded = false;
  bool isTreatmentExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize the future here and use it in the FutureBuilder
    skinDiseaseFuture = FirebaseFirestore.instance
        .collection('skinDiseases')
        .doc(widget.documentId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBCA93),
      appBar: AppBar(
        backgroundColor: Color(0xFFEBCA93),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 30),
          onPressed: () {
            // Pop until the root (first page in the stack) is reached and then push the SkinDiseaseListWidget page
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SkinDiseaseListWidget()),
            );
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Skin Disease Info', // The title text
          style: GoogleFonts.dmSerifDisplay(
            // Using Google Fonts for styling
            color: Colors.white, // Title color
            fontSize: 21, // Title font size
            fontWeight: FontWeight.w600, // Title font weight
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: skinDiseaseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          // Print statements for debugging
          print("Document ID: ${widget.documentId}");
          print("Fetched Data: $data");

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['imageUrl'], // Fallback image if no imageUrl
                        width: double.infinity,
                        height: 230,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  expandableSection(
                    title: 'Description',
                    isExpanded: isDescriptionExpanded,
                    onTap: () => setState(
                        () => isDescriptionExpanded = !isDescriptionExpanded),
                    contentList: List<String>.from(
                        data['description'] ?? ['No description available']),
                  ),
                  const Divider(thickness: 1, color: Colors.transparent),
                  expandableSection(
                    title: 'Symptoms',
                    isExpanded: isSymptomsExpanded,
                    onTap: () => setState(
                        () => isSymptomsExpanded = !isSymptomsExpanded),
                    contentList: List<String>.from(
                        data['symptoms'] ?? ['No symptoms available']),
                  ),
                  const Divider(thickness: 1, color: Colors.transparent),
                  expandableSection(
                    title: 'Treatment',
                    isExpanded: isTreatmentExpanded,
                    onTap: () => setState(
                        () => isTreatmentExpanded = !isTreatmentExpanded),
                    contentList: List<String>.from(
                        data['treatment'] ?? ['No treatment available']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget expandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<dynamic> contentList, // Expect a list for the content
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  blurRadius: 3,
                  color: Color(0x33000000),
                  offset: Offset(0, 1)),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: contentList
                          .map((item) => Text('• ${item.toString()}'))
                          .toList(), // Create a list of Text widgets
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
