import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dtos/review/reviewCreationRequestDto.dart';
import '../../../data/models/booking/booking_list_item.dart';
import '../../../provider/review/review_provider.dart'; // Provider import
import 'widgets/review_star_widget.dart';

class ReviewFormScreen extends ConsumerStatefulWidget {
  final BookingListItem booking;

  const ReviewFormScreen({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends ConsumerState<ReviewFormScreen>
    with TickerProviderStateMixin {
  int _rating = 0;
  int _hoverRating = 0;
  final TextEditingController _controller = TextEditingController();
  late AnimationController _starAnimationController;
  late AnimationController _submitAnimationController;
  bool _isSubmitting = false; // 기존 _isSubmitting 상태 유지

  final List<String> _ratingLabels = [
    '',
    '별로예요 😞',
    '그저그래요 😐',
    '괜찮아요 🙂',
    '좋아요 😊',
    '최고예요! 🤩'
  ];

  final List<Color> _ratingColors = [
    Colors.grey,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    _submitAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitReview() async {
    // ▼▼▼ This is the only new code block being added ▼▼▼
    if (widget.booking.photoService == null ||
        widget.booking.photoService!.id == 0) {
      _showErrorSnackBar("유효하지 않은 서비스 정보입니다. 다시 시도해주세요.");
      // 로딩 중이었다면 상태를 되돌림
      if (_isSubmitting) {
        setState(() {
          _isSubmitting = false;
        });
        if (_submitAnimationController.isAnimating) {
          _submitAnimationController.reverse();
        }
      }
      return;
    }
    // ▲▲▲ End of the new code block ▲▲▲

    if (_rating == 0 || _controller.text.isEmpty) {
      _showErrorSnackBar("별점과 리뷰 내용을 입력해주세요.");
      return;
    }

    setState(() {
      // 기존 로직 유지
      _isSubmitting = true;
    });
    _submitAnimationController.forward(); // 기존 로직 유지

    final reviewRequest = ReviewCreationRequestDto(
      serviceId: widget.booking.photoService!.id, // 이 값이 0이 아니어야 함
      bookingId: widget.booking.bookingInfoId!,
      rating: _rating.toDouble(),
      reviewContent: _controller.text,
    );

    // Provider를 통해 리뷰 생성 요청
    await ref.read(reviewCreationProvider.notifier).createReview(reviewRequest);

    // _isSubmitting = false 및 애니메이션 reverse는 ref.listen에서 처리
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 40,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '리뷰 등록 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '소중한 후기 감사합니다.\n다른 고객들에게 큰 도움이 될거예요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(true); // 리뷰 화면 닫고 true 반환
                  // Provider 상태 초기화는 ref.listen에서 담당
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildServiceCard, _buildRatingSection, _buildReviewInput 메서드는 기존 코드 유지
  Widget _buildServiceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.booking.photoService?.imageUrl ??
                    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.photoService?.title ?? '포토그래피 서비스',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.booking.otherPartyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '0.0 (0)', // 이 부분은 실제 데이터로 채워져야 합니다.
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '200,000원~', // 이 부분은 실제 데이터로 채워져야 합니다.
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            '서비스는 어떠셨나요?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTapDown: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);
              double starAreaWidth = 5 * 50.0;
              double screenWidth = MediaQuery.of(context).size.width;
              double startX = (screenWidth - starAreaWidth) / 2;

              if (localPosition.dx >= startX &&
                  localPosition.dx <= startX + starAreaWidth) {
                int newRating =
                    ((localPosition.dx - startX) / 50).ceil().clamp(1, 5);
                setState(() {
                  _rating = newRating;
                  _hoverRating = 0;
                });
                _starAnimationController.forward().then((_) {
                  _starAnimationController.reverse();
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                int starNumber = index + 1;
                bool isFilled =
                    starNumber <= (_hoverRating > 0 ? _hoverRating : _rating);
                return AnimatedBuilder(
                  animation: _starAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isFilled
                          ? 1.0 + (_starAnimationController.value * 0.2)
                          : 1.0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = starNumber;
                            _hoverRating = 0;
                          });
                          _starAnimationController.forward().then((_) {
                            _starAnimationController.reverse();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            size: 40,
                            color: isFilled
                                ? _ratingColors[_rating > 0 ? _rating : 1]
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _rating > 0
                ? Text(
                    _ratingLabels[_rating],
                    key: ValueKey(_rating),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _ratingColors[_rating],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInput() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '리뷰를 남겨주세요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: "서비스에 대한 솔직한 후기를 작성해주세요.\n다른 고객분들에게 큰 도움이 됩니다! ✨",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
                counterStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReviewCreationState>(reviewCreationProvider, (previous, next) {
      final nextStatus = next.status;

      if (nextStatus == ReviewCreationStatus.success) {
        if (mounted) {
          _showSuccessDialog(); // 다이얼로그의 확인 버튼이 pop(true)를 호출
          setState(() {
            _isSubmitting = false;
          });
        }
        if (_submitAnimationController.isAnimating) {
          _submitAnimationController.reverse();
        }
        ref.read(reviewCreationProvider.notifier).resetState();
      } else if (nextStatus == ReviewCreationStatus.error) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        if (_submitAnimationController.isAnimating) {
          _submitAnimationController.reverse();
        }
        if (next.errorMessage != null) {
          _showErrorSnackBar(next.errorMessage!);
        } else {
          _showErrorSnackBar("알 수 없는 오류로 리뷰 등록에 실패했습니다.");
        }
        ref.read(reviewCreationProvider.notifier).resetState();
      }
      // ReviewCreationStatus.loading 상태는 _submitReview에서 _isSubmitting = true로 이미 처리됨
    });

    // ElevatedButton의 상태는 _isSubmitting 변수를 직접 사용 (기존 로직 유지)

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "리뷰 작성",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildServiceCard(),
            const SizedBox(height: 20),
            _buildRatingSection(),
            const SizedBox(height: 30),
            _buildReviewInput(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _submitAnimationController, // 기존 애니메이션 컨트롤러 유지
          builder: (context, child) {
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _isSubmitting ? null : _submitReview, // _isSubmitting 사용
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitting
                      ? Colors.grey.shade400
                      : Colors.black87, // _isSubmitting 사용
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting // _isSubmitting 사용
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '등록 중...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        '리뷰 등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
