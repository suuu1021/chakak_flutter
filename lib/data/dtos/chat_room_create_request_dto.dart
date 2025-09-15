class ChatRoomCreateRequestDto {
  final int photographerProfileId;

  ChatRoomCreateRequestDto({required this.photographerProfileId});

  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': photographerProfileId,
    };
  }
}
