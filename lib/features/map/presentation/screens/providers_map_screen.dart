import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../provider/data/models/provider_model.dart';
import '../../../provider/presentation/providers/provider_provider.dart';

class ProvidersMapScreen extends ConsumerStatefulWidget {
  const ProvidersMapScreen({super.key});

  @override
  ConsumerState<ProvidersMapScreen> createState() => _ProvidersMapScreenState();
}

class _ProvidersMapScreenState extends ConsumerState<ProvidersMapScreen> {
  final MapController mapController = MapController();

  List<ProviderModel> providers = [];
  LatLng? userLocation;
  bool isLoading = true;
  ProviderModel? selectedProvider;

  @override
  void initState() {
    super.initState();
    loadProviders();
    moveToUserLocation();
  }

  Future<void> moveToUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        mapController.move(LatLng(position.latitude, position.longitude), 13);
      });
    } catch (_) {}
  }

  Future<void> loadProviders() async {
    try {
      final result = await ref
          .read(providerProvider.notifier)
          .getAllProviders();
      setState(() {
        providers = result;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  double? _distanceKm(ProviderModel provider) {
    if (userLocation == null) return null;
    return Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          provider.latitude,
          provider.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            flex: 40,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(32.2211, 35.2544),
                    initialZoom: 11,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.mustafa.servicefinder',
                    ),

                    // User location marker — unchanged
                    if (userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: userLocation!,
                            width: 80,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF0F766E,
                                ).withOpacity(0.15),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Color(0xFF0F766E),
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Provider markers — unchanged logic, improved icon
                    MarkerLayer(
                      markers: providers.map((provider) {
                        final isSelected = selectedProvider?.id == provider.id;
                        return Marker(
                          point: LatLng(provider.latitude, provider.longitude),
                          width: 56,
                          height: 56,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedProvider = provider);
                              context.push(
                                '/provider-details',
                                extra: provider,
                              );
                            },
                            child: Tooltip(
                              message: provider.name,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0F766E)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0F766E),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0F766E,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.handyman_rounded,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0F766E),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                Positioned(
                  bottom: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: () {
                      if (userLocation != null) {
                        mapController.move(userLocation!, 14);
                      } else {
                        moveToUserLocation();
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF0F766E),
                        size: 22,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 14,
                  right: 14,
                  child: Column(
                    children: [
                      _mapControlBtn(
                        icon: Icons.add,
                        onTap: () => mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom + 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _mapControlBtn(
                        icon: Icons.remove,
                        onTap: () => mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom - 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Providers Near You',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${providers.length} provider${providers.length == 1 ? '' : 's'} found',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sort/filter badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF0F766E),
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Filter',
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Provider cards list
                Expanded(
                  child: providers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final provider = providers[index];
                            final distKm = _distanceKm(provider);
                            return _buildProviderCard(provider, distKm);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 8),
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

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Providers Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      userLocation != null
                          ? 'Location detected ✓'
                          : 'Detecting location...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Provider count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '${providers.length} found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(ProviderModel provider, double? distKm) {
    return GestureDetector(
      onTap: () {
        // Move map to this provider
        mapController.move(LatLng(provider.latitude, provider.longitude), 14);
        setState(() => selectedProvider = provider);
        context.push('/provider-details', extra: provider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selectedProvider?.id == provider.id
              ? Border.all(color: const Color(0xFF0F766E), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  provider.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    provider.serviceName,
                    style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        provider.city,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      if (distKm != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.near_me_rounded,
                          size: 13,
                          color: Color(0xFF14B8A6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${distKm.toStringAsFixed(1)} km',
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

            // Arrow
            Container(
              width: 34,
              height: 34,
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
      ),
    );
  }

  Widget _mapControlBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF0F172A), size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: Color(0xFF0F766E),
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No providers found nearby',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try zooming out or moving the map',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
