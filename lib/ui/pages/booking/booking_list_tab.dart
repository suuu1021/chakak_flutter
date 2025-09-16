// import 'package:chakak_flutter/ui/pages/booking/widgets/booking_cancel_dialog.dart';
// import 'package:chakak_flutter/ui/pages/booking/widgets/booking_empty_widget.dart';
// import 'package:chakak_flutter/ui/pages/booking/widgets/booking_error_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../data/models/booking/booking_model.dart';
// import '../../../provider/global/booking/booking_list_notifier.dart';
// import '../search/widgets/custom_search_field.dart';
//
// class BookingListTab extends ConsumerStatefulWidget {
//   const BookingListTab({super.key});
//
//   @override
//   ConsumerState<BookingListTab> createState() => _BookingListTabState();
// }
//
// class _BookingListTabState extends ConsumerState<BookingListTab> {
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadBookings();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _loadBookings() {
//     final userType = ref.read(currentUserTypeProvider);
//     final userId = ref.read(currentUserIdProvider);
//
//     if (userType == UserType.user) {
//       ref.read(userBookingListProvider(userId).notifier).loadBookings();
//     } else {
//       ref.read(photographerBookingListProvider(userId).notifier).loadBookings();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userType = ref.watch(currentUserTypeProvider);
//     final userId = ref.watch(currentUserIdProvider);
//
//     final bookingState = userType == UserType.user
//         ? ref.watch(userBookingListProvider(userId))
//         : ref.watch(photographerBookingListProvider(userId));
//
//     return Column(
//       children: [
//         _buildSearchBar(),
//         Expanded(
//           child: _buildBookingContent(bookingState, userType, userId),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: CustomSearchField(
//         controller: _searchController,
//         hintText: '포토그래퍼명으로 검색',
//         showSearchButton: false,
//         onChanged: (value) {
//           setState(() {
//             _searchQuery = value;
//           });
//         },
//         margin: EdgeInsets.zero,
//       ),
//     );
//   }
//
//   Widget _buildBookingContent(
//       BookingListState state, UserType userType, int userId) {
//     if (state.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (state.errorMessage != null) {
//       return BookingErrorWidget(
//         error: state.errorMessage!,
//         onRetry: _loadBookings,
//       );
//     }
//
//     final filteredBookings = _getFilteredBookings(state.bookings);
//
//     if (filteredBookings.isEmpty) {
//       if (_searchQuery.isNotEmpty && state.bookings.isNotEmpty) {
//         return _buildNoSearchResults();
//       }
//       return const BookingEmptyWidget();
//     }
//
//     return RefreshIndicator(
//       onRefresh: () async {
//         if (userType == UserType.user) {
//           await ref.read(userBookingListProvider(userId).notifier).refresh();
//         } else {
//           await ref
//               .read(photographerBookingListProvider(userId).notifier)
//               .refresh();
//         }
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: filteredBookings.length,
//         itemBuilder: (context, index) {
//           final booking = filteredBookings[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: _buildBookingCard(booking, userType, userId),
//           );
//         },
//       ),
//     );
//   }
//
//   List<BookingListItem> _getFilteredBookings(List<BookingListItem> bookings) {
//     if (_searchQuery.isEmpty) return bookings;
//
//     return bookings.where((booking) {
//       return booking.photographerName
//           .toLowerCase()
//           .contains(_searchQuery.toLowerCase());
//     }).toList();
//   }
//
//   Widget _buildBookingCard(
//       BookingListItem booking, UserType userType, int userId) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => _showBookingDetail(booking),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               _buildServiceImage(booking),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildServiceInfo(booking, userType, userId),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceImage(BookingListItem booking) {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey[200],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: booking.photoService?.imageUrl != null
//             ? Image.network(
//                 booking.photoService!.imageUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return _buildImagePlaceholder();
//                 },
//               )
//             : _buildImagePlaceholder(),
//       ),
//     );
//   }
//
//   Widget _buildImagePlaceholder() {
//     return Container(
//       color: Colors.grey[200],
//       child: const Icon(
//         Icons.camera_alt,
//         color: Colors.grey,
//         size: 32,
//       ),
//     );
//   }
//
//   Widget _buildServiceInfo(
//       BookingListItem booking, UserType userType, int userId) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildServiceTitle(booking),
//         const SizedBox(height: 4),
//         _buildPhotographerName(booking),
//         const SizedBox(height: 8),
//         _buildRatingAndStatus(booking),
//         const SizedBox(height: 8),
//         _buildPriceAndAction(booking, userType, userId),
//       ],
//     );
//   }
//
//   Widget _buildServiceTitle(BookingListItem booking) {
//     return Text(
//       booking.photoService?.title ?? '포토 촬영 서비스',
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//     );
//   }
//
//   Widget _buildPhotographerName(BookingListItem booking) {
//     return Text(
//       booking.photographerName,
//       style: TextStyle(
//         fontSize: 14,
//         color: Colors.grey[600],
//       ),
//     );
//   }
//
//   Widget _buildRatingAndStatus(BookingListItem booking) {
//     return Row(
//       children: [
//         _buildRating(booking),
//         const Spacer(),
//         _buildStatusChip(booking),
//       ],
//     );
//   }
//
//   Widget _buildRating(BookingListItem booking) {
//     return Row(
//       children: [
//         const Icon(
//           Icons.star,
//           size: 16,
//           color: Colors.amber,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           booking.photoService?.rating.toStringAsFixed(1) ?? '정보없음',
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatusChip(BookingListItem booking) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: _getStatusColor(booking.status),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         booking.status.description,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPriceAndAction(
//       BookingListItem booking, UserType userType, int userId) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildPrice(booking),
//         if (_shouldShowCancelButton(booking, userType))
//           _buildCancelButton(booking, userType, userId),
//       ],
//     );
//   }
//
//   Widget _buildPrice(BookingListItem booking) {
//     return Text(
//       booking.photoService?.priceRange ?? '정보없음',
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
//
//   bool _shouldShowCancelButton(BookingListItem booking, UserType userType) {
//     return userType == UserType.user && booking.status == BookingStatus.pending;
//   }
//
//   Widget _buildCancelButton(
//       BookingListItem booking, UserType userType, int userId) {
//     return TextButton(
//       onPressed: () => _showCancelDialog(booking, userType, userId),
//       style: TextButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: Text(
//         '취소',
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.red[600],
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor(BookingStatus status) {
//     switch (status) {
//       case BookingStatus.pending:
//         return Colors.orange;
//       case BookingStatus.confirmed:
//         return Colors.green;
//       case BookingStatus.rejected:
//       case BookingStatus.canceled:
//         return Colors.red;
//       case BookingStatus.completed:
//         return Colors.blue;
//       case BookingStatus.reviewed:
//         return Colors.purple;
//     }
//   }
//
//   Widget _buildNoSearchResults() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             '검색 결과가 없습니다',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '"$_searchQuery"에 대한 결과를 찾을 수 없습니다',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextButton(
//             onPressed: () {
//               _searchController.clear();
//               setState(() {
//                 _searchQuery = '';
//               });
//             },
//             child: const Text('검색 초기화'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showBookingDetail(BookingListItem booking) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${booking.photographerName} 예약 상세 화면'),
//       ),
//     );
//   }
//
//   void _showCancelDialog(
//       BookingListItem booking, UserType userType, int userId) {
//     showDialog(
//       context: context,
//       builder: (context) => BookingCancelDialog(
//         booking: booking,
//         onConfirm: () async {
//           if (userType == UserType.user && booking.bookingInfoId != null) {
//             await ref
//                 .read(userBookingListProvider(userId).notifier)
//                 .cancelBooking(booking.bookingInfoId!);
//           }
//
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('예약이 취소되었습니다')),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
