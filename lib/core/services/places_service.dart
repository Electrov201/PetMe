import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class PlacesService {
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> getNearbyOrganizations(
    Position position,
    String type, {
    double radius = 5000,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=$radius&type=$type&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          throw Exception('Failed to get nearby places: ${data['status']}');
        }
      } else {
        throw Exception('Failed to get nearby places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get nearby places: $e');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/details/json?place_id=$placeId&fields=name,rating,formatted_address,formatted_phone_number,website,opening_hours,photos,reviews&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        } else {
          throw Exception('Failed to get place details: ${data['status']}');
        }
      } else {
        throw Exception('Failed to get place details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get place details: $e');
    }
  }

  Future<String> getPlacePhoto(String photoReference,
      {int maxWidth = 400}) async {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  Future<List<Map<String, dynamic>>> searchNearbyOrganizations(
    Position position, {
    double radius = 5000,
  }) async {
    List<Map<String, dynamic>> allPlaces = [];

    // Search for different types of places
    final types = [
      'veterinary_care',
      'pet_store',
      'zoo',
      'animal_shelter',
    ];

    // Also search for keywords related to animal welfare
    final keywords = [
      'animal rescue',
      'pet shelter',
      'animal ngo',
      'animal welfare',
    ];

    // Get places by type
    for (final type in types) {
      try {
        final places = await getNearbyOrganizations(position, type);
        allPlaces.addAll(places);
      } catch (e) {
        print('Error fetching $type: $e');
      }
    }

    // Get places by keyword
    for (final keyword in keywords) {
      try {
        final response = await http.get(
          Uri.parse(
            '$_baseUrl/textsearch/json?query=$keyword&location=${position.latitude},${position.longitude}&radius=$radius&key=$_apiKey',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            allPlaces.addAll(List<Map<String, dynamic>>.from(data['results']));
          }
        }
      } catch (e) {
        print('Error fetching $keyword: $e');
      }
    }

    // Remove duplicates based on place_id
    final uniquePlaces = <String, Map<String, dynamic>>{};
    for (var place in allPlaces) {
      if (place['place_id'] != null &&
          !uniquePlaces.containsKey(place['place_id'])) {
        uniquePlaces[place['place_id']] = place;
      }
    }

    return uniquePlaces.values.toList();
  }
}
