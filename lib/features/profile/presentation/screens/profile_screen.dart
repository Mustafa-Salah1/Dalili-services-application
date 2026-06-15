import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_finder/core/storage/secure_storage_service.dart';

import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import 'package:go_router/go_router.dart';
import '../../../provider/presentation/providers/provider_provider.dart';
import '../../../provider/presentation/providers/provider_state.dart';
import '../../../provider_application/presentation/providers/provider_application_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileProvider.notifier).getProfile();
      ref.read(providerApplicationProvider.notifier).getMyApplication();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: state is ProfileLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F766E)),
              )
            : state is ProfileLoaded
            ? SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
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
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              child: Text(
                                state.profile.username[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome Back 👋',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.profile.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.profile.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // User Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF0F766E),
                            label: 'Username',
                            value: state.profile.username,
                          ),
                          const Divider(height: 28, color: Color(0xFFF1F5F9)),
                          _infoRow(
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFF14B8A6),
                            label: 'Email',
                            value: state.profile.email,
                          ),
                          const Divider(height: 28, color: Color(0xFFF1F5F9)),
                          _infoRow(
                            icon: Icons.verified_user_outlined,
                            iconColor: const Color(0xFF10B981),
                            label: 'Role',
                            value: state.profile.role,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Actions',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Edit Profile — always visible
                    _actionCard(
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF0F766E),
                      iconBg: const Color(0xFFCCFBF1),
                      title: 'Edit Profile',
                      onTap: () async {
                        await context.push('/edit-profile');
                        if (context.mounted) {
                          ref.read(profileProvider.notifier).getProfile();
                        }
                      },
                    ),

                    // USER only
                    if (state.profile.role == 'USER') ...[
                      const SizedBox(height: 12),
                      _actionCard(
                        icon: Icons.assignment_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        iconBg: const Color(0xFFFEF3C7),
                        title: 'My Requests',
                        onTap: () {
                          context.push('/my-requests');
                        },
                      ),
                      const SizedBox(height: 12),

                      _actionCard(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFEF4444),
                        iconBg: const Color(0xFFFEE2E2),
                        title: 'My Favorites',
                        onTap: () {
                          context.push('/favorites');
                        },
                      ),
                      const SizedBox(height: 12),
                      _actionCard(
                        icon: Icons.business_center_outlined,
                        iconColor: const Color(0xFF10B981),
                        iconBg: const Color(0xFFD1FAE5),
                        title: 'Apply as Provider',
                        onTap: () {
                          context.push('/apply-provider');
                        },
                      ),
                    ],

                    // PROVIDER only
                    if (state.profile.role == 'PROVIDER') ...[
                      const SizedBox(height: 12),
                      _actionCard(
                        icon: Icons.store_outlined,
                        iconColor: const Color(0xFF0F766E),
                        iconBg: const Color(0xFFCCFBF1),
                        title: 'My Provider Profile',
                        onTap: () {
                          context.push('/my-provider');
                        },
                      ),
                      const SizedBox(height: 12),
                      _actionCard(
                        icon: Icons.inbox_outlined,
                        iconColor: const Color(0xFF6366F1),
                        iconBg: const Color(0xFFE0E7FF),
                        title: 'Provider Requests',
                        onTap: () async {
                          await ref
                              .read(providerProvider.notifier)
                              .getMyProvider();
                          final providerState = ref.read(providerProvider);
                          if (providerState is MyProviderLoaded) {
                            context.push(
                              '/provider-requests',
                              extra: providerState.provider.id,
                            );
                          } else if (providerState is ProviderError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(providerState.message)),
                            );
                          }
                        },
                      ),
                    ],

                    // ADMIN only
                    if (state.profile.role == 'ADMIN') ...[
                      const SizedBox(height: 12),
                      _actionCard(
                        icon: Icons.admin_panel_settings_outlined,
                        iconColor: const Color(0xFFEF4444),
                        iconBg: const Color(0xFFFEE2E2),
                        title: 'Admin Dashboard',
                        onTap: () {
                          context.push('/admin-dashboard');
                        },
                      ),
                    ],

                    // Logout — always visible
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFEF4444),
                      iconBg: const Color(0xFFFEE2E2),
                      title: 'Logout',
                      titleColor: const Color(0xFFEF4444),
                      showArrow: false,
                      onTap: () async {
                        await SecureStorageService.clearTokens();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              )
            : state is ProfileError
            ? Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
                  color: Color(0xFF64748B),
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
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF0F172A),
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }
}
