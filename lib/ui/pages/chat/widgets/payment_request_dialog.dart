import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../data/models/photo_service/price_option.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../../../provider/chat/chat_provider.dart';

class PaymentRequestDialog {
  static void show(
    BuildContext context, {
    required Function(
      String title,
      int amount,
      String? description,
      int photoServiceInfoId,
      int priceInfoId,
    ) onPaymentRequest,
    required WidgetRef ref,
  }) async {
    List<PhotoService> myPhotoServices = [];
    final ScrollController scrollController = ScrollController();

    try {
      final session = ref.read(sessionProvider);
      final sessionUserId = session.userId;

      if (sessionUserId != null) {
        final photoService = ref.read(photoServiceRepositoryProvider);

        // 1단계: userId로 photographerId 매핑
        final photographerId =
            await photoService.getPhotographerIdByUserId(sessionUserId);

        if (photographerId != null) {
          // 2단계: photographerId로 포토서비스 조회
          myPhotoServices =
              await photoService.getServicesByPhotographer(photographerId);

          print(
              '[PaymentRequestDialog] 매핑 성공: userId($sessionUserId) → photographerId($photographerId)');
          print('[PaymentRequestDialog] 로드된 서비스 개수: ${myPhotoServices.length}');
          if (myPhotoServices.isNotEmpty) {
            print(
                '[PaymentRequestDialog] photographer.id: ${myPhotoServices.first.photographerId}');
          }
        } else {
          print('[PaymentRequestDialog] 매핑 실패: photographerId를 찾을 수 없습니다');
        }
      } else {
        print('세션 사용자 ID가 유효하지 않습니다.');
      }
    } catch (e) {
      print('Failed to load services: $e');
    }

    showDialog(
      context: context,
      builder: (context) => _PaymentRequestDialogContent(
        myPhotoServices: myPhotoServices,
        onPaymentRequest: onPaymentRequest,
        scrollController: scrollController,
      ),
    );
  }
}

class _PaymentRequestDialogContent extends ConsumerStatefulWidget {
  final List<PhotoService> myPhotoServices;
  final Function(
    String title,
    int amount,
    String? description,
    int photoServiceInfoId,
    int priceInfoId,
  ) onPaymentRequest;
  final ScrollController scrollController;

  const _PaymentRequestDialogContent({
    Key? key,
    required this.myPhotoServices,
    required this.onPaymentRequest,
    required this.scrollController,
  }) : super(key: key);

  @override
  _PaymentRequestDialogContentState createState() =>
      _PaymentRequestDialogContentState();
}

class _PaymentRequestDialogContentState
    extends ConsumerState<_PaymentRequestDialogContent> {
  PhotoService? selectedService;
  PriceOption? selectedPriceOption;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onServiceSelected(PhotoService service) {
    setState(() {
      if (selectedService?.id == service.id) {
        selectedService = null;
        selectedPriceOption = null;
      } else {
        selectedService = service;
        selectedPriceOption = null;
      }
    });
  }

  void _onPriceOptionSelected(PriceOption option) {
    setState(() {
      if (selectedPriceOption != null &&
          selectedPriceOption!.name == option.name &&
          selectedPriceOption!.price == option.price) {
        selectedPriceOption = null;
      } else {
        selectedPriceOption = option;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '결제 요청',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '서비스 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.myPhotoServices.isEmpty)
                const Center(
                  child: Text(
                    '등록된 서비스가 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.myPhotoServices.length,
                itemBuilder: (context, index) {
                  final service = widget.myPhotoServices[index];
                  final isSelected = selectedService?.id == service.id;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(service.title),
                      subtitle: Text(service.priceRange),
                      onTap: () => _onServiceSelected(service),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: Colors.blue.shade600)
                          : null,
                    ),
                  );
                },
              ),
              if (selectedService != null) ...[
                const SizedBox(height: 24),
                const Text(
                  '가격 옵션 선택',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedService!.availableOptions.length,
                  itemBuilder: (context, index) {
                    final option = selectedService!.availableOptions[index];
                    final isSelected = selectedPriceOption != null &&
                        selectedPriceOption!.name == option.name &&
                        selectedPriceOption!.price == option.price;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text('${option.name} (${option.price}원)'),
                        onTap: () => _onPriceOptionSelected(option),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: Colors.blue.shade600)
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '요청 내용 (선택)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: '특별히 요청하고 싶은 내용을 적어주세요.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedService != null &&
                            selectedPriceOption != null
                        ? () {
                            final finalDescription =
                                _descriptionController.text.isEmpty
                                    ? '결제 요청'
                                    : _descriptionController.text;

                            final priceInfoId = selectedPriceOption!.id ?? 0;

                            widget.onPaymentRequest(
                              selectedService!.title,
                              selectedPriceOption!.price,
                              finalDescription,
                              selectedService!.id,
                              priceInfoId,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedService != null && selectedPriceOption != null
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
            ],
          ),
        ),
      ),
    );
  }
}
