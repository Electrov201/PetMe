import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import '../models/pet_model.dart';
import '../services/pet_service.dart';

class PetRepository {
  final PetService _petService;

  PetRepository(this._petService);

  Future<List<PetModel>> getAvailablePets() async {
    return _petService.getAvailablePets();
  }

  Future<PetModel?> getPetById(String userId, String petId) async {
    return _petService.getPetById(userId, petId);
  }

  Stream<List<PetModel>> streamUserPets(String userId) {
    return _petService.streamUserPets(userId);
  }

  Future<void> addPet(PetModel pet) async {
    return _petService.addPet(pet);
  }

  Future<void> updatePet(PetModel pet) async {
    return _petService.updatePet(pet);
  }

  Future<void> deletePet(String petId) async {
    return _petService.deletePet(petId);
  }

  Future<List<PetModel>> getNearbyPets(
    double lat,
    double lng,
    double radiusInKm,
  ) async {
    final allPets = await _petService.getAvailablePets();
    return allPets.where((pet) {
      final distance = _calculateDistance(
        lat,
        lng,
        pet.latitude,
        pet.longitude,
      );
      return distance <= radiusInKm;
    }).toList();
  }

  /// Calculates the great-circle distance between two points on Earth
  /// using the Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
