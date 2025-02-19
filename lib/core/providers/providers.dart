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

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
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
