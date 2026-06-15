import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/provider_model.dart';
import '../../../review/presentation/screens/provider_reviews_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/provider_image_model.dart';
import '../providers/provider_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../review/data/datasources/review_remote_data_source.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';

class ProviderDetailsScreen extends ConsumerStatefulWidget {
  final ProviderModel provider;

  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  ConsumerState<ProviderDetailsScreen> createState() =>
      _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends ConsumerState<ProviderDetailsScreen> {
  double? distanceKm;
  double averageRating = 0;
  int reviewsCount = 0;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    calculateDistance();
    loadReviewsData();
    loadFavoriteStatus();
  }

  Future<void> calculateDistance() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.provider.latitude,
        widget.provider.longitude,
      );
      setState(() => distanceKm = distanceInMeters / 1000);
    } catch (_) {}
  }

  Future<void> loadReviewsData() async {
    try {
      final dataSource = ReviewRemoteDataSource();
      final averageResponse = await dataSource.getAverageRating(
        widget.provider.id,
      );
      final reviewsResponse = await dataSource.getProviderReviews(
        widget.provider.id,
      );
      setState(() {
        averageRating = (averageResponse.data as num).toDouble();
        reviewsCount = (reviewsResponse.data as List).length;
      });
    } catch (_) {}
  }

  Future<void> loadFavoriteStatus() async {
    try {
      final result = await ref
          .read(favoriteProvider.notifier)
          .isFavorite(widget.provider.id);

      if (mounted) {
        setState(() {
          isFavorite = result;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 290,
                pinned: true,
                backgroundColor: const Color(0xFF0F766E),
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () async {
                      if (isFavorite) {
                        await ref
                            .read(favoriteProvider.notifier)
                            .removeFavorite(widget.provider.id);

                        setState(() {
                          isFavorite = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from Favorites'),
                          ),
                        );
                      } else {
                        await ref
                            .read(favoriteProvider.notifier)
                            .addFavorite(widget.provider.id);

                        setState(() {
                          isFavorite = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Favorites ❤️'),
                            ),
                          );
                        });
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                ],
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover gradient
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                      // Decorative circles
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),

                      // Provider info
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    widget.provider.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Name
                              Text(
                                widget.provider.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Service badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.provider.serviceName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Rating + Distance
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${averageRating.toStringAsFixed(1)} ($reviewsCount reviews)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (distanceKm != null) ...[
                                    const SizedBox(width: 14),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.white54,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(
                                      Icons.near_me_rounded,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${distanceKm!.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              icon: Icons.star_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              iconBg: const Color(0xFFFEF3C7),
                              label: 'Rating',
                              value: averageRating.toStringAsFixed(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.rate_review_outlined,
                              iconColor: const Color(0xFF6366F1),
                              iconBg: const Color(0xFFE0E7FF),
                              label: 'Reviews',
                              value: '$reviewsCount',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.location_on_rounded,
                              iconColor: const Color(0xFF0F766E),
                              iconBg: const Color(0xFFCCFBF1),
                              label: 'City',
                              value: widget.provider.city,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('Provider Info'),
                      const SizedBox(height: 14),

                      _infoCard(
                        icon: Icons.home_repair_service_rounded,
                        iconColor: const Color(0xFF0F766E),
                        iconBg: const Color(0xFFCCFBF1),
                        label: 'Service',
                        value: widget.provider.serviceName,
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFF10B981),
                        iconBg: const Color(0xFFD1FAE5),
                        label: 'City',
                        value: widget.provider.city,
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.phone_rounded,
                        iconColor: const Color(0xFF6366F1),
                        iconBg: const Color(0xFFE0E7FF),
                        label: 'Phone',
                        value: widget.provider.phone,
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('About Provider'),
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.provider.description.isEmpty
                              ? 'No description available.'
                              : widget.provider.description,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            height: 1.65,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('Work Gallery'),
                      const SizedBox(height: 14),

                      FutureBuilder<List<ProviderImageModel>>(
                        future: ref
                            .read(providerProvider.notifier)
                            .getProviderImages(widget.provider.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0F766E),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    color: Color(0xFF94A3B8),
                                    size: 40,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No work images available',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final images = snapshot.data!;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: images.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    'http://10.0.2.2:8080${images[index].imageUrl}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderReviewsScreen(
                                providerId: widget.provider.id,
                                providerName: widget.provider.name,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF0F766E),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F766E,
                                ).withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFF0F766E),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Customer Reviews',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$reviewsCount reviews • ${averageRating.toStringAsFixed(1)} avg',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xFF0F766E),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  context.push('/create-request', extra: widget.provider);
                },
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Request Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
