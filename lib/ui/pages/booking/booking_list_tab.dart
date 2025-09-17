import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../data/models/booking/booking_model.dart';
import '../../../data/models/photo_service/photo_service.dart';

class BookingListTab extends ConsumerStatefulWidget {
  const BookingListTab({super.key});

  @override
  ConsumerState<BookingListTab> createState() => _BookingListTabState();
}

class _BookingListTabState extends ConsumerState<BookingListTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  BookingStatus? selectedFilter;

  // 스냅촬영 플랫폼에 맞는 더미 예약 데이터
  final List<BookingListItem> dummyBookings = [
    BookingListItem(
      photographerProfileId: 1,
      bookingDateTime: DateTime(2025, 9, 20, 14, 30),
      status: BookingStatus.confirmed,
      photographerName: '김포토 작가',
      bookingInfoId: 1001,
      photoService: PhotoService(
        id: 4,
        photographerId: 1,
        title: '커플 스냅',
        imageUrl:
            'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=800&h=600&fit=crop&crop=center',
        categories: ['커플'],
        price: 250000,
        rating: 4.6,
        reviewCount: 12,
        isLiked: false,
        description: '연인의 달콤한 순간을 기록합니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 2,
      bookingDateTime: DateTime(2025, 9, 18, 10, 0),
      status: BookingStatus.pending,
      photographerName: '이스냅 작가',
      bookingInfoId: 1002,
      photoService: PhotoService(
        id: 3,
        photographerId: 2,
        title: '프로필 촬영',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop&crop=face',
        categories: ['프로필'],
        price: 200000,
        rating: 4.9,
        reviewCount: 35,
        isLiked: true,
        description: '전문적이고 매력적인 프로필 사진을 촬영해드립니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 3,
      bookingDateTime: DateTime(2025, 9, 15, 16, 0),
      status: BookingStatus.completed,
      photographerName: '박셔터 작가',
      bookingInfoId: 1003,
      photoService: PhotoService(
        id: 1,
        photographerId: 3,
        title: '웨딩 스냅 촬영',
        imageUrl:
            'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&h=600&fit=crop&crop=center',
        categories: ['웨딩'],
        price: 500000,
        rating: 4.8,
        reviewCount: 24,
        isLiked: false,
        description: '특별한 날의 소중한 순간을 아름답게 담아드립니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 4,
      bookingDateTime: DateTime(2025, 9, 12, 13, 30),
      status: BookingStatus.reviewed,
      photographerName: '최프레임 작가',
      bookingInfoId: 1004,
      photoService: PhotoService(
        id: 2,
        photographerId: 4,
        title: '가족사진 촬영',
        imageUrl:
            'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&h=600&fit=crop&crop=center',
        categories: ['가족사진'],
        price: 300000,
        rating: 4.7,
        reviewCount: 18,
        isLiked: false,
        description: '가족의 행복한 모습을 자연스럽게 포착합니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 5,
      bookingDateTime: DateTime(2025, 9, 10, 11, 0),
      status: BookingStatus.canceled,
      photographerName: '정렌즈 작가',
      bookingInfoId: 1005,
      photoService: PhotoService(
        id: 5,
        photographerId: 5,
        title: '졸업사진 촬영',
        imageUrl:
            'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&h=300&fit=crop',
        categories: ['졸업사진'],
        price: 150000,
        rating: 4.5,
        reviewCount: 8,
        isLiked: false,
        description: '인생의 중요한 순간을 기념하는 졸업사진을 촬영합니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 6,
      bookingDateTime: DateTime(2025, 9, 8, 15, 30),
      status: BookingStatus.rejected,
      photographerName: '한캡처 작가',
      bookingInfoId: 1006,
      photoService: PhotoService(
        id: 19,
        photographerId: 6,
        title: '반려동물 촬영',
        imageUrl:
            'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg',
        categories: ['펫'],
        price: 180000,
        rating: 4.6,
        reviewCount: 22,
        isLiked: true,
        description: '사랑스러운 반려동물의 순간을 담아드립니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 7,
      bookingDateTime: DateTime(2025, 9, 5, 9, 0),
      status: BookingStatus.completed,
      photographerName: '윤아웃풋 작가',
      bookingInfoId: 1007,
      photoService: PhotoService(
        id: 20,
        photographerId: 7,
        title: '브랜딩 촬영',
        imageUrl:
            'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=400&h=300&fit=crop',
        categories: ['브랜딩'],
        price: 400000,
        rating: 4.8,
        reviewCount: 15,
        isLiked: false,
        description: '브랜드의 가치를 담은 전문적인 촬영을 진행합니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
    BookingListItem(
      photographerProfileId: 8,
      bookingDateTime: DateTime(2025, 9, 3, 17, 0),
      status: BookingStatus.reviewed,
      photographerName: '송포커스 작가',
      bookingInfoId: 1008,
      photoService: PhotoService(
        id: 21,
        photographerId: 8,
        title: '임신 기념 촬영',
        imageUrl:
            'https://images.pexels.com/photos/4513731/pexels-photo-4513731.jpeg',
        categories: ['임신'],
        price: 250000,
        rating: 4.9,
        reviewCount: 27,
        isLiked: true,
        description: '생명의 소중함을 담은 임신 기념 촬영입니다.',
        priceOptions: [],
        portfolioImages: [],
      ),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingListItem> get filteredBookings {
    List<BookingListItem> result = dummyBookings;

    // 상태 필터링
    if (selectedFilter != null) {
      result =
          result.where((booking) => booking.status == selectedFilter).toList();
    }

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      result = result.where((booking) {
        return booking.photographerName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  int getCountByStatus(BookingStatus status) {
    return dummyBookings.where((booking) => booking.status == status).length;
  }

  Color getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.primary; // 골든 아워 샌디 브라운
      case BookingStatus.confirmed:
        return AppColors.secondary; // 차분한 블루
      case BookingStatus.rejected:
      case BookingStatus.canceled:
        return AppColors.textSecondary; // 부드러운 회색
      case BookingStatus.completed:
        return AppColors.secondaryDark; // 진한 블루
      case BookingStatus.reviewed:
        return AppColors.gray600; // 중간 회색
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: _buildBookingContent(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '포토그래퍼명으로 검색',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('전체', null, dummyBookings.length),
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
    final isSelected = selectedFilter == status;
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
        setState(() {
          selectedFilter = selected ? status : null;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildBookingContent() {
    final bookings = filteredBookings;

    if (bookings.isEmpty) {
      if (_searchQuery.isNotEmpty && dummyBookings.isNotEmpty) {
        return _buildNoSearchResults();
      }
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // 새로고침 로직
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBookingCard(booking),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingListItem booking) {
    return Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBookingDetail(booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildServiceImage(booking),
              const SizedBox(width: 16),
              Expanded(
                child: _buildServiceInfo(booking),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(BookingListItem booking) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7), // 보더 두께만큼 작게 조정
        child: booking.photoService?.imageUrl != null
            ? Image.network(
                booking.photoService!.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.gray200,
      child: const Icon(
        Icons.camera_alt,
        color: AppColors.gray500,
        size: 32,
      ),
    );
  }

  Widget _buildServiceInfo(BookingListItem booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildServiceTitle(booking),
        const SizedBox(height: 4),
        _buildPhotographerName(booking),
        const SizedBox(height: 8),
        _buildDateTimeAndStatus(booking),
        const SizedBox(height: 8),
        _buildPriceAndAction(booking),
      ],
    );
  }

  Widget _buildServiceTitle(BookingListItem booking) {
    return Text(
      booking.photoService?.title ?? '포토 촬영 서비스',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPhotographerName(BookingListItem booking) {
    return Text(
      booking.photographerName,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDateTimeAndStatus(BookingListItem booking) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${booking.formattedDate} ${booking.formattedTime}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(booking),
      ],
    );
  }

  Widget _buildStatusChip(BookingListItem booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(booking.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        booking.status.description,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildPriceAndAction(BookingListItem booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPrice(booking),
        if (_shouldShowCancelButton(booking)) _buildCancelButton(booking),
      ],
    );
  }

  Widget _buildPrice(BookingListItem booking) {
    return Text(
      '${booking.photoService?.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  bool _shouldShowCancelButton(BookingListItem booking) {
    return booking.status == BookingStatus.pending;
  }

  Widget _buildCancelButton(BookingListItem booking) {
    return TextButton(
      onPressed: () => _showCancelDialog(booking),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        '취소',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red[600],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            selectedFilter == null
                ? '예약 내역이 없습니다'
                : '${selectedFilter!.description} 예약이 없습니다',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
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

  void _showBookingDetail(BookingListItem booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${booking.photographerName} 예약 상세 화면'),
      ),
    );
  }

  void _showCancelDialog(BookingListItem booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: Text('${booking.photographerName}님과의 예약을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('예약이 취소되었습니다')),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
