import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/service_service.dart';
import '../../config/theme.dart';
import 'service_detail_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServiceService _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final services = await _serviceService.getAllServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildServicesList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to load services',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadServices,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_laundry_service,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No services available',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive spacing based on screen width
          final screenWidth = constraints.maxWidth;
          final horizontalPadding = screenWidth * 0.04; // 4% of screen width
          final gridSpacing = screenWidth * 0.03; // 3% of screen width

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12,
            ),
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Choose Your Service',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth < 360 ? 20 : null,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We offer professional laundry services tailored to your needs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: screenWidth < 360 ? 13 : null,
                ),
              ),
              const SizedBox(height: 16),

              // Services Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: gridSpacing.clamp(8.0, 16.0),
                  mainAxisSpacing: gridSpacing.clamp(8.0, 16.0),
                  childAspectRatio: screenWidth < 360 ? 0.68 : 0.72,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return _buildServiceCard(_services[index]);
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Get available width for the card
            final cardWidth = constraints.maxWidth;

            // Calculate responsive sizes
            final iconSize = (cardWidth * 0.35).clamp(50.0, 70.0);
            final iconFontSize = (cardWidth * 0.18).clamp(28.0, 36.0);
            final titleFontSize = (cardWidth * 0.08).clamp(13.0, 16.0);
            final priceFontSize = (cardWidth * 0.085).clamp(14.0, 17.0);
            final bodyFontSize = (cardWidth * 0.065).clamp(11.0, 13.0);
            final verticalPadding = (cardWidth * 0.06).clamp(8.0, 12.0);

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: cardWidth * 0.06,
                vertical: verticalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Service Icon/Image
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(iconSize / 2),
                    ),
                    child: Center(
                      child: Text(
                        service.icon ?? '🧺',
                        style: TextStyle(fontSize: iconFontSize),
                      ),
                    ),
                  ),
                  SizedBox(height: cardWidth * 0.04),

                  // Service Name
                  Flexible(
                    child: Text(
                      service.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: cardWidth * 0.03),

                  // Price
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardWidth * 0.06,
                      vertical: cardWidth * 0.025,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: priceFontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: cardWidth * 0.025),

                  // Estimated Days
                  if (service.estimatedDays != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: bodyFontSize + 1,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${service.estimatedDays} days',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: bodyFontSize,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
