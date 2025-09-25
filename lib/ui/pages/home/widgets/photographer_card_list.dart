import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:chakak_flutter/_core/constants/app_text_styles.dart';
import 'package:chakak_flutter/_core/utils/image_utils.dart';

import '../../../../data/models/photographer.dart';
import '../../../../provider/global/photographer/photographer_provider.dart';

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
      ref.read(photographerProvider.notifier).loadPhotographers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final photographerState = ref.watch(photographerProvider);

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
          height: 220,
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
        padding: const EdgeInsets.only(bottom: 10),
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
                  .read(photographerProvider.notifier)
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
                  child: ImageUtils.buildSafeImage(
                    photographer.imageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
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
