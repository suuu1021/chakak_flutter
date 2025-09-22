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
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'serviceId': serviceId,
      'rating': rating,
    };
    if (reviewContent != null && reviewContent!.isNotEmpty) {
      map['reviewContent'] = reviewContent;
    }
    return map;
  }
}
