import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/constants/app_colors.dart';
import '../../../data/models/booking/booking_model.dart';
import '../../../data/models/booking/booking_list_item.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/global/booking/booking_list_notifier.dart';
import 'widgets/booking_error_widget.dart';
import 'widgets/booking_empty_widget.dart';
import 'widgets/booking_card.dart';

class BookingListTab extends ConsumerStatefulWidget {
  const BookingListTab({super.key});

  @override
  ConsumerState<BookingListTab> createState() => _BookingListTabState();
}

class _BookingListTabState extends ConsumerState<BookingListTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  // selectedFilter 제거 - provider에서 완전히 관리

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingListProvider.notifier).loadMyBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingListItem> get filteredBookings {
    final bookingState = ref.watch(bookingListProvider); // watch 사용
    List<BookingListItem> result = bookingState.bookings;

    // Provider의 selectedFilter 사용
    if (bookingState.selectedFilter != null) {
      result = result
          .where((booking) => booking.status == bookingState.selectedFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((booking) {
        return booking.otherPartyName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  int getCountByStatus(BookingStatus status) {
    final bookingState = ref.watch(bookingListProvider); // watch 사용
    return bookingState.bookings
        .where((booking) => booking.status == status)
        .length;
  }

  int get totalCount {
    final bookingState = ref.watch(bookingListProvider); // watch 사용
    return bookingState.bookings.length;
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingListProvider);
    final session = ref.watch(sessionProvider);

    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: _buildBookingContent(bookingState, session),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '상대방 이름으로 검색',
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          fillColor: AppColors.background,
          filled: true,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('전체', null, totalCount),
            const SizedBox(width: 8),
            ...BookingStatus.values.map((status) {
              final count = getCountByStatus(status);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(status.description, status, count),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, BookingStatus? status, int count) {
    final bookingState = ref.watch(bookingListProvider);
    final isSelected = bookingState.selectedFilter == status;

    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        ref
            .read(bookingListProvider.notifier)
            .setFilter(selected ? status : null);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildBookingContent(BookingListState state, AppSession session) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return BookingErrorWidget(
        error: state.errorMessage!,
        onRetry: () {
          ref.read(bookingListProvider.notifier).loadMyBookings();
        },
      );
    }

    final bookings = filteredBookings;

    if (bookings.isEmpty) {
      if (_searchQuery.isNotEmpty && state.bookings.isNotEmpty) {
        return _buildNoSearchResults();
      }
      return BookingEmptyWidget(selectedFilter: state.selectedFilter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(bookingListProvider.notifier).refresh();
      },
      child: Container(
        color: AppColors.gray200,
        child: ListView.builder(
          padding: const EdgeInsets.all(4),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: BookingCard(
                booking: booking,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_searchQuery"에 대한 결과를 찾을 수 없습니다',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            child: const Text('검색 초기화'),
          ),
        ],
      ),
    );
  }
}
