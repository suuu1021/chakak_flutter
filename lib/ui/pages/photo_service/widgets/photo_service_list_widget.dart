import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../provider/global/photoService/photo_service_provider.dart';
import 'photo_service_card.dart';

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
    final photoServiceState = ref.watch(photoServiceProvider);

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final serviceId = services[index].id;
        // 현재 상태에서 해당 서비스를 찾음
        final service = photoServiceState.services.firstWhere(
            (s) => s.id == serviceId,
            orElse: () => services[index]);

        return PhotoServiceCard(
          service: service,
          onTap: onServiceTap,
          onBookmarkTap: () {
            ref.read(photoServiceProvider.notifier).toggleLike(service.id);
          },
        );
      },
    );
  }
}
