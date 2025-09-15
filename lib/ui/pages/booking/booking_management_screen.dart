import 'package:chakak_flutter/data/models/booking.dart';
import 'package:chakak_flutter/data/models/payment.dart';
import 'package:chakak_flutter/provider/booking/booking_provider.dart';
import 'package:chakak_flutter/provider/payment/payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingManagementScreen extends ConsumerStatefulWidget {
  const BookingManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState
    extends ConsumerState<BookingManagementScreen> {
  int _currentTabIndex = 0; // 0: 예약 현황, 1: 결제 내역

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).loadBookings();
      ref.read(paymentProvider.notifier).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '예약 관리',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '검색어를 입력하세요',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 탭 영역
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTabIndex == 0
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '예약 현황',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _currentTabIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _currentTabIndex == 0
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTabIndex == 1
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '결제 내역',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _currentTabIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _currentTabIndex == 1
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 컨텐츠 영역
          Expanded(
            child: _currentTabIndex == 0
                ? _buildBookingList(bookingState)
                : _buildPaymentList(paymentState),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(BookingState bookingState) {
    if (bookingState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(bookingState.errorMessage!),
            ElevatedButton(
              onPressed: () =>
                  ref.read(bookingProvider.notifier).loadBookings(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (bookingState.bookings.isEmpty) {
      return const Center(
        child: Text('예약 내역이 없습니다'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookingProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookingState.bookings.length,
        itemBuilder: (context, index) {
          final booking = bookingState.bookings[index];
          return _buildBookingItem(booking);
        },
      ),
    );
  }

  Widget _buildPaymentList(PaymentState paymentState) {
    if (paymentState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(paymentState.errorMessage!),
            ElevatedButton(
              onPressed: () =>
                  ref.read(paymentProvider.notifier).loadPayments(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (paymentState.payments.isEmpty) {
      return const Center(
        child: Text('결제 내역이 없습니다'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(paymentProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paymentState.payments.length,
        itemBuilder: (context, index) {
          final payment = paymentState.payments[index];
          return _buildPaymentItem(payment);
        },
      ),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.grey),
            ),
            const SizedBox(width: 16),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.photographerName ?? '포토그래퍼',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: booking.status.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          booking.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.serviceName ?? '사진 촬영 서비스',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '촬영일: ${booking.formattedBookingDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 결제 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: payment.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.payment,
                color: payment.status.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.itemName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: payment.status.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (payment.paymentMethodType != null)
                    Text(
                      payment.paymentMethodType!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '결제일: ${payment.createdAt.year}.${payment.createdAt.month.toString().padLeft(2, '0')}.${payment.createdAt.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (payment.approvedAt != null)
                    Text(
                      '승인일: ${payment.approvedAt!.year}.${payment.approvedAt!.month.toString().padLeft(2, '0')}.${payment.approvedAt!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    payment.formattedAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
