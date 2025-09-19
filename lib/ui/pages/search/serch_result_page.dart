import 'package:chakak_flutter/data/models/portfolio.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/photographer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photographer.dart';
import '../../../provider/global/search/search_provider.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../photo_service/widgets/photo_service_list_widget.dart';
import '../portfolio/widgets/portfolio_card_widget.dart';
import '../profile/photographer/photographer_profile_page.dart';
import 'widgets/custom_search_field.dart';
import '../portfolio/portfolio_detail_page.dart';

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
  List<Portfolio> filteredPortfolios = [];

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
      // 3. 포트폴리오 검색 추가
      final searchedPortfolios = await searchNotifier.searchPortfolios(query);

      filteredPhotoServices = searchedServices;
      filteredPhotographers = searchedPhotographers;
      filteredPortfolios = searchedPortfolios;

      print(
          '검색 결과 - 포토서비스: ${filteredPhotoServices.length}, 포토그래퍼: ${filteredPhotographers.length}, 포트폴리오: ${filteredPortfolios.length}');
    } catch (e) {
      print('검색 오류: $e');
    }

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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPortfolios.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return PortfolioCardWidget(
          portfolio: filteredPortfolios[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PortfolioDetailPage(
                  portfolio: filteredPortfolios[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
