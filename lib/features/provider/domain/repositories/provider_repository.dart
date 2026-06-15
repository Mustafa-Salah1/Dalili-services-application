import '../../data/models/provider_image_model.dart';
import '../../data/models/provider_model.dart';

abstract class ProviderRepository {
  Future<List<ProviderModel>> getProvidersByService(int serviceId);

  Future<ProviderModel> getMyProvider();

  Future<List<ProviderModel>> getAllProviders();

  Future<ProviderModel> uploadCoverImage({
    required int providerId,
    required String imagePath,
  });

  Future<ProviderImageModel> uploadGalleryImage({
    required int providerId,
    required String imagePath,
  });

  Future<ProviderModel> getProviderById(int providerId);
  
  Future<List<ProviderImageModel>> getProviderImages(int providerId);

  Future<ProviderModel> updateMyProvider({
    required String name,
    required String phone,
    required String description,
    required String city,
    required int serviceId,
    required double latitude,
    required double longitude,
  });
}
