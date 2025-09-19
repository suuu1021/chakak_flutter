import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../provider/global/photoService/photo_service_provider.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../photo_service/widgets/photo_service_list_widget.dart';

class CategoryServiceListPage extends ConsumerStatefulWidget {
  final PhotoServiceCategory category;

  const CategoryServiceListPage({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryServiceListPage> createState() =>
      _CategoryServiceListPageState();
}

class _CategoryServiceListPageState
    extends ConsumerState<CategoryServiceListPage> {
  @override
  void initState() {
    super.initState();
    // 서비스 데이터가 없으면 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceState = ref.read(photoServiceProvider);
      if (serviceState.services.isEmpty && !serviceState.isLoading) {
        ref.read(photoServiceProvider.notifier).loadServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(photoServiceProvider);

    // 카테고리에 해당하는 서비스들 필터링
    final filteredServices = serviceState.services
        .where((service) => service.categories.contains(widget.category.name))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.primaryLight,
      ),
      body: _buildBody(serviceState, filteredServices),
    );
  }

  Widget _buildBody(
      ServiceState serviceState, List<PhotoService> filteredServices) {
    if (serviceState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (serviceState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '서비스를 불러오는 중 오류가 발생했습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              serviceState.error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(photoServiceProvider.notifier).loadServices();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.category.name} 카테고리의\n서비스가 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return PhotoServiceListWidget(
      services: filteredServices,
      onServiceTap: _navigateToServiceDetail,
    );
  }

  void _navigateToServiceDetail(PhotoService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoServiceDetailPage(service: service),
      ),
    );
  }
}
