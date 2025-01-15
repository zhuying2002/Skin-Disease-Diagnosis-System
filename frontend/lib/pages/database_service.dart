import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DiseaseData {
  final DateTime date;
  final String imageUrl;
  final String prediction;

  DiseaseData({
    required this.date,
    required this.imageUrl,
    required this.prediction,
  });
}

class SkinDisease {
  String name;
  List<String> description;
  List<String> symptoms;
  List<String> treatment;
  String imageUrl; // Declare the imageUrl field

  SkinDisease({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.imageUrl,
  });
}

class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  // Function to add a new skin condition detection
  Future<DocumentReference<Object?>> addSkinDiseaseDetection({
    required String userId,
    required String type,
    required String imageUrl,
    required String prediction,
    required DateTime date, // Changed from 'time' to 'date'
  }) async {
    CollectionReference detections =
        firestore.collection('users').doc(userId).collection('detections');

    // Add additional fields 'prediction' and 'confidence', and use 'date' instead of 'time'
    return await detections.add({
      'type': type,
      'imageUrl': imageUrl,
      'prediction': prediction,
      'date': date, // Firestore can store DateTime objects directly
    });
  }

  Future<String> uploadImageToStorage(File imageFile, String userId) async {
    String filePath =
        'uploads/$userId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    firebase_storage.Reference ref = _storage.ref().child(filePath);

    try {
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on firebase_storage.FirebaseException catch (e) {
      // Here you can handle the specific errors such as quota exceeded, network issue etc.
      print('Error during image upload: $e');
      throw e;
    }
  }

  late Future<DiseaseData?> latestDetection;
  // Function to retrieve user's skin condition detections from Firestore
  Future<List<DiseaseData>> retrieveSkinDiseaseDetections() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      QuerySnapshot detectionSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('detections')
          .get();

      List<DiseaseData> detections = detectionSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DateTime? detectionDate;
        Timestamp? timestamp = data['time'] as Timestamp?;
        if (timestamp != null) {
          detectionDate = timestamp.toDate();
        }

        String imageUrl = data['imageUrl'] as String? ??
            ''; // Provide a default or handle null appropriately
        String prediction = data['prediction'] as String? ??
            'Unknown'; // Retrieve the prediction or provide a default value

        return DiseaseData(
            date: detectionDate ?? DateTime.now(),
            imageUrl: imageUrl,
            prediction: prediction);
      }).toList();

      return detections;
    }
    return []; // Return an empty list if there is no user
  }

//
  Future<Map<String, String>?> retrieveLatestSkinDisease(String userId) async {
    try {
      QuerySnapshot detectionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('detections')
          .orderBy('date',
              descending: true) // Sorting by date in descending order
          .limit(1) // Limiting to only the most recent detection
          .get();

      if (detectionSnapshot.docs.isNotEmpty) {
        DocumentSnapshot latestDetectionDoc = detectionSnapshot.docs.first;
        Map<String, dynamic> data =
            latestDetectionDoc.data() as Map<String, dynamic>;

        String diseaseName = data['prediction'] ??
            'No skin disease detected'; // 'prediction' holds the disease name
        String imageUrl = data['imageUrl'] ??
            'assets/images/image.png'; //'imageUrl' holds the link to the image

        return {
          'diseaseName': diseaseName,
          'imageUrl': imageUrl,
        };
      }
    } catch (e) {
      print("Error fetching latest skin disease and image: $e");
    }
    return null; // Return null if there's no detection or in case of an error
  }

  Future<List<Map<String, dynamic>>> getSkinDiseaseNames() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('skinDiseases').get();
      List<Map<String, dynamic>> diseaseNames = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['name'] as String?,
              'documentId': doc.id,
            };
          })
          .where((disease) =>
              disease['name'] != null) // Filter out documents without a name
          .toList();

      return diseaseNames;
    } catch (e) {
      print('Error fetching skin disease names: $e');
      throw e;
    }
  }

  Future<SkinDisease> getSkinDisease(String documentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firestore.collection('skinDiseases').doc(documentId).get();

      if (!documentSnapshot.exists) {
        throw Exception('Document not found');
      }

      Map<String, dynamic> data = documentSnapshot.data() ?? {};

      return SkinDisease(
        name: data['name'] ?? 'Unknown',
        description: data['description'] is List
            ? List<String>.from(data['description'])
            : ['No description available'],
        symptoms: data['symptoms'] is List
            ? List<String>.from(data['symptoms'])
            : ['No symptoms available'],
        treatment: data['treatment'] is List
            ? List<String>.from(data['treatment'])
            : ['No treatment available'],
        imageUrl: data['imageUrl'] as String? ?? 'default_image_url_here',
      );
    } catch (e) {
      print('Error fetching skin disease: $e');
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getSkinDiseaseImages() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('skinDiseases').get();
      List<Map<String, String>> images = querySnapshot.docs.map((doc) {
        String imageUrl =
            (doc.data() as Map<String, dynamic>)['imageUrl'] as String? ??
                'assets/images/image.png';
        String documentId = doc.id;
        return {'imageUrl': imageUrl, 'documentId': documentId};
      }).toList();

      return images;
    } catch (e) {
      print('Error fetching skin disease images: $e');
      throw e;
    }
  }
}
