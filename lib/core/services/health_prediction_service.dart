import 'package:cloud_firestore/cloud_firestore.dart';

class HealthPredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'healthPredictions';

  // Make a health prediction
  Future<Map<String, dynamic>> makeHealthPrediction({
    required String petId,
    required Map<String, dynamic> symptoms,
  }) async {
    try {
      // TODO: Integrate with ML model API
      final prediction = {
        'petId': petId,
        'symptoms': symptoms,
        'timestamp': FieldValue.serverTimestamp(),
        'prediction': 'Healthy', // Placeholder
        'confidence': 0.0, // Placeholder
      };

      final docRef = await _firestore.collection(_collection).add(prediction);

      return {'id': docRef.id, ...prediction};
    } catch (e) {
      throw Exception('Error making health prediction: $e');
    }
  }

  // Get prediction history for a pet
  Future<List<Map<String, dynamic>>> getPredictionHistory(String petId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('petId', isEqualTo: petId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error fetching prediction history: $e');
    }
  }

  // Get prediction details
  Future<Map<String, dynamic>?> getPredictionDetails(
    String predictionId,
  ) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(predictionId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Error fetching prediction details: $e');
    }
  }

  Future<Map<String, dynamic>> predictHealth({
    required List<String> symptoms,
    required String petType,
    required int age,
    String? breed,
  }) async {
    try {
      // Simple rule-based prediction system
      final prediction = _analyzePetSymptoms(symptoms, petType, age, breed);
      final recommendations = _getRecommendations(prediction);
      final severity = _calculateSeverity(symptoms, prediction);

      final predictionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'symptoms': symptoms,
        'petType': petType,
        'age': age,
        'breed': breed,
        'prediction': prediction,
        'severity': severity,
        'recommendations': recommendations,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Store prediction in Firestore
      await _firestore.collection(_collection).add(predictionData);

      return {
        'prediction': prediction,
        'severity': severity,
        'recommendations': recommendations,
      };
    } catch (e) {
      throw Exception('Failed to predict health: $e');
    }
  }

  String _analyzePetSymptoms(
      List<String> symptoms, String petType, int age, String? breed) {
    // Common conditions for both cats and dogs
    if (symptoms.contains('vomiting') && symptoms.contains('diarrhea')) {
      return 'Gastroenteritis';
    }
    if (symptoms.contains('coughing') && symptoms.contains('sneezing')) {
      return 'Upper Respiratory Infection';
    }
    if (symptoms.contains('lethargy') &&
        symptoms.contains('loss of appetite')) {
      return 'General Illness';
    }
    if (symptoms.contains('excessive thirst') &&
        symptoms.contains('frequent urination')) {
      return 'Possible Diabetes or Kidney Issue';
    }

    // Dog-specific conditions
    if (petType.toLowerCase() == 'dog') {
      if (symptoms.contains('limping') && age > 7) {
        return 'Possible Arthritis';
      }
      if (symptoms.contains('scratching') && symptoms.contains('red skin')) {
        return 'Skin Allergy';
      }
    }

    // Cat-specific conditions
    if (petType.toLowerCase() == 'cat') {
      if (symptoms.contains('urinating outside litter box')) {
        return 'Possible Urinary Tract Issue';
      }
      if (symptoms.contains('excessive grooming')) {
        return 'Possible Anxiety or Skin Issue';
      }
    }

    return 'Inconclusive - Please consult a veterinarian';
  }

  double _calculateSeverity(List<String> symptoms, String prediction) {
    double severity = 0.0;

    // Base severity on number of symptoms
    severity += symptoms.length * 0.1;

    // Increase severity for certain symptoms
    if (symptoms.contains('difficulty breathing')) severity += 0.5;
    if (symptoms.contains('severe pain')) severity += 0.4;
    if (symptoms.contains('collapse')) severity += 0.5;
    if (symptoms.contains('bleeding')) severity += 0.3;

    // Adjust based on prediction
    switch (prediction) {
      case 'Possible Diabetes or Kidney Issue':
      case 'Upper Respiratory Infection':
        severity += 0.3;
        break;
      case 'Gastroenteritis':
        severity += 0.2;
        break;
    }

    // Cap severity at 1.0
    return severity.clamp(0.0, 1.0);
  }

  List<String> _getRecommendations(String prediction) {
    final recommendations = <String>[];

    switch (prediction.toLowerCase()) {
      case 'gastroenteritis':
        recommendations.addAll([
          'Temporarily withhold food for 12-24 hours',
          'Provide small amounts of water frequently',
          'Gradually reintroduce bland food',
          'Monitor stool consistency',
          'Consult vet if symptoms persist more than 24 hours',
        ]);
        break;

      case 'upper respiratory infection':
        recommendations.addAll([
          'Keep pet warm and comfortable',
          'Clean nose and eyes with warm damp cloth',
          'Use humidifier if available',
          'Ensure good ventilation',
          'Seek veterinary care if breathing becomes difficult',
        ]);
        break;

      case 'possible diabetes or kidney issue':
        recommendations.addAll([
          'Immediate veterinary consultation recommended',
          'Monitor water intake and urination',
          'Keep track of food intake',
          'Watch for changes in energy level',
        ]);
        break;

      case 'skin allergy':
        recommendations.addAll([
          'Prevent scratching if possible',
          'Keep affected areas clean and dry',
          'Consider hypoallergenic diet',
          'Monitor for spreading or worsening',
        ]);
        break;

      default:
        recommendations.addAll([
          'Monitor your pet closely',
          'Keep pet comfortable and warm',
          'Ensure access to fresh water',
          'Contact veterinarian if condition worsens',
          'Keep track of all symptoms and their duration',
        ]);
    }

    // Add emergency warning if needed
    if (prediction == 'Inconclusive - Please consult a veterinarian') {
      recommendations.insert(
          0, 'Veterinary consultation recommended for proper diagnosis');
    }

    return recommendations;
  }
}
