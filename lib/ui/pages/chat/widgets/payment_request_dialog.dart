import 'package:chakak_flutter/provider/global/photographer_profile/photographer_profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../data/models/photo_service/price_option.dart';
import '../../../../data/models/repositories/photo_service_repository.dart';
import '../../../../provider/core/dio_provider.dart';

final photoServiceRepositoryProvider = Provider<PhotoServiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PhotoServiceRepositoryImpl(dio);
});

class PaymentRequestDialog {
  static void show(
    BuildContext context, {
    required Function(String title, int amount, String? description)
        onPaymentRequest,
    required WidgetRef ref,
  }) async {
    List<PhotoService> myPhotoServices = [];

    try {
      final profileState = ref.read(photographerProfileProvider);
      final profile = profileState.profile;

      if (profile != null && profile.id.isNotEmpty) {
        final photoService = ref.read(photoServiceRepositoryProvider);
        final photographerProfileId = int.tryParse(profile.id);

        if (photographerProfileId != null) {
          myPhotoServices = await photoService
              .getServicesByPhotographer(photographerProfileId);
        } else {
          print('포토그래퍼 프로필 ID 변환 실패: ${profile.id}');
        }
      }
    } catch (e) {
      print('포토 서비스 목록을 가져오는 중 오류 발생: $e');
    }

    PhotoService? selectedService;
    PriceOption? selectedPriceOption;
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        '결제 요청',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '포토 서비스 선택',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PhotoService>(
                        value: selectedService,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('서비스를 선택하세요'),
                        ),
                        isExpanded: true,
                        onChanged: (PhotoService? service) {
                          setState(() {
                            selectedService = service;
                            selectedPriceOption = null;
                          });
                        },
                        items: myPhotoServices.map((service) {
                          return DropdownMenuItem<PhotoService>(
                            value: service,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  softWrap: true, // 글자 길면 줄바꿈
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (selectedService != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      '가격 옵션 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PriceOption>(
                          value: selectedPriceOption,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('가격 옵션을 선택하세요'),
                          ),
                          isExpanded: true,
                          onChanged: (PriceOption? option) {
                            setState(() {
                              selectedPriceOption = option;
                            });
                          },
                          items: (selectedService?.priceOptions ?? [])
                              .map((option) {
                            return DropdownMenuItem<PriceOption>(
                              value: option,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option.name ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                    Text(
                                      '${option.price?.toString() ?? '0'}원',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    '추가 설명 (선택사항)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '서비스에 대한 추가 설명을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedService != null &&
                                  selectedPriceOption != null
                              ? () {
                                  final description =
                                      descriptionController.text.trim();
                                  final baseDescription =
                                      '${selectedPriceOption?.name ?? ''}\n'
                                      '${selectedPriceOption?.duration ?? ''} | '
                                      '${selectedPriceOption?.photoCount ?? ''}';
                                  final finalDescription =
                                      description.isNotEmpty
                                          ? '$baseDescription\n\n$description'
                                          : baseDescription;
                                  onPaymentRequest(
                                    selectedService!.title,
                                    selectedPriceOption!.price!,
                                    finalDescription,
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedService != null &&
                                    selectedPriceOption != null
                                ? Colors.blue.shade600
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '결제 요청',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
