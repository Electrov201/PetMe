import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../repositories/pet_repository.dart';
import '../models/pet_model.dart';
import '../repositories/organization_repository.dart';
import '../repositories/rescue_request_repository.dart';
import '../repositories/feeding_point_repository.dart';
import '../repositories/veterinary_repository.dart';
import '../repositories/donation_repository.dart';
import '../repositories/health_prediction_repository.dart';
import '../models/user_model.dart';
import '../services/pet_service.dart';
import '../services/rescue_request_service.dart';
import '../services/feeding_point_service.dart';
import '../services/veterinary_service.dart';
import '../services/donation_service.dart';
import '../services/health_prediction_service.dart';
import '../services/cloudinary_service.dart';
import '../services/organization_service.dart';
import '../models/organization_model.dart';
import '../services/places_service.dart';
import 'package:geolocator/geolocator.dart';

// Auth Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Service Providers
final petServiceProvider = Provider<PetService>((ref) => PetService());
final rescueRequestServiceProvider =
    Provider<RescueRequestService>((ref) => RescueRequestService());
final feedingPointServiceProvider =
    Provider<FeedingPointService>((ref) => FeedingPointService());
final veterinaryServiceProvider =
    Provider<VeterinaryService>((ref) => VeterinaryService());
final donationServiceProvider =
    Provider<DonationService>((ref) => DonationService());
final healthPredictionServiceProvider =
    Provider<HealthPredictionService>((ref) => HealthPredictionService());
final cloudinaryServiceProvider =
    Provider<CloudinaryService>((ref) => CloudinaryService());

// Repository Providers
final petRepositoryProvider = Provider<PetRepository>((ref) {
  final petService = ref.watch(petServiceProvider);
  return PetRepository(petService);
});

// Organization Providers
final organizationServiceProvider = Provider<OrganizationService>(
  (ref) => OrganizationService(),
);

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final organizationService = ref.watch(organizationServiceProvider);
  return OrganizationRepository(organizationService);
});

final userOrganizationsProvider =
    FutureProvider<List<OrganizationModel>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getUserOrganizations();
});

final organizationByIdProvider =
    FutureProvider.family<OrganizationModel?, String>((ref, id) async {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.getOrganizationById(id);
});

final organizationStreamProvider =
    StreamProvider.family<OrganizationModel?, String>((ref, id) {
  final repository = ref.watch(organizationRepositoryProvider);
  return repository.streamOrganization(id);
});

final placesServiceProvider = Provider<PlacesService>((ref) => PlacesService());

final userLocationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition();
});

final nearbyOrganizationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final position = await ref.watch(userLocationProvider.future);
  final placesService = ref.read(placesServiceProvider);
  return placesService.searchNearbyOrganizations(position);
});

final rescueRequestRepositoryProvider =
    Provider<RescueRequestRepository>((ref) {
  final rescueService = ref.watch(rescueRequestServiceProvider);
  return RescueRequestRepository(rescueService);
});

final feedingPointRepositoryProvider = Provider<FeedingPointRepository>((ref) {
  final feedingService = ref.watch(feedingPointServiceProvider);
  return FeedingPointRepository(feedingService);
});

final veterinaryRepositoryProvider = Provider<VeterinaryRepository>((ref) {
  final vetService = ref.watch(veterinaryServiceProvider);
  return VeterinaryRepository(vetService);
});

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  final donationService = ref.watch(donationServiceProvider);
  return DonationRepository(donationService);
});

final healthPredictionRepositoryProvider =
    Provider<HealthPredictionRepository>((ref) {
  final healthService = ref.watch(healthPredictionServiceProvider);
  return HealthPredictionRepository(healthService);
});

// UI State Providers
final loadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

// Location Provider
final currentLocationProvider = FutureProvider((ref) async {
  // TODO: Implement location service
  return null;
});

// Theme Provider
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Pets Provider
final petsProvider = FutureProvider<List<PetModel>>((ref) async {
  final petRepository = ref.watch(petRepositoryProvider);
  return petRepository.getAvailablePets();
});

final userPetsProvider =
    StreamProvider.family<List<PetModel>, String>((ref, userId) {
  final petService = ref.watch(petServiceProvider);
  return petService.streamUserPets(userId);
});

final petByIdProvider =
    FutureProvider.family<PetModel?, String>((ref, petId) async {
  final petRepository = ref.watch(petRepositoryProvider);
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) return null;
  return petRepository.getPetById(currentUser.id, petId);
});

// Stream provider for real-time pet updates
final petStreamProvider =
    StreamProvider.family<PetModel?, String>((ref, petId) {
  final petService = ref.watch(petServiceProvider);
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) return Stream.value(null);
  return petService.streamPetById(currentUser.id, petId);
});
