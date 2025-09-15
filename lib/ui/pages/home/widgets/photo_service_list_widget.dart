import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/photo_service.dart';
import '../../../../provider/global/photoService/photo_service_notifier.dart';

class PhotoServiceListWidget extends ConsumerWidget {
  final List<PhotoService> services;
  final EdgeInsets? padding;
  final Function(PhotoService)? onServiceTap;

  const PhotoServiceListWidget({
    super.key,
    required this.services,
    this.padding,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (services.isEmpty) {
      return const Center(child: Text('서비스가 없습니다.'));
    }

    // 실시간으로 포토서비스 상태를 가져옴
    final photoServiceState = ref.watch(photoServiceNotifierProvider);

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final serviceId = services[index].id;
        // 현재 상태에서 해당 서비스를 찾음
        final service =
            photoServiceState.services.firstWhere((s) => s.id == serviceId);

        return PhotoServiceCard(
          service: service,
          onTap: onServiceTap,
          onBookmarkTap: () {
            ref
                .read(photoServiceNotifierProvider.notifier)
                .toggleLike(service.id);
          },
        );
      },
    );
  }
}

class PhotoServiceCard extends StatelessWidget {
  final PhotoService service;
  final Function(PhotoService)? onTap;
  final VoidCallback? onBookmarkTap;

  const PhotoServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(service) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // 서비스 이미지
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Image.asset(
                      service.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.camera_alt,
                            size: 30, color: Colors.grey);
                      },
                    ),
                  ),
                  // 북마크 아이콘
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onBookmarkTap,
                      child: Icon(
                        service.isLiked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: service.isLiked ? Colors.orange : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 서비스 정보
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 평점과 별 아이콘
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 카테고리
                    Text(
                      service.categories.join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 가격
                    Text(
                      '${service.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
