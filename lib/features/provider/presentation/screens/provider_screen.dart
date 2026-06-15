import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/provider_model.dart';
import '../providers/provider_provider.dart';
import '../providers/provider_state.dart';

import '../../../service/data/models/service_model.dart';
import 'package:geolocator/geolocator.dart';

class ProvidersScreen extends ConsumerStatefulWidget {
  final ServiceModel service;

  const ProvidersScreen({super.key, required this.service});

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

String? getServiceHeaderImage(String title) {
  final t = title.toLowerCase();

  if (t.contains('electric')) {
    return 'assets/images/electrician1.jpg';
  }

  if (t.contains('plumb')) {
    return 'assets/images/plumber1.jpeg';
  }

  if (t.contains('paint')) {
    return 'assets/images/painter1.jpeg';
  }

  if (t.contains('clean')) {
    return 'assets/images/cleaning1.jpeg';
  }

  if (t.contains('carpent')) {
    return 'assets/images/carpenter1.jpeg';
  }

  return null;
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  String searchQuery = '';
  String selectedCity = 'All';
  double? userLatitude;
  double? userLongitude;

  @override
  void initState() {
    super.initState();
    loadUserLocation();
    Future.microtask(() {
      ref
          .read(providerProvider.notifier)
          .getProvidersByService(widget.service.id);
    });
  }

  Future<void> loadUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Builder(
        builder: (context) {
          if (state is ProviderLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            );
          }

          if (state is ProviderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ProviderLoaded) {
            final filteredProviders = state.providers.where((provider) {
              final matchesSearch = provider.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
              final matchesCity =
                  selectedCity == 'All' || provider.city == selectedCity;
              return matchesSearch && matchesCity;
            }).toList();

            if (userLatitude != null && userLongitude != null) {
              filteredProviders.sort((a, b) {
                final distanceA = Geolocator.distanceBetween(
                  userLatitude!,
                  userLongitude!,
                  a.latitude,
                  a.longitude,
                );
                final distanceB = Geolocator.distanceBetween(
                  userLatitude!,
                  userLongitude!,
                  b.latitude,
                  b.longitude,
                );
                return distanceA.compareTo(distanceB);
              });
            }

            final cities = [
              'All',
              ...state.providers.map((e) => e.city).toSet(),
            ];

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 230,
                  pinned: true,
                  backgroundColor: const Color(0xFF0F766E),
                  elevation: 0,
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
                    background: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            getServiceHeaderImage(widget.service.title)!,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),

                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),

                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Service Providers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.home_repair_service_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.service.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.service.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${state.providers.length} providers available',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      children: [
                        // Search Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search providers...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 15,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF0F766E),
                                  size: 18,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // City Filter Chips
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cities.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final city = cities[index];
                              final isSelected = selectedCity == city;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => selectedCity = city),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0F766E)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(
                                                0xFF0F766E,
                                              ).withOpacity(0.3)
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    city,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Results count
                        Row(
                          children: [
                            Text(
                              '${filteredProviders.length} results',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (userLatitude != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.my_location_rounded,
                                      size: 11,
                                      color: Color(0xFF0F766E),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Sorted by distance',
                                      style: TextStyle(
                                        color: Color(0xFF0F766E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (state.providers.isEmpty || filteredProviders.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              color: Color(0xFF0F766E),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No providers found',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ProviderModel provider = filteredProviders[index];

                        double? distanceKm;
                        if (userLatitude != null && userLongitude != null) {
                          distanceKm =
                              Geolocator.distanceBetween(
                                userLatitude!,
                                userLongitude!,
                                provider.latitude,
                                provider.longitude,
                              ) /
                              1000;
                        }

                        return _ProviderCard(
                          provider: provider,
                          distanceKm: distanceKm,
                          serviceName: widget.service.title,
                          onTap: () => context.push(
                            '/provider-details',
                            extra: provider,
                          ),
                        );
                      }, childCount: filteredProviders.length),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final double? distanceKm;
  final String serviceName;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.distanceKm,
    required this.serviceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    provider.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Arrow
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF0F766E),
                            size: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Service name badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        serviceName,
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      provider.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Meta row: city + distance
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.city,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (distanceKm != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.near_me_rounded,
                            size: 14,
                            color: Color(0xFF14B8A6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
