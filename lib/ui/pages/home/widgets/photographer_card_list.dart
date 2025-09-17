// lib/ui/pages/home/widgets/photographer_card_list.dart
import 'dart:convert'; // Base64 디코딩을 위해 추가
import 'dart:typed_data'; // Uint8List를 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:chakak_flutter/_core/constants/app_text_styles.dart';

import '../../../../data/models/photographer.dart';
import '../../../../provider/global/photographer/photographer_notifier.dart';

class PhotographerCardList extends ConsumerStatefulWidget {
  final Function(Photographer) onPhotographerTap;

  const PhotographerCardList({super.key, required this.onPhotographerTap});

  @override
  ConsumerState<PhotographerCardList> createState() =>
      _PhotographerCardListState();
}

class _PhotographerCardListState extends ConsumerState<PhotographerCardList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photographerNotifierProvider.notifier).loadPhotographers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final photographerState = ref.watch(photographerNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '작가 목록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220, // 카드의 높이에 따라 조정
          child: _buildContent(photographerState),
        ),
      ],
    );
  }

  Widget _buildContent(PhotographerState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      return Center(child: Text('에러: ${state.error}'));
    } else if (state.photographers.isEmpty) {
      return const Center(child: Text('등록된 작가가 없습니다.'));
    } else {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.photographers.length,
        itemBuilder: (context, index) {
          final photographer = state.photographers[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: index == state.photographers.length - 1 ? 16.0 : 0,
            ),
            child: PhotographerCard(
              photographer: photographer,
              onTap: () => widget.onPhotographerTap(photographer),
              onLikeTap: () => ref
                  .read(photographerNotifierProvider.notifier)
                  .toggleLike(photographer.id),
            ),
          );
        },
      );
    }
  }
}

class PhotographerCard extends StatelessWidget {
  final Photographer photographer;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const PhotographerCard({
    Key? key,
    required this.photographer,
    required this.onTap,
    required this.onLikeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final String imageUrl = photographer
        .imageUrl; // Assume this is the Base64 string or a network URL

    if (imageUrl.startsWith('http')) {
      // Handle network image
      imageWidget = Image.network(
        imageUrl,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.person, color: Colors.grey, size: 40),
            ),
          );
        },
      );
    } else if (imageUrl.isNotEmpty) {
      // Handle Base64 image
      try {
        String base64String = imageUrl;
        if (base64String.startsWith('data:image')) {
          base64String = base64String.split(',').last;
        }
        Uint8List imageBytes = base64Decode(base64String);
        imageWidget = Image.memory(
          imageBytes,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print(
                'Error decoding Base64 image for photographer ${photographer.businessName}: $error');
            return Container(
              height: 120,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.person, color: Colors.grey, size: 40),
              ),
            );
          },
        );
      } catch (e) {
        print(
            'Error processing Base64 string for photographer ${photographer.businessName}: $e');
        imageWidget = Container(
          height: 120,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.person, color: Colors.grey, size: 40),
          ),
        );
      }
    } else {
      // Handle empty or null imageUrl (fallback)
      imageWidget = Container(
        height: 120,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.person, color: Colors.grey, size: 40),
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
                  child: imageWidget, // Display the determined image widget
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
                        photographer.isLiked
                            ? Icons.favorite // 좋아요 아이콘
                            : Icons.favorite_border,
                        color: photographer.isLiked ? Colors.red : Colors.black,
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
                    photographer.businessName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (photographer.categories.isNotEmpty)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: photographer.categories
                          .take(3) // 최대 3개 카테고리 표시
                          .map((categoryName) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(
                                        0.1), // AppColors 사용 및 투명도 조절
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                        color: AppColors.primary, width: 0.5)),
                                child: Text(
                                  categoryName,
                                  style: AppTextStyles.categoryName.copyWith(
                                      color: AppColors
                                          .primary), // AppTextStyles 사용
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
                        '${photographer.rating.toStringAsFixed(1)} (${photographer.reviewCount})',
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
