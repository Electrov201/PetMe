import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/health_prediction_service.dart';

class HealthPredictionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HealthPredictionService _healthPredictionService;

  HealthPredictionRepository(this._healthPredictionService);

  Future<List<String>> getCommonSymptoms(String petType) async {
    // Common symptoms for both dogs and cats
    final List<String> commonSymptoms = [
      'Loss of appetite',
      'Lethargy',
      'Vomiting',
      'Diarrhea',
      'Coughing',
      'Sneezing',
      'Fever',
      'Excessive thirst',
      'Weight loss',
      'Changes in urination',
      'Bad breath',
      'Skin problems',
    ];

    // Add pet-specific symptoms
    if (petType == 'dog') {
      commonSymptoms.addAll([
        'Limping',
        'Excessive barking',
        'Changes in behavior',
        'Difficulty breathing',
      ]);
    } else if (petType == 'cat') {
      commonSymptoms.addAll([
        'Excessive meowing',
        'Hiding',
        'Litter box issues',
        'Grooming changes',
      ]);
    }

    return commonSymptoms;
  }

  Future<List<String>> getBreedSpecificSymptoms(String breed) async {
    // Breed-specific symptoms (example for some dog breeds)
    final Map<String, List<String>> breedSymptoms = {
      'german_shepherd': [
        'Hip problems',
        'Back leg weakness',
        'Ear infections',
      ],
      'bulldog': [
        'Breathing difficulties',
        'Skin fold infections',
        'Joint problems',
      ],
      'labrador': [
        'Joint pain',
        'Eye problems',
        'Obesity tendency',
      ],
      'golden_retriever': [
        'Skin allergies',
        'Joint issues',
        'Eye problems',
      ],
    };

    return breedSymptoms[breed] ?? [];
  }

  Future<Map<String, dynamic>> getPetHealthPrediction({
    required List<String> symptoms,
    required String petType,
    required int age,
    String? breed,
    List<String>? imageUrls,
  }) async {
    // Calculate base severity based on number of symptoms
    double severity = symptoms.length / 12; // Max severity of 1.0

    // Analyze symptoms and create prediction
    final prediction = _analyzePetSymptoms(symptoms, petType, age, breed);

    // Get recommendations based on prediction
    final recommendations = _getRecommendations(
      prediction,
      severity,
      petType,
      age,
      breed,
    );

    // Store prediction in Firestore
    final predictionData = {
      'petType': petType,
      'age': age,
      'breed': breed,
      'symptoms': symptoms,
      'prediction': prediction,
      'severity': severity,
      'recommendations': recommendations,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrls': imageUrls ?? [],
    };

    try {
      await _firestore.collection('health_predictions').add(predictionData);
    } catch (e) {
      print('Error storing prediction: $e');
      // Continue even if storage fails
    }

    return {
      'prediction': prediction,
      'severity': severity,
      'recommendations': recommendations,
      'imageUrls': imageUrls ?? [],
    };
  }

  String _analyzePetSymptoms(
    List<String> symptoms,
    String petType,
    int age,
    String? breed,
  ) {
    // Rule-based analysis system
    if (symptoms.isEmpty) {
      return 'No symptoms detected. Pet appears healthy.';
    }

    // Check for emergency symptoms
    final emergencySymptoms = [
      'Difficulty breathing',
      'Excessive bleeding',
      'Seizures',
      'Collapse',
      'Severe trauma',
    ];

    for (final symptom in symptoms) {
      if (emergencySymptoms.contains(symptom)) {
        return 'EMERGENCY: Immediate veterinary care required!';
      }
    }

    // Check for digestive issues
    final digestiveSymptoms = ['Vomiting', 'Diarrhea', 'Loss of appetite'];
    final hasDigestiveIssues =
        symptoms.any((symptom) => digestiveSymptoms.contains(symptom));

    // Check for respiratory issues
    final respiratorySymptoms = [
      'Coughing',
      'Sneezing',
      'Difficulty breathing'
    ];
    final hasRespiratoryIssues =
        symptoms.any((symptom) => respiratorySymptoms.contains(symptom));

    // Check for age-related issues
    final isYoung = age < 2;
    final isSenior = petType == 'dog' ? age > 7 : age > 10;

    // Generate prediction based on combinations
    if (hasDigestiveIssues && hasRespiratoryIssues) {
      return 'Multiple system involvement - veterinary examination recommended';
    } else if (hasDigestiveIssues) {
      return 'Possible digestive system issue';
    } else if (hasRespiratoryIssues) {
      return 'Possible respiratory infection or allergies';
    }

    // Age-specific predictions
    if (isYoung && symptoms.contains('Diarrhea')) {
      return 'Common in young pets - monitor and ensure hydration';
    } else if (isSenior && symptoms.contains('Lethargy')) {
      return 'May be age-related - veterinary check-up recommended';
    }

    // Breed-specific predictions
    if (breed != null) {
      if (breed == 'german_shepherd' && symptoms.contains('Hip problems')) {
        return 'Possible hip dysplasia - common in breed';
      } else if (breed == 'bulldog' &&
          symptoms.contains('Breathing difficulties')) {
        return 'Breed-specific respiratory issue - monitor closely';
      }
    }

    return 'Non-specific symptoms - monitor and consult vet if persisting';
  }

  List<String> _getRecommendations(
    String prediction,
    double severity,
    String petType,
    int age,
    String? breed,
  ) {
    final recommendations = <String>[];

    // Emergency recommendations
    if (prediction.startsWith('EMERGENCY')) {
      recommendations.addAll([
        'Seek immediate veterinary care',
        'Keep pet calm and comfortable during transport',
        'Call ahead to alert the veterinary clinic',
      ]);
      return recommendations;
    }

    // General recommendations based on severity
    if (severity < 0.3) {
      recommendations.add('Monitor your pet\'s condition for 24-48 hours');
      recommendations.add('Ensure fresh water is always available');
    } else if (severity < 0.6) {
      recommendations
          .add('Schedule a veterinary check-up within the next few days');
      recommendations.add('Monitor food and water intake');
      recommendations.add('Keep a log of symptoms and their frequency');
    } else {
      recommendations.add('Veterinary attention recommended within 24 hours');
      recommendations.add('Monitor vital signs and symptoms closely');
      recommendations.add('Prepare for possible emergency veterinary visit');
    }

    // Age-specific recommendations
    if (age < 2) {
      recommendations.add('Ensure proper vaccination schedule is maintained');
      recommendations.add('Monitor for signs of common puppy/kitten issues');
    } else if ((petType == 'dog' && age > 7) ||
        (petType == 'cat' && age > 10)) {
      recommendations.add('Consider senior pet health screening');
      recommendations.add('Monitor for age-related health changes');
    }

    // Breed-specific recommendations
    if (breed != null) {
      if (breed == 'german_shepherd') {
        recommendations.add('Monitor joint health and mobility');
      } else if (breed == 'bulldog') {
        recommendations.add('Ensure proper ventilation and avoid overheating');
      }
    }

    // Add general care recommendations
    recommendations.add('Maintain regular feeding schedule');
    recommendations.add('Ensure proper rest and minimal stress');

    return recommendations;
  }
}
