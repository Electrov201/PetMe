import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petme/core/services/cloudinary_service.dart';
import 'package:petme/core/repositories/organization_repository.dart';
import 'package:petme/core/services/organization_service.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

final organizationServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final organizationService = ref.watch(organizationServiceProvider);
  return OrganizationRepository(organizationService);
});
