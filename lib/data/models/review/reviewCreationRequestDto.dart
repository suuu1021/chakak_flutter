class ReviewCreationRequestDto {
  final int serviceId;
  final int bookingId;
  final double rating;
  final String? reviewContent;

  ReviewCreationRequestDto({
    required this.serviceId,
    required this.bookingId,
    required this.rating,
    this.reviewContent,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['booking_id'] = bookingId;
    data['rating'] = rating;
    if (reviewContent != null && reviewContent!.isNotEmpty) {
      data['review_content'] = reviewContent;
    }
    return data;
  }
}
