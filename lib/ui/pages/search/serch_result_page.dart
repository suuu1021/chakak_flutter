import 'package:chakak_flutter/data/models/portfolio.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/photographer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photographer.dart';
import '../../../provider/global/search/search_provider.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../photo_service/widgets/photo_service_list_widget.dart';
import '../profile/photographer/photographer_profile_page.dart';
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

  void _performSearch() async {
    final query = widget.searchQuery.toLowerCase();

    try {
      final searchNotifier = ref.read(searchProvider.notifier);

      // 1. 포토 서비스 검색
      final searchedServices = await searchNotifier.searchPhotoServices(query);
      // 2. 포토그래퍼 검색
      final searchedPhotographers =
          await searchNotifier.searchPhotographers(query);

      filteredPhotoServices = searchedServices;
      filteredPhotographers = searchedPhotographers;
      _buildPortfolioResults();

      print(
          '검색 결과 - 포토서비스: ${filteredPhotoServices.length}, 포토그래퍼: ${filteredPhotographers.length}, 포트폴리오: ${filteredPortfolios.length}');
    } catch (e) {
      print('검색 오류: $e');
    }

    setState(() {});
  }

  void _buildPortfolioResults() {
    final allPortfolios = <Map<String, dynamic>>[];

    for (final service in filteredPhotoServices) {
      for (int i = 0; i < service.portfolioImages.length; i++) {
        allPortfolios.add({
          'id': '${service.id}_$i',
          'title': '${service.title} 포트폴리오 ${i + 1}',
          'artist': '작가명', // photographer 정보가 필요하면 추가 로직 필요
          'categories': service.categories,
          'imageUrl': service.portfolioImages[i],
          'service': service,
        });
      }
    }

    filteredPortfolios = allPortfolios;
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoServiceDetailPage(service: service),
          ),
        );
      },
    );
  }

  Widget _buildPhotographerTab() {
    if (filteredPhotographers.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    return PhotographerListWidget(
      photographers: filteredPhotographers,
      onServiceTap: (photographer) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotographerProfilePage(
              photographerId: photographer.id,
            ),
          ),
        );
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
        return GestureDetector(
          onTap: () {
            // 포트폴리오를 탭했을 때 해당 서비스 상세 페이지로 이동
            final service = portfolio['service'] as PhotoService;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoServiceDetailPage(service: service),
              ),
            );
          },
          child: Container(
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
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        portfolio['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.photo,
                                size: 40, color: Colors.grey),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
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
          ),
        );
      },
    );
  }
}
