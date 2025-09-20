import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../data/models/payment.dart';

class PaymentHistoryTab extends ConsumerStatefulWidget {
  const PaymentHistoryTab({super.key});

  @override
  ConsumerState<PaymentHistoryTab> createState() => _PaymentHistoryTabState();
}

class _PaymentHistoryTabState extends ConsumerState<PaymentHistoryTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 스냅촬영 플랫폼에 맞는 더미 결제 데이터
  final List<Payment> dummyPayments = [
    Payment(
      paymentId: 1,
      tid: 'T1234567890',
      partnerOrderId: 'SNAP_001_20250920',
      partnerUserId: 'user_001',
      itemName: '커플 스냅촬영 - 김포토 작가',
      totalAmount: 250000,
      vatAmount: 22727,
      taxFreeAmount: 0,
      status: PaymentStatus.approved,
      paymentMethodType: 'CARD',
      aid: 'A1234567890',
      createdAt: DateTime(2025, 9, 20, 14, 30),
      approvedAt: DateTime(2025, 9, 20, 14, 31),
    ),
    Payment(
      paymentId: 2,
      tid: 'T2345678901',
      partnerOrderId: 'SNAP_002_20250918',
      partnerUserId: 'user_002',
      itemName: '프로필 촬영 - 이스냅 작가',
      totalAmount: 200000,
      vatAmount: 18182,
      taxFreeAmount: 0,
      status: PaymentStatus.ready,
      paymentMethodType: 'MONEY',
      createdAt: DateTime(2025, 9, 18, 10, 0),
    ),
    Payment(
      paymentId: 3,
      tid: 'T3456789012',
      partnerOrderId: 'SNAP_003_20250915',
      partnerUserId: 'user_003',
      itemName: '웨딩 스냅촬영 - 박셔터 작가',
      totalAmount: 500000,
      vatAmount: 45455,
      taxFreeAmount: 0,
      status: PaymentStatus.approved,
      paymentMethodType: 'CARD',
      aid: 'A3456789012',
      createdAt: DateTime(2025, 9, 15, 16, 0),
      approvedAt: DateTime(2025, 9, 15, 16, 2),
    ),
    Payment(
      paymentId: 4,
      tid: 'T4567890123',
      partnerOrderId: 'SNAP_004_20250912',
      partnerUserId: 'user_004',
      itemName: '가족사진 촬영 - 최프레임 작가',
      totalAmount: 300000,
      vatAmount: 27273,
      taxFreeAmount: 0,
      status: PaymentStatus.canceled,
      paymentMethodType: 'BANK',
      createdAt: DateTime(2025, 9, 12, 13, 30),
    ),
    Payment(
      paymentId: 5,
      tid: 'T5678901234',
      partnerOrderId: 'SNAP_005_20250910',
      partnerUserId: 'user_005',
      itemName: '졸업사진 촬영 - 정렌즈 작가',
      totalAmount: 150000,
      vatAmount: 13636,
      taxFreeAmount: 0,
      status: PaymentStatus.failed,
      paymentMethodType: 'CARD',
      createdAt: DateTime(2025, 9, 10, 11, 0),
    ),
    Payment(
      paymentId: 6,
      tid: 'T6789012345',
      partnerOrderId: 'SNAP_006_20250908',
      partnerUserId: 'user_006',
      itemName: '반려동물 촬영 - 한캡처 작가',
      totalAmount: 180000,
      vatAmount: 16364,
      taxFreeAmount: 0,
      status: PaymentStatus.approved,
      paymentMethodType: 'MONEY',
      aid: 'A6789012345',
      createdAt: DateTime(2025, 9, 8, 15, 30),
      approvedAt: DateTime(2025, 9, 8, 15, 31),
    ),
    Payment(
      paymentId: 7,
      tid: 'T7890123456',
      partnerOrderId: 'SNAP_007_20250905',
      partnerUserId: 'user_007',
      itemName: '브랜딩 촬영 - 윤아웃풋 작가',
      totalAmount: 400000,
      vatAmount: 36364,
      taxFreeAmount: 0,
      status: PaymentStatus.approved,
      paymentMethodType: 'CARD',
      aid: 'A7890123456',
      createdAt: DateTime(2025, 9, 5, 9, 0),
      approvedAt: DateTime(2025, 9, 5, 9, 1),
    ),
    Payment(
      paymentId: 8,
      tid: 'T8901234567',
      partnerOrderId: 'SNAP_008_20250903',
      partnerUserId: 'user_008',
      itemName: '임신 기념 촬영 - 송포커스 작가',
      totalAmount: 250000,
      vatAmount: 22727,
      taxFreeAmount: 0,
      status: PaymentStatus.approved,
      paymentMethodType: 'BANK',
      aid: 'A8901234567',
      createdAt: DateTime(2025, 9, 3, 17, 0),
      approvedAt: DateTime(2025, 9, 3, 17, 2),
    ),
    Payment(
      paymentId: 9,
      tid: 'T9012345678',
      partnerOrderId: 'SNAP_009_20250901',
      partnerUserId: 'user_009',
      itemName: '한복 돌잔치 촬영 - 한전통 작가',
      totalAmount: 450000,
      vatAmount: 40909,
      taxFreeAmount: 0,
      status: PaymentStatus.approved,
      paymentMethodType: 'CARD',
      aid: 'A9012345678',
      createdAt: DateTime(2025, 9, 1, 14, 0),
      approvedAt: DateTime(2025, 9, 1, 14, 1),
    ),
    Payment(
      paymentId: 10,
      tid: 'T0123456789',
      partnerOrderId: 'SNAP_010_20250830',
      partnerUserId: 'user_010',
      itemName: '야외 커플 촬영 - 자연스냅 작가',
      totalAmount: 280000,
      vatAmount: 25455,
      taxFreeAmount: 0,
      status: PaymentStatus.ready,
      paymentMethodType: 'MONEY',
      createdAt: DateTime(2025, 8, 30, 11, 30),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildPaymentContent(),
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
          hintText: '결제 내역 검색',
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

  Widget _buildPaymentContent() {
    final filteredPayments = _getFilteredPayments(dummyPayments);

    if (filteredPayments.isEmpty) {
      if (_searchQuery.isNotEmpty && dummyPayments.isNotEmpty) {
        return _buildNoSearchResults();
      }
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // 새로고침 로직
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Container(
        color: AppColors.gray200,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = filteredPayments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildPaymentCard(payment),
            );
          },
        ),
      ),
    );
  }

  List<Payment> _getFilteredPayments(List<Payment> payments) {
    if (_searchQuery.isEmpty) return payments;

    return payments.where((payment) {
      return payment.itemName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          payment.partnerOrderId
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    payment.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(payment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '주문번호: ${payment.partnerOrderId}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '결제일시: ${_formatDateTime(payment.createdAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (payment.approvedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                '승인일시: ${_formatDateTime(payment.approvedAt!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  payment.formattedAmount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (payment.paymentMethodType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getPaymentMethodText(payment.paymentMethodType!),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.ready:
        return AppColors.primary; // 결제준비
      case PaymentStatus.approved:
        return AppColors.secondary; // 결제승인완료
      case PaymentStatus.canceled:
        return AppColors.gray600; // 결제취소
      case PaymentStatus.failed:
        return AppColors.textSecondary; // 결제실패
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          const Text(
            '결제 내역이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 번째 촬영을 예약해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
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
          const Text(
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodText(String method) {
    switch (method.toUpperCase()) {
      case 'MONEY':
        return '카카오머니';
      case 'CARD':
        return '카드';
      case 'BANK':
        return '계좌이체';
      default:
        return method;
    }
  }
}
