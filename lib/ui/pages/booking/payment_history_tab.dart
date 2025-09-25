import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../data/models/payment.dart';
import '../../../data/dtos/payment/payment_dto.dart';
import '../../../provider/core/dio_provider.dart'; // ✅ dioProvider import 추가

final paymentHistoryProvider = FutureProvider<List<Payment>>((ref) async {
  final dio = ref.watch(dioProvider);

  final response = await dio.get('/api/payment/user');

  final body = response.data;
  final dynamic payload = body is Map
      ? (body['data'] ?? body['response'] ?? body['body'] ?? body)
      : body;

  List<dynamic> list;
  if (payload is Map && payload['content'] is List) {
    list = payload['content'];
  } else if (payload is List) {
    list = payload;
  } else {
    list = const [];
  }

  return list
      .map((e) => PaymentDto.fromJson(e as Map<String, dynamic>).toModel())
      .toList();
});

class PaymentHistoryTab extends ConsumerStatefulWidget {
  const PaymentHistoryTab({super.key});

  @override
  ConsumerState<PaymentHistoryTab> createState() => _PaymentHistoryTabState();
}

class _PaymentHistoryTabState extends ConsumerState<PaymentHistoryTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
    final paymentsAsync = ref.watch(paymentHistoryProvider);

    return paymentsAsync.when(
      data: (payments) {
        final filteredPayments = _getFilteredPayments(payments);

        if (filteredPayments.isEmpty) {
          if (_searchQuery.isNotEmpty && payments.isNotEmpty) {
            return _buildNoSearchResults();
          }
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(paymentHistoryProvider);
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("에러 발생: $e")),
    );
  }

  List<Payment> _getFilteredPayments(List<Payment> payments) {
    if (_searchQuery.isEmpty) return payments;

    final q = _searchQuery.toLowerCase();
    return payments.where((p) {
      final title = p.itemName.toLowerCase();
      final orderId = (p.partnerOrderId ?? '').toLowerCase();
      return title.contains(q) || orderId.contains(q);
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
              '주문번호: ${payment.partnerOrderId ?? '-'}',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.gray400),
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
          Icon(Icons.search_off, size: 64, color: AppColors.gray400),
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
            style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
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
