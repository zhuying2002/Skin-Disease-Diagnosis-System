import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:skin_disease_model_flask_app/pages/skin_disease_list.dart';
import 'package:skin_disease_model_flask_app/pages/status_page.dart';
import 'home_page.dart';
import 'database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetectPage extends StatefulWidget {
  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  int selectedIndex = 1;
  File? _file;
  String predictionText = ''; // State variable to hold prediction result
  String treatmentText = '';
  final DatabaseService dbService = DatabaseService();

  Future<void> UploadImage() async {
    final myfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _file = File(myfile!.path);
    });
  }

  Future<void> deleteImage() async {
    setState(() {
      _file = null; // Clears the selected image
      predictionText = ''; // Also clear the prediction text
    });
  }

  Future<void> Predict() async {
    if (_file == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Image Selected"),
            content:
                Text("Please upload an image to proceed with the prediction."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    String imageUrl = await dbService.uploadImageToStorage(
        _file!, FirebaseAuth.instance.currentUser!.uid);

    var request = http.MultipartRequest(
        'POST', Uri.parse("http://172.20.10.6:5000/image/upload"));
    request.files.add(await http.MultipartFile.fromPath('photo', _file!.path));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('prediction')) {
          // Prediction was successful
          await dbService.addSkinDiseaseDetection(
            userId: FirebaseAuth.instance.currentUser!.uid,
            type: jsonResponse['prediction'],
            imageUrl: imageUrl,
            prediction: jsonResponse['prediction'],
            date: DateTime.now(),
          );

          setState(() {
            predictionText = 'Prediction: ${jsonResponse['prediction']}';
          });

          // Retrieve treatment information and show modal
          String treatment =
              await getTreatmentInformation(jsonResponse['prediction']);
          showTreatmentModal(context, treatment);
        } else if (jsonResponse.containsKey('message')) {
          // Handle cases where a message is returned instead of a prediction
          setState(() {
            predictionText = jsonResponse['message'];
          });
          // Optionally, show a dialog with the message or update the UI accordingly
        }
      } else {
        // Handle the case of a non-200 status code
        print('Error: ${response.reasonPhrase}');
        setState(() {
          predictionText = 'Error: ${response.reasonPhrase}';
        });
        // Optionally, show a dialog with the error message or update the UI accordingly
      }
    } catch (e) {
      // Exception occurred during request sending or response handling
      print('Exception occurred: $e');
      setState(() {
        predictionText = 'Exception occurred: $e';
      });
      // Optionally, show a dialog with the exception message or update the UI accordingly
    }
  }

  Future<String> getTreatmentInformation(String diseasePrediction) async {
    var treatmentsCollection =
        FirebaseFirestore.instance.collection('skinDiseases');
    try {
      var documentSnapshot =
          await treatmentsCollection.doc(diseasePrediction).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data()!['treatment'] ??
            'No treatment information available for this disease.';
      } else {
        return 'No treatment information available for this disease.';
      }
    } catch (e) {
      print('Error retrieving treatment information: $e');
      return 'Error retrieving treatment information.';
    }
  }

  void showTreatmentModal(BuildContext context, String treatment) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Wrap(
            children: <Widget>[
              Text('Treatment Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(treatment, style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          'Skin Disease Detection Page',
          style: GoogleFonts.dmSerifDisplay(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 65,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_file != null)
              Image.file(_file!), // Display the selected/uploaded image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.file_upload),
                  onPressed: UploadImage,
                ),
                IconButton(
                  icon: Icon(Icons.analytics),
                  onPressed: Predict,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: deleteImage,
                ),
              ],
            ),
            // Display the prediction result in a styled container
            if (predictionText.isNotEmpty)
              Container(
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(predictionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
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
