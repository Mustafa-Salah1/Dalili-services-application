import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:service_finder/core/network/dio_client.dart';
import 'package:service_finder/core/storage/secure_storage_service.dart';

import 'package:service_finder/features/auth/data/datasources/auth_remote_source.dart';

import 'package:service_finder/features/service/presentation/providers/service_provider.dart';
import 'package:service_finder/features/service/presentation/providers/service_state.dart';

import 'package:service_finder/features/service/presentation/widgets/service_search_bar.dart';

String? _serviceImageAsset(String title) {
  final t = title.toLowerCase();
  if (t.contains('electric')) return 'assets/images/electrician1.jpg';
  if (t.contains('plumb')) return 'assets/images/plumber1.jpeg';
  if (t.contains('paint')) return 'assets/images/painter1.jpeg';
  if (t.contains('clean')) return 'assets/images/cleaning1.jpeg';
  if (t.contains('carpent') || t.contains('wood'))
    return 'assets/images/carpenter1.jpeg';
  return null;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(serviceProvider.notifier).getServices();
    });
  }

  Future<void> logout(BuildContext context) async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken != null) {
        await AuthRemoteDataSource().logout(refreshToken: refreshToken);
      }
    } catch (_) {}

    await SecureStorageService.clearTokens();

    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> testProtectedEndpoint() async {
    try {
      final response = await DioClient.dio.get('/api/users/me');
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (state is ServiceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F766E)),
              );
            }

            if (state is ServiceError) {
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

            if (state is ServiceLoaded) {
              return RefreshIndicator(
                color: const Color(0xFF0F766E),
                onRefresh: () async {
                  await ref.read(serviceProvider.notifier).getServices();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: const ServiceSearchBar(),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        child: _buildHeroBanner(context),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        child: _buildStatsRow(),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: _buildSectionHeader(
                          icon: Icons.category_outlined,
                          title: 'Categories',
                          iconColor: const Color(0xFF0F766E),
                          subtitle: '${state.services.length} services',
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                        child: _buildCategoriesGrid(context, state.services),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final imagePath = _serviceImageAsset(service.title);

        return GestureDetector(
          onTap: () => context.push('/providers', extra: service),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Real image or gradient placeholder
                        imagePath != null
                            ? Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _gridPlaceholder(),
                              )
                            : _gridPlaceholder(),

                        // Subtle gradient overlay at bottom of image
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.25),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 12,
                                    color: Color(0xFF0F766E),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Explore',
                                    style: TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _gridPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCCFBF1), Color(0xFFE0F2F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.home_repair_service_rounded,
          color: Color(0xFF0F766E),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_repair_service_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Dalili',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _headerIconBtn(
                    icon: Icons.person_outline_rounded,
                    onTap: () => context.push('/profile'),
                  ),
                  const SizedBox(width: 10),
                  _headerIconBtn(
                    icon: Icons.notifications_outlined,
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome Back 👋',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find Trusted Services\nNear You',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _headerIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0F766E),
    Color bgColor = const Color(0xFFCCFBF1),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    '✨ Top Rated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Need a\nProfessional?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find trusted providers\naround you instantly.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => context.push('/providers-map'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          color: Color(0xFF0F766E),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Open Map',
                          style: TextStyle(
                            color: Color(0xFF0F766E),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.handyman_outlined,
            iconColor: const Color(0xFF0F766E),
            iconBg: const Color(0xFFCCFBF1),
            label: 'Services',
            value: '50+',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF6366F1),
            iconBg: const Color(0xFFE0E7FF),
            label: 'Providers',
            value: '200+',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.star_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFEF3C7),
            label: 'Rating',
            value: '4.9★',
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (subtitle != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
