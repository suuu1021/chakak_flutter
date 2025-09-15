import 'package:chakak_flutter/ui/pages/home/widgets/photographer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photographer.dart';
import '../../../provider/global/photoService/photo_service_notifier.dart';
import '../../../provider/global/photographer/photographer_notifier.dart';
import '../home/widgets/photo_service_list_widget.dart';
import 'widgets/custom_search_field.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Photographer> filteredPhotographers = [];
  List<PhotoService> filteredPhotoServices = [];
  List<Map<String, dynamic>> filteredPortfolios = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = widget.searchQuery.toLowerCase();

    // 포토그래퍼 검색 (이름, 카테고리)
    final photographerState = ref.read(photographerNotifierProvider);
    filteredPhotographers =
        photographerState.photographers.where((photographer) {
      return photographer.businessName.toLowerCase().contains(query) ||
          photographer.categories
              .any((category) => category.toLowerCase().contains(query));
    }).toList();

    // 포토서비스 검색 (서비스명, 카테고리)
    final photoServiceState = ref.read(photoServiceNotifierProvider);
    filteredPhotoServices = photoServiceState.services.where((service) {
      return service.title.toLowerCase().contains(query) ||
          service.categories
              .any((category) => category.toLowerCase().contains(query));
    }).toList();

    // 포트폴리오 더미데이터 필터링
    final allPortfolios = [
      {
        'title': '웨딩 포트폴리오 1',
        'artist': '김포토',
        'categories': ['웨딩', '스튜디오']
      },
      {
        'title': '커플 포트폴리오',
        'artist': '이작가',
        'categories': ['커플', '야외']
      },
      {
        'title': '가족 사진',
        'artist': '박사진',
        'categories': ['가족', '스튜디오']
      },
      {
        'title': '웨딩드레스 촬영',
        'artist': '최웨딩',
        'categories': ['웨딩', '드레스']
      },
      {
        'title': '프로필 사진',
        'artist': '정프로',
        'categories': ['프로필', '비즈니스']
      },
    ];

    filteredPortfolios = allPortfolios.where((portfolio) {
      return portfolio['title'].toString().toLowerCase().contains(query) ||
          portfolio['artist'].toString().toLowerCase().contains(query) ||
          (portfolio['categories'] as List).any(
              (category) => category.toString().toLowerCase().contains(query));
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: CustomSearchField(
          hintText: widget.searchQuery,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SearchResultsPage(searchQuery: value.trim()),
                ),
              );
            }
          },
          margin: const EdgeInsets.symmetric(vertical: 8),
          showSearchButton: true,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              indicatorWeight: 3,
              tabs: [
                Tab(text: '포토그래퍼 (${filteredPhotographers.length})'),
                Tab(text: '포트폴리오 (${filteredPortfolios.length})'),
                Tab(text: '포토서비스 (${filteredPhotoServices.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPhotographerTab(),
                _buildPortfolioTab(),
                _buildPhotoServiceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoServiceTab() {
    if (filteredPhotoServices.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    return PhotoServiceListWidget(
      services: filteredPhotoServices,
      onServiceTap: (service) {
        print('서비스 선택: ${service.title}');
      },
    );
  }

  Widget _buildPhotographerTab() {
    if (filteredPhotographers.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    return PhotographerListWidget(
      photographers: filteredPhotographers,
      onServiceTap: (service) {
        print('포토그래퍼 선택: ${service.businessName}');
      },
    );
  }

  Widget _buildPortfolioTab() {
    if (filteredPortfolios.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredPortfolios.length,
      itemBuilder: (context, index) {
        final portfolio = filteredPortfolios[index];
        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 포트폴리오 이미지
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: const Icon(Icons.photo, size: 40, color: Colors.grey),
                ),
              ),

              // 포트폴리오 정보
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portfolio['title'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        portfolio['artist'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
