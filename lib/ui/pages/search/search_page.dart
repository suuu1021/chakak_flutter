import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../data/models/photographer.dart';
import '../../../provider/global/search/search_notifier.dart';
import '../home/widgets/photographer_card_list.dart';
import '../home/widgets/photo_service_category_widget.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchNotifierProvider.notifier).loadSearchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) async {
    if (query.trim().isNotEmpty) {
      // 검색어 추가
      await ref.read(searchNotifierProvider.notifier).addSearch(query.trim());

      // 검색 데이터 다시 로드해서 UI 업데이트
      await ref.read(searchNotifierProvider.notifier).loadSearchData();

      _focusNode.unfocus(); // 키보드 숨기기

      print('검색 실행: $query');
      print('최근 검색어 저장 완료');
    }
  }

  void _onRecentSearchTap(String keyword) {
    _searchController.text = keyword;
    _onSearchSubmitted(keyword);
  }

  void _onPopularSearchTap(String keyword) {
    _searchController.text = keyword;
    _onSearchSubmitted(keyword);
  }

  void _onCategoryTap(PhotoServiceCategory category) {
    print('카테고리 선택: ${category.name}');
  }

  void _onPhotographerTap(Photographer photographer) {
    print('작가 선택: ${photographer.businessName}');
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHAKAK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: Column(
          children: [
            // 검색 입력 필드
            _buildSearchField(),

            // 메인 콘텐츠
            Expanded(
              child: _buildMainContent(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(searchNotifierProvider.notifier).updateQuery(value);
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // 검색 버튼 추가
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () => _onSearchSubmitted(_searchController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: const Text(
                '검색',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(SearchState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최근 검색어 섹션
          _buildRecentSearches(state),

          const SizedBox(height: 24),

          // 추천 검색어
          _buildPopularSearches(state),

          const SizedBox(height: 24),

          // 인기 작가
          PhotographerCardList(
            onPhotographerTap: _onPhotographerTap,
          ),

          const SizedBox(height: 24),

          // 카테고리
          PhotoServiceCategoryWidget(
            onCategoryTap: _onCategoryTap,
            showSeeAll: false,
          ),
        ],
      ),
    );
  }

  // 최근 검색어 섹션 (추천 검색어와 같은 스타일)
  Widget _buildRecentSearches(SearchState state) {
    if (state.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 검색어',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(searchNotifierProvider.notifier)
                    .clearAllHistory();
                await ref
                    .read(searchNotifierProvider.notifier)
                    .loadSearchData();
              },
              child: Text(
                '전체 삭제',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.recentSearches.map((search) {
            return _buildSearchChip(
              search.keyword,
              onTap: () => _onRecentSearchTap(search.keyword),
              onRemove: () async {
                await ref
                    .read(searchNotifierProvider.notifier)
                    .removeRecentSearch(search.id);
                await ref
                    .read(searchNotifierProvider.notifier)
                    .loadSearchData();
              },
              showRemove: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSearches(SearchState state) {
    if (state.popularSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추천 검색어',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.popularSearches.map((search) {
            return _buildSearchChip(
              search.keyword,
              onTap: () => _onPopularSearchTap(search.keyword),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchChip(
    String keyword, {
    required VoidCallback onTap,
    VoidCallback? onRemove,
    bool showRemove = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (showRemove && onRemove != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
