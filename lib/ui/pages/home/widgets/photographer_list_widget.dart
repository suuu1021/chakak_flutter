import 'package:chakak_flutter/data/models/photographer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/global/photographer/photographer_provider.dart';

class PhotographerListWidget extends ConsumerWidget {
  final List<Photographer> photographers;
  final EdgeInsets? padding;
  final Function(Photographer)? onServiceTap;

  const PhotographerListWidget({
    super.key,
    required this.photographers,
    this.padding,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (photographers.isEmpty) {
      return const Center(child: Text('포토그래퍼가 없습니다.'));
    }

    // 실시간으로 포토그래퍼 상태를 가져옴
    final photographerState = ref.watch(photographerProvider);

    return Consumer(
      builder: (context, ref, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: photographers.length,
          itemBuilder: (context, index) {
            final photographerId = photographers[index].id;
            // 현재 상태에서 해당 포토그래퍼를 찾음
            final photographer = photographerState.photographers.firstWhere(
                (p) => p.id == photographerId,
                orElse: () => photographers[index]);

            return GestureDetector(
              onTap: () {
                print('포토그래퍼 클릭됨: ${photographer.businessName}');
                if (onServiceTap != null) {
                  onServiceTap!(photographer);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 프로필 이미지
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          photographer.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            photographer.businessName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            photographer.categories.join(', '),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                photographer.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${photographer.reviewCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 좋아요 버튼
                    IconButton(
                      icon: Icon(
                        photographer.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: photographer.isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        ref
                            .read(photographerProvider.notifier)
                            .toggleLike(photographer.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
