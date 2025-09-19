import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:chakak_flutter/_core/constants/app_text_styles.dart';

import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../provider/global/photoService/photo_service_provider.dart';

class ServiceCardList extends ConsumerStatefulWidget {
  final Function(PhotoService) onServiceTap;

  const ServiceCardList({required this.onServiceTap, super.key});

  @override
  ConsumerState<ServiceCardList> createState() => _ServiceCardListState();
}

class _ServiceCardListState extends ConsumerState<ServiceCardList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photoServiceProvider.notifier).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(photoServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '서비스',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: _buildContent(serviceState),
        ),
      ],
    );
  }

  Widget _buildContent(ServiceState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      return Center(child: Text('에러: ${state.error}'));
    } else if (state.services.isEmpty) {
      return const Center(child: Text('서비스가 없습니다.'));
    } else {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.services.length,
        itemBuilder: (context, index) {
          final service = state.services[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: index == state.services.length - 1 ? 16.0 : 0,
            ),
            child: ServiceCard(
              service: service,
              onTap: () => widget.onServiceTap(service),
              onLikeTap: () => ref
                  .read(photoServiceProvider.notifier)
                  .toggleLike(service.id),
            ),
          );
        },
      );
    }
  }
}

class ServiceCard extends StatelessWidget {
  final PhotoService service;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (service.imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        service.imageUrl,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 140,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        },
      );
    } else if (service.imageUrl.isNotEmpty) {
      try {
        String base64String = service.imageUrl;
        if (base64String.startsWith('data:image')) {
          base64String = base64String.split(',').last;
        }
        Uint8List imageBytes = base64Decode(base64String);
        imageWidget = Image.memory(
          imageBytes,
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error decoding or displaying base64 image: $error');
            return Container(
              height: 140,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        );
      } catch (e) {
        print('Error processing base64 image string: $e');
        imageWidget = Container(
          height: 140,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
        );
      }
    } else {
      imageWidget = Container(
        height: 140,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.photo, color: Colors.grey, size: 40),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageWidget,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onLikeTap,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        service.isLiked
                            ? Icons.bookmark_outlined
                            : Icons.bookmark_border_outlined,
                        color:
                            service.isLiked ? AppColors.primary : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: service.categories
                        .take(3)
                        .map((categoryName) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                      color: AppColors.primary, width: 0.5)),
                              child: Text(
                                categoryName,
                                style: AppTextStyles.categoryName
                                    .copyWith(color: AppColors.primary),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${service.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원~',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
