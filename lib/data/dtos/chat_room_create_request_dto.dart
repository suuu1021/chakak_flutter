class ChatRoomCreateRequestDto {
  final int? photographerProfileId;
  final int? userProfileId;

  ChatRoomCreateRequestDto({this.photographerProfileId, this.userProfileId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (photographerProfileId != null) {
      data['photographerProfileId'] = photographerProfileId;
    }
    if (userProfileId != null) {
      data['userProfileId'] = userProfileId;
    }
    return data;
  }
}
