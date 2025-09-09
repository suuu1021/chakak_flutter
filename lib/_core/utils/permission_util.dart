//
//
// // 권한 관리 전용 유틸 클래스
//
// class PermissionUtil {
//   // 권한 로직 설계
//   // 1. 로그인 여부 체크
//   // 2. 게시글 작성자와 현재 사용자 id 비교
//   // 3. 관리자 권한 체크(옵션)
//
//   static bool canEditPost(User? currentUser, Post post) {
//     // 1단계
//     if (currentUser == null) {
//       return false;
//     }
//     // 2단계
//     bool isOwner = currentUser.id == post.user.id;
//     // 3단계 (관리자 사용시 )
//     // bool isAdmin = currentUser.role == 'ADMIN';
//     return isOwner;
//   }
//
//   // 게시글 삭제 권한 확인
//   static bool canDeletePost(User? currentUser, Post post) {
//     // 삭제 권한에서 시간을 추가하고 싶다면? (24시간 이후 삭제 불가)
//     // DateTime createdAt = post.createdAt;
//     // Duration difference = DateTime.now().difference(createdAt);
//     // difference.inHours < 24;
//     return canEditPost(currentUser, post);
//   }
//
//   // String action = "수정, 삭제, 댓글 작성 등"
//   static String getNoPermissionMessage(String action) {
//     return "이 게시글을 ${action}할 권한이 없습니다";
//   }
// }
