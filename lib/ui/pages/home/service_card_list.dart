import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../_core/constants/app_images.dart';
import '../../../_core/constants/app_text_styles.dart';

// 1. 데이터 모델 (ServiceItem)
class ServiceItem {
  final int id;
  final String title;
  final String imageUrl;
  final List<String> categories;
  final int price;
  final double rating;
  final int reviewCount;
  final bool isLiked;

  ServiceItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
  });
}

// 2. 더미 데이터 (ServiceApiService)
class ServiceApiService {
  static Future<List<ServiceItem>> getServices() async {
    // 실제 API 호출 대신 500ms 지연 후 더미 데이터 반환
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      ServiceItem(
        id: 1,
        title: '추억이 될 오늘을 스냅으로 담아드려요요요요요요요요요요요요요요',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: true,
      ),
      ServiceItem(
        id: 2,
        title: '추억이 될 오늘을 스냅으로 담아드려요',
        imageUrl: AppImages.onboarding2,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: false,
      ),
      ServiceItem(
        id: 3,
        title: '추억이 될 오늘을 스냅으로 담아드려요',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: true,
      ),
    ];
  }
}

// 3. UI 위젯
class ServiceCardList extends StatelessWidget {
  final Function(ServiceItem) onServiceTap;

  const ServiceCardList({required this.onServiceTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<ServiceItem>>(
            future: ServiceApiService.getServices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('서비스가 없습니다.'));
              } else {
                final services = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: index == services.length - 1 ? 16.0 : 0,
                      ),
                      child: ServiceCard(
                        service: service,
                        onTap: () => onServiceTap(service),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceItem service;
  final VoidCallback onTap;

  const ServiceCard({Key? key, required this.service, required this.onTap})
      : super(key: key);

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.service.isLiked;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      // await ApiService.updateLikeStatus(widget.service.id, _isLiked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                  child: Image.asset(
                    widget.service.imageUrl,
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
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleLike,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLiked
                            ? Icons.bookmark_outlined
                            : Icons.bookmark_border_outlined,
                        color: _isLiked ? Colors.orange : Colors.black,
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
                    widget.service.title,
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
                    children: widget.service.categories
                        .take(3)
                        .map((categoryName) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                categoryName,
                                style: AppTextStyles.categoryName,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.service.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원~',
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
                        '${widget.service.rating.toStringAsFixed(1)} (${widget.service.reviewCount})',
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
