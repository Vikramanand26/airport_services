import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../app_utils/themes.dart';
import '../../../data/app_models/airport_model.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Obx(() => controller.isLoading.value
            ? const LoadingView()
            : const MainContent(),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero animated logo
          const Hero(
            tag: 'logo',
            child: Icon(
              Icons.flight_takeoff,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          // Animated progress indicator
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: AppTheme.slowAnimation,
            builder: (context, value, child) {
              return SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade300,
                  color: AppTheme.primaryColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Airport Data...',
            style: AppTheme.subheadingStyle,
          ),
        ],
      ),
    );
  }
}

/// Helper widget for delayed animations
class DelayedAnimationWidget extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final double beginOpacity;

  const DelayedAnimationWidget({
    super.key,
    required this.child,
    required this.delay,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 30),
    this.beginOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        final bool delayComplete = snapshot.connectionState == ConnectionState.done;

        return AnimatedOpacity(
          opacity: delayComplete ? 1.0 : beginOpacity,
          duration: duration,
          curve: curve,
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            transform: Matrix4.translationValues(
              beginOffset.dx * (delayComplete ? 0 : 1),
              beginOffset.dy * (delayComplete ? 0 : 1),
              0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class MainContent extends GetView<HomeController> {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Animated app bar
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'Airport Access',
              style: TextStyle(color: Colors.white),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated background elements
                  ...List.generate(5, (index) {
                    return Positioned(
                      top: 20.0 * (index + 1),
                      right: 30.0 * index,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 1000 + (index * 300)),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value * 0.3,
                            child: Icon(
                              Icons.flight,
                              size: 20,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  // Hero logo in the app bar
                  const Positioned(
                    right: 20,
                    bottom: 20,
                    child: Hero(
                      tag: 'logo',
                      child: Icon(
                        Icons.flight_takeoff,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main content sections with staggered animations
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Email input section
              DelayedAnimationWidget(
                delay: const Duration(milliseconds: 0),
                child: _buildEmailSection(),
              ),

              const SizedBox(height: 16),

              // Error message section with animation
              Obx(() => controller.errorMessage.value.isEmpty
                  ? const SizedBox.shrink()
                  : DelayedAnimationWidget(
                delay: const Duration(milliseconds: 100),
                child: _buildErrorMessage(),
              ),
              ),

              const SizedBox(height: 16),

              // Title bar with animation
              DelayedAnimationWidget(
                delay: const Duration(milliseconds: 200),
                child: _buildTitleBar(),
              ),

              const SizedBox(height: 16),
            ]),
          ),
        ),

        // Airports list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: Obx(() {
            final airports = controller.airportsToShow.value;

            if (airports.isEmpty) {
              return SliverToBoxAdapter(
                child: DelayedAnimationWidget(
                  delay: const Duration(milliseconds: 300),
                  child: _buildEmptyState(),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return AnimatedAirportCard(
                    airport: airports[index],
                    index: index,
                  );
                },
                childCount: airports.length,
              ),
            );
          }),
        ),

        // Bottom space
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.email,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Check Your Airport Access',
                style: AppTheme.subheadingStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.emailController,
            decoration: AppTheme.inputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Icons.alternate_email,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Add haptic feedback
                HapticFeedback.mediumImpact();
                controller.checkAccessByEmail();
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Check Access'),
              style: AppTheme.primaryButtonStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: AppTheme.fastAnimation,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.errorColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: AppTheme.errorColor,
                    onPressed: () => controller.errorMessage.value = '',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
          controller.isShowingAllAirports.value
              ? 'All Deployed Airports'
              : 'Your Accessible Airports',
          style: AppTheme.subheadingStyle,
        )),
        Obx(() => AnimatedSwitcher(
          duration: AppTheme.fastAnimation,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: OutlinedButton.icon(
            key: ValueKey<bool>(controller.isShowingAllAirports.value),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.toggleAirportView();
            },
            icon: Icon(
              controller.isShowingAllAirports.value
                  ? Icons.lock_open
                  : Icons.language,
              size: 18,
            ),
            label: Text(
              controller.isShowingAllAirports.value
                  ? 'Show My Access'
                  : 'Show All',
              style: const TextStyle(fontSize: 12),
            ),
            style: AppTheme.secondaryButtonStyle,
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated empty state icon
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: AppTheme.slowAnimation,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Opacity(
                  opacity: value,
                  child: Icon(
                    controller.isShowingAllAirports.value
                        ? Icons.flight_takeoff
                        : Icons.lock,
                    size: 64,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            controller.isShowingAllAirports.value
                ? 'No airports found'
                : 'No accessible airports found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            controller.isShowingAllAirports.value
                ? 'Try refreshing the page'
                : 'Try checking with a different email domain',
            style: AppTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Animated card for each airport
class AnimatedAirportCard extends StatelessWidget {
  final Airport airport;
  final int index;

  const AnimatedAirportCard({
    super.key,
    required this.airport,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return DelayedAnimationWidget(
      delay: Duration(milliseconds: 300 + (index * 100)),
      beginOffset: const Offset(0, 50),
      child: AirportCard(airport: airport),
    );
  }
}

// Individual airport card
class AirportCard extends StatelessWidget {
  final Airport airport;

  const AirportCard({super.key, required this.airport});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          HapticFeedback.selectionClick();

          // Show more details in a cool bottom sheet
          Get.bottomSheet(
            AirportDetailsSheet(airport: airport),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.primaryColor.withOpacity(0.1),
        highlightColor: AppTheme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildAirportLogo(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airport.airportName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Code: ${airport.airportCode}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirportLogo() {
    // Use a safe approach to display the logo, falling back to an icon if there's an error
    try {
      if (airport.airportLogo.isNotEmpty) {
        // First, try to extract the Base64 data after the comma if it's in data:image format
        String base64String = airport.airportLogo;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        return Hero(
          tag: 'airport-${airport.airportCode}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(base64String),
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackLogo();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // If decoding fails, use fallback
      print('Error decoding logo: $e');
    }

    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    return Hero(
      tag: 'airport-${airport.airportCode}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            airport.airportCode,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Airport details bottom sheet
class AirportDetailsSheet extends StatelessWidget {
  final Airport airport;

  const AirportDetailsSheet({super.key, required this.airport});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'airport-${airport.airportCode}',
                  child: _buildAirportLogo(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airport.airportName,
                        style: AppTheme.subheadingStyle.copyWith(fontSize: 20),
                      ),
                      Text(
                        'Airport Code: ${airport.airportCode}',
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow('Status', 'Active', Icons.check_circle, AppTheme.successColor),
                const SizedBox(height: 16),
                _buildDetailRow('Access', 'Authorized', Icons.verified_user, AppTheme.primaryColor),
                const SizedBox(height: 16),
                _buildDetailRow('Location', 'International', Icons.public, AppTheme.secondaryColor),
              ],
            ),
          ),

          const Divider(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Get.back();
                    Get.snackbar(
                      'Feature Coming Soon',
                      'Airport details will be available in the next update',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.primaryColor,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Get.back();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDarkColor,
                  ),
                ),
              ],
            ),
          ),

          // Extra space for bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.captionStyle,
            ),
            Text(
              value,
              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAirportLogo() {
    // Use a safe approach to display the logo, falling back to an icon if there's an error
    try {
      if (airport.airportLogo.isNotEmpty) {
        // First, try to extract the Base64 data after the comma if it's in data:image format
        String base64String = airport.airportLogo;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(base64String),
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo();
            },
          ),
        );
      }
    } catch (e) {
      print('Error decoding logo: $e');
    }

    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          airport.airportCode,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}