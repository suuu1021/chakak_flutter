import 'package:flutter/material.dart';

import '../../../_core/constants/app_colors.dart';
import 'community_detail_page.dart';

// 더미 데이터 모델
class Post {
  final String id;
  final String title;
  final String author;
  final String authorBadge;
  final int views;
  final int comments;
  final String timeAgo;
  final String? thumbnailUrl;
  final String category;

  const Post({
    required this.id,
    required this.title,
    required this.author,
    this.authorBadge = '',
    required this.views,
    required this.comments,
    required this.timeAgo,
    this.thumbnailUrl,
    this.category = '일반',
  });
}

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  String selectedCategory = '전체 인기글';
  static const String adminBadge = '✅';

  // 스냅촬영 플랫폼에 맞는 더미 데이터
  final List<Post> dummyPosts = [
    Post(
      id: '1',
      title: '스냅촬영 작가님 추천 리스트 공지사항',
      author: '찰칵관리팀',
      authorBadge: adminBadge,
      views: 8420,
      comments: 67,
      timeAgo: '1일전',
      category: '공지',
    ),
    Post(
      id: '2',
      title: '프로필 촬영 베스트 작가님들 소개',
      author: '찰칵관리팀',
      authorBadge: adminBadge,
      views: 12350,
      comments: 234,
      timeAgo: '2일전',
      category: '추천',
    ),
    Post(
      id: '3',
      title: '한강 스냅촬영 명소 BEST 10 (2025년 버전)',
      author: '찰칵관리팀',
      authorBadge: adminBadge,
      views: 15420,
      comments: 189,
      timeAgo: '3일전',
      category: '추천',
    ),
    Post(
      id: '4',
      title: '연남동 카페거리에서 찍은 커플스냅 후기',
      author: '셔터러버',
      views: 2340,
      comments: 45,
      timeAgo: '5시간전',
      thumbnailUrl:
          'https://images.pexels.com/photos/17490115/pexels-photo-17490115.jpeg',
    ),
    Post(
      id: '5',
      title: '졸업사진 촬영 완전 만족! 작가님 찬양해요',
      author: '캠퍼스걸',
      views: 1890,
      comments: 28,
      timeAgo: '8시간전',
      thumbnailUrl:
          'https://images.pexels.com/photos/2513989/pexels-photo-2513989.jpeg',
    ),
    Post(
      id: '6',
      title: '벚꽃 시즌 스냅촬영 예약 꿀팁 공유',
      author: '봄날사진관',
      views: 3250,
      comments: 72,
      timeAgo: '12시간전',
    ),
    Post(
      id: '7',
      title: '웨딩스냅 로케이션 추천드려요 (경복궁 편)',
      author: '웨딩포토그래퍼',
      views: 4120,
      comments: 56,
      timeAgo: '1일전',
      thumbnailUrl:
          'https://images.pexels.com/photos/27936090/pexels-photo-27936090.jpeg',
    ),
    Post(
      id: '8',
      title: '프로필사진 보정 전후 비교샷',
      author: '리터치마스터',
      views: 5680,
      comments: 93,
      timeAgo: '1일전',
      thumbnailUrl:
          'https://images.pexels.com/photos/5528835/pexels-photo-5528835.jpeg',
    ),
    Post(
      id: '9',
      title: '가성비 갑 실내스튜디오 발견했어요!',
      author: '스튜디오헌터',
      views: 2890,
      comments: 41,
      timeAgo: '2일전',
    ),
    Post(
      id: '10',
      title: '야외 스냅촬영 시 날씨 대비 준비물 리스트',
      author: '포토프렙',
      views: 1650,
      comments: 23,
      timeAgo: '2일전',
    ),
    Post(
      id: '11',
      title: '홍대 인스타 핫플레이스 스냅촬영 스팟 모음',
      author: '홍대포토투어',
      views: 3780,
      comments: 88,
      timeAgo: '3시간전',
      thumbnailUrl:
          'https://images.pexels.com/photos/33437315/pexels-photo-33437315.jpeg',
    ),
    Post(
      id: '12',
      title: '가족사진 찍을 때 꼭 알아야 할 포즈 가이드',
      author: '패밀리포토',
      views: 2145,
      comments: 34,
      timeAgo: '6시간전',
    ),
    Post(
      id: '13',
      title: '신상 작가님 발견! 감성 스냅 실력 대박',
      author: '스냅매니아',
      views: 1567,
      comments: 52,
      timeAgo: '10시간전',
      thumbnailUrl:
          'https://images.pexels.com/photos/33892985/pexels-photo-33892985.jpeg',
    ),
    Post(
      id: '14',
      title: '강남 스튜디오 가격 비교 후기 (실제 이용)',
      author: '스튜디오리뷰어',
      views: 4320,
      comments: 76,
      timeAgo: '14시간전',
    ),
    Post(
      id: '15',
      title: '청담동 카페에서 프로필 촬영한 썰',
      author: '청담걸',
      views: 2890,
      comments: 43,
      timeAgo: '18시간전',
      thumbnailUrl: 'https://example.com/thumb7.jpg',
    ),
    Post(
      id: '16',
      title: '한복 스냅촬영 소품 추천 리스트',
      author: '한복스냅러버',
      views: 1890,
      comments: 29,
      timeAgo: '1일전',
    ),
    Post(
      id: '17',
      title: '우천시 실내 촬영 대체 장소 추천',
      author: '날씨걱정마',
      views: 2340,
      comments: 38,
      timeAgo: '1일전',
      thumbnailUrl:
          'https://images.pexels.com/photos/6635767/pexels-photo-6635767.jpeg',
    ),
    Post(
      id: '18',
      title: '커플 스냅촬영 의상 컬러 매칭 꿀팁',
      author: '커플포토코디',
      views: 3456,
      comments: 67,
      timeAgo: '2일전',
    ),
    Post(
      id: '19',
      title: '반려동물과 함께하는 가족사진 노하우',
      author: '펫포토그래퍼',
      views: 1789,
      comments: 45,
      timeAgo: '2일전',
      thumbnailUrl:
          'https://images.pexels.com/photos/416160/pexels-photo-416160.jpeg',
    ),
    Post(
      id: '20',
      title: '겨울 야외 스냅촬영 방한 준비물 체크리스트',
      author: '겨울스냅전문',
      views: 2567,
      comments: 31,
      timeAgo: '3일전',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // 제목 섹션
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '스냅촬영 커뮤니티',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '사진작가 추천, 장소 정보, 후기를 공유해요',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 게시글 목록
          Expanded(
            child: ListView.builder(
              itemCount: dummyPosts.length,
              itemBuilder: (context, index) {
                return PostListItem(post: dummyPosts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostListItem extends StatelessWidget {
  final Post post;

  const PostListItem({super.key, required this.post});

  Color _getCategoryColor(String category) {
    switch (category) {
      case '공지':
        return AppColors.error;
      case '추천':
        return AppColors.primary;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityDetailPage(post: post),
          ),
        );
      },
      child: Container(
        color: AppColors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽 콘텐츠
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 카테고리 태그
                            if (post.category == '공지' ||
                                post.category == '추천') ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(post.category),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.category,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],

                            // 제목
                            Text(
                              post.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // 메타 정보
                        Row(
                          children: [
                            // 추천수
                            Row(
                              children: [
                                const Icon(Icons.thumb_up_outlined,
                                    color: AppColors.primary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  (post.views ~/ 100).toString(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // 댓글수
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline,
                                    color: AppColors.secondary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  post.comments.toString(),
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // 작성자
                            Text(
                              post.author,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (post.authorBadge.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text(
                                post.authorBadge,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                            // 조회수
                            Row(
                              children: [
                                const Icon(Icons.visibility_outlined,
                                    color: AppColors.textTertiary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  post.views.toString(),
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // 시간
                            Text(
                              post.timeAgo,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 썸네일 (있는 경우)
                  if (post.thumbnailUrl != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          post.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.camera_alt,
                              color: AppColors.gray400,
                              size: 24,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.gray400),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 구분선
            Container(
              height: 1,
              color: AppColors.divider,
              margin: const EdgeInsets.only(left: 16),
            ),
          ],
        ),
      ),
    );
  }
}
