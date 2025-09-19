import 'package:chakak_flutter/ui/pages/search/serch_result_page.dart';
import 'package:chakak_flutter/ui/pages/search/widgets/category_grid.dart';
import 'package:chakak_flutter/ui/pages/search/widgets/custom_search_field.dart';
import 'package:chakak_flutter/ui/pages/search/widgets/photographer_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service_category.dart';
import '../../../data/models/photographer.dart';
import '../../../provider/global/search/search_provider.dart';
import '../photo_service/category_service_list_page.dart';
import '../profile/photographer/photographer_profile_page.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).loadSearchData();
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
      // 검색 결과 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(searchQuery: query.trim()),
        ),
      );

      // 검색어 저장
      await ref.read(searchProvider.notifier).addSearch(query.trim());
      await ref.read(searchProvider.notifier).loadSearchData();
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryServiceListPage(category: category),
      ),
    );
  }

  void _onPhotographerTap(Photographer photographer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotographerProfilePage(
          photographerId: photographer.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(child: _buildMainContent(searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return CustomSearchField(
      controller: _searchController,
      focusNode: _focusNode,
      onChanged: (value) {
        ref.read(searchProvider.notifier).updateQuery(value);
      },
      onSubmitted: _onSearchSubmitted,
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
          PhotographerGrid(
            onPhotographerTap: _onPhotographerTap,
          ),
          const SizedBox(height: 24),

          // 카테고리
          CategoryGrid(
            onCategoryTap: _onCategoryTap,
            showSeeAll: false,
          ),
        ],
      ),
    );
  }

  // 최근 검색어
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
                await ref.read(searchProvider.notifier).clearAllHistory();
                await ref.read(searchProvider.notifier).loadSearchData();
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
                    .read(searchProvider.notifier)
                    .removeRecentSearch(search.id);
                await ref.read(searchProvider.notifier).loadSearchData();
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
          color: Colors.white,
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
