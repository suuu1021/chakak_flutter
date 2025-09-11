import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../../_core/constants/app_images.dart';
import '../../../_core/constants/app_text_styles.dart';

// 1. 데이터 모델 (PhotographerItem)
class PhotographerItem {
  final int id;
  final String businessName; // 작가/업체명
  final String imageUrl; // 대표 이미지 URL
  final List<String> categories; // 전문 분야 (예: 웨딩, 프로필, 스냅)
  final double rating; // 평점
  final int reviewCount; // 리뷰 수
  final bool isLiked;

  PhotographerItem({
    required this.id,
    required this.businessName,
    required this.imageUrl,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false, // 기본값 false
  });
}

// 2. 더미 데이터 (PhotographerApiService) - 실제 API 연동 시 수정 필요
class PhotographerApiService {
  static Future<List<PhotographerItem>> getPhotographers() async {
    // 실제 API 호출 대신 500ms 지연 후 더미 데이터 반환
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      PhotographerItem(
        id: 1,
        businessName: '감성 포토 스튜디오',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        rating: 4.8,
        reviewCount: 120,
        isLiked: true,
      ),
      PhotographerItem(
        id: 2,
        businessName: '모던 스냅',
        imageUrl: AppImages.onboarding2,
        categories: [
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
          AppStrings.categoryPersonal,
        ],
        rating: 4.9,
        reviewCount: 98,
        isLiked: false,
      ),
      PhotographerItem(
        id: 3,
        businessName: '빛을 담는 사진관',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
          AppStrings.categoryPersonal,
        ],
        rating: 4.7,
        reviewCount: 75,
        isLiked: true,
      ),
    ];
  }
}

// 3. UI 위젯 (PhotographerCardList)
class PhotographerCardList extends StatelessWidget {
  final Function(PhotographerItem) onPhotographerTap;

  const PhotographerCardList({Key? key, required this.onPhotographerTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '추천 작가',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<PhotographerItem>>(
            future: PhotographerApiService.getPhotographers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('등록된 작가가 없습니다.'));
              } else {
                final photographers = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photographers.length,
                  itemBuilder: (context, index) {
                    final photographer = photographers[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: index == photographers.length - 1 ? 16.0 : 0,
                      ),
                      child: PhotographerCard(
                          photographer: photographer,
                          onTap: () => onPhotographerTap(photographer)),
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

// 4. 개별 작가 카드 위젯 (PhotographerCard)
class PhotographerCard extends StatefulWidget {
  final PhotographerItem photographer;
  final VoidCallback onTap;

  const PhotographerCard(
      {Key? key, required this.photographer, required this.onTap})
      : super(key: key);

  @override
  State<PhotographerCard> createState() => _PhotographerCardState();
}

class _PhotographerCardState extends State<PhotographerCard> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.photographer.isLiked;
  }

  void _toggleLike() {
    // _toggleFollow 대신 _toggleLike
    setState(() {
      _isLiked = !_isLiked;
      // TODO: 실제 API 연동 - 좋아요 상태 업데이트 로직 추가
      // 예: await PhotographerApiService.updateLikeStatus(widget.photographer.id, _isLiked);
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
                    widget.photographer.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(
                          child:
                              Icon(Icons.person, color: Colors.grey, size: 40),
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
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.black,
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
                    widget.photographer.businessName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (widget.photographer.categories.isNotEmpty)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: widget.photographer.categories
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.photographer.rating.toStringAsFixed(1)} (${widget.photographer.reviewCount})',
                        style: const TextStyle(fontSize: 13),
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
