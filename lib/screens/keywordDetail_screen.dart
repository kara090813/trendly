import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import '../models/_models.dart';
import '../services/api_service.dart';
import '../widgets/_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 공통 스타일을 정의한 클래스
class DetailStyles {
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration insetDecoration = BoxDecoration(
    color: Color(0xFFFAFAFA),
    borderRadius: BorderRadius.circular(15.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(-2, -2),
      ),
    ],
  );

  static final BoxDecoration commentDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(15.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        spreadRadius: 0,
        offset: Offset(2, 2),
      ),
    ],
  );
}

class KeywordDetailScreen extends StatefulWidget {
  final int keywordId;

  const KeywordDetailScreen({
    Key? key,
    required this.keywordId,
  }) : super(key: key);

  @override
  State<KeywordDetailScreen> createState() => _KeywordDetailScreenState();
}

class _KeywordDetailScreenState extends State<KeywordDetailScreen> {
  final ApiService _apiService = ApiService();
  Keyword? _keyword;
  DiscussionRoom? _discussionRoom;
  List<Comment>? _comments;
  bool _isLoading = true;
  String? _error;
  String _selectedSummaryType = '3줄';
  bool _isNewsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadKeywordDetails();
  }

  Future<void> _loadKeywordDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 키워드 ID로 상세 정보 로드
      final keyword = await _apiService.getKeywordById(widget.keywordId);

      // 현재 활성화된 토론방 정보 로드
      DiscussionRoom? discussionRoom;
      List<Comment>? comments;

      try {
        if (keyword.currentDiscussionRoomId > 0) {
          // 토론방 정보가 있는 경우 댓글 목록 가져오기 (인기순으로 변경)
          comments = await _apiService.getDiscussionComments(keyword.currentDiscussionRoomId, isPopular: true);

          // 토론방 정보도 가져오기
          try {
            discussionRoom = await _apiService.getDiscussionRoomById(keyword.currentDiscussionRoomId);
          } catch (e) {
            print('토론방 상세 정보 로드 실패: $e');
          }
        }
      } catch (e) {
        print('토론방 정보 로드 실패: $e');
      }

      // 마운트된 상태일 때만 setState 호출
      if (mounted) {
        setState(() {
          _keyword = keyword;
          _discussionRoom = discussionRoom;
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '키워드 정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onSummaryTypeChanged(String type) {
    setState(() {
      _selectedSummaryType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9EC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _keyword == null
          ? const Center(child: Text('키워드 정보가 없습니다.'))
          : _buildOptimizedDetailContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadKeywordDetails,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // CustomScrollView 및 SliverAppBar 사용하여 최적화
  Widget _buildOptimizedDetailContent() {
    return CustomScrollView(
      // 키 추가하여 스크롤 포지션 유지
      key: PageStorageKey('keywordDetail_${widget.keywordId}'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        // SliverAppBar 수정 - 내부 구조 간소화
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 8,
          expandedHeight: 0,
          toolbarHeight: 54.h,
          centerTitle: true, //
          automaticallyImplyLeading: false, // 기본 백버튼 비활성화
          // 헤더 부분을 title 대신 flexibleSpace로 구현 (더 유연한 레이아웃)
          flexibleSpace: SafeArea(
            child: _buildSimplifiedHeader(),
          ),
          title: null, // title 속성 사용하지 않음
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(14.r),
              bottomRight: Radius.circular(14.r),
            ),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),

        // 여기서 SliverPadding의 vertical 패딩 제거
        // 콘텐츠에 SafeArea 적용
        SliverSafeArea(
          top: false, // 상단은 이미 AppBar에서 처리했으므로 제외
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSummarySection(),
              _buildRelatedNewsSection(),
              _buildDiscussionReactionSection(),
              _buildTopDiscussionsSection(),
              SizedBox(height: 20.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSimplifiedHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical:10.h, horizontal: 16.w),
      child: Row(
        children: [
          // 1. 백버튼 (좌측)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 22.sp,
                  color: Color(0xFF19B3F6),
                ),
              ),
            ),
          ),

          // 2. 타이틀과 카테고리 (중앙)
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 키워드에 더 많은 공간 할당
                      child: AutoSizeText(
                        _keyword!.keyword,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        minFontSize: 10,
                        stepGranularity: 1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      flex: 1, // 카테고리에 더 적은 공간 할당
                      child: AutoSizeText(
                        '('+_keyword!.category+')',
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.grey[600],
                        ),
                        minFontSize: 8,
                        stepGranularity: 1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. 우측 여백 (균형을 맞추기 위한 빈 공간)
          SizedBox(width: 30.w),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: DetailStyles.cardDecoration,
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 실검 요약 타이틀
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Row(
                  children: [
                    Text(
                      '실검 요약',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    DetailSummaryToggleWidget(
                      currentType: _selectedSummaryType,
                      onChanged: _onSummaryTypeChanged,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              Divider(
                color: Color(0xFFE2E2E2),
                thickness: 1,
                indent: 4,
                endIndent: 4,
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                child: _buildFormattedSummaryContent(),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // 요약 내용 생성
  Widget _buildFormattedSummaryContent() {
    switch (_selectedSummaryType) {
      case '3줄':
        if (_keyword!.type1.isEmpty) {
          return Text('요약 내용이 없습니다.');
        }
        // 반복문 대신 map과 spread 연산자 활용
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._keyword!.type1.asMap().entries.map((entry) {
              int index = entry.key;
              String content = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < _keyword!.type1.length - 1 ? 15.h : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      case '짧은 글':
        return Text(
          _keyword!.type2,
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.5,
          ),
        );
      case '긴 글':
        return Text(
          _keyword!.type3,
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.5,
          ),
        );
      default:
        return Text('요약 내용이 없습니다.');
    }
  }

  // 토론방 반응 섹션 - discussionHome 컴포넌트 스타일로 변경
  Widget _buildDiscussionReactionSection() {
    // 토론방 반응 데이터 계산
    final int positiveCount = _discussionRoom?.positiveCount ?? 0;
    final int neutralCount = _discussionRoom?.neutralCount ?? 0;
    final int negativeCount = _discussionRoom?.negativeCount ?? 0;
    final int totalCount = positiveCount + neutralCount + negativeCount;

    // 퍼센티지 계산 (총합이 0인 경우 예외 처리)
    final double positiveRatio = totalCount > 0 ? (positiveCount / totalCount * 100) : 0;
    final double neutralRatio = totalCount > 0 ? (neutralCount / totalCount * 100) : 0;
    final double negativeRatio = totalCount > 0 ? (negativeCount / totalCount * 100) : 0;

    // 표시할 퍼센티지 (반올림하여 정수로 표시)
    final int positivePercent = positiveRatio.round();
    final int neutralPercent = neutralRatio.round();
    final int negativePercent = negativeRatio.round();

    // 토론방 반응 요약 텍스트
    final String summaryText = _discussionRoom?.commentSummary ??
        '${_keyword!.keyword}에 대한 토론방 반응을 분석한 결과입니다.';

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: DetailStyles.cardDecoration,
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '토론방 반응',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),

              if (totalCount > 0)
              // 반응이 있는 경우 그래프 표시
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 긍정/중립/부정 그래프 - discussionHome 스타일로 변경
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Container(
                        height: 8.h,
                        child: Row(
                          children: [
                            // 긍정 부분 (블루 컬러)
                            _reactionSegment(positiveRatio / 100, const Color(0xFF00AEEF)),
                            // 중립 부분 (회색)
                            _reactionSegment(neutralRatio / 100, Colors.grey.shade400),
                            // 부정 부분 (빨간색)
                            _reactionSegment(negativeRatio / 100, const Color(0xFFFF5A5F)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // 긍정/중립/부정 레이블
                    Row(
                      children: [
                        _reactionLabel('긍정', '$positivePercent%', const Color(0xFF00AEEF)),
                        SizedBox(width: 16.w),
                        _reactionLabel('중립', '$neutralPercent%', Colors.grey.shade600),
                        SizedBox(width: 16.w),
                        _reactionLabel('부정', '$negativePercent%', const Color(0xFFFF5A5F)),
                      ],
                    ),
                  ],
                )
              else
              // 반응이 없는 경우 안내 메시지 표시
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '아직 토론방 반응이 없습니다.',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

              Divider(
                color: Colors.grey[300],
                thickness: 1,
                height: 30.h,
              ),

              Text(
                summaryText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 반응 그래프의 세그먼트 생성
  Widget _reactionSegment(double value, Color color) {
    return Expanded(
      flex: (value * 100).toInt() > 0 ? (value * 100).toInt() : 1, // 최소 1의 flex 값 보장
      child: Container(
        color: color,
      ),
    );
  }

  // 반응 레이블 생성
  Widget _reactionLabel(String text, String percentage, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '$text $percentage',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // 토론방 인기글 섹션
  Widget _buildTopDiscussionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: DetailStyles.cardDecoration,
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 타이틀과 전체보기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '토론방 인기글',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_keyword!.currentDiscussionRoomId > 0) {
                      context.push('/discussion/${_keyword!.currentDiscussionRoomId}');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('활성화된 토론방이 없습니다.')),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        '전체보기',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF19B3F6),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: Color(0xFF19B3F6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 토론방 인기글 목록
            _buildOptimizedDiscussionList(),
          ],
        ),
      ),
    );
  }

  // 최적화된 토론방 인기글 목록
  Widget _buildOptimizedDiscussionList() {
    // 댓글이 없는 경우
    if (_comments == null || _comments!.isEmpty) {
      return Container(
        height: 60.h,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16.sp,
              color: Colors.grey[500],
            ),
            SizedBox(width: 8.w),
            Text(
              '아직 의견이 없어요! 첫 의견을 남겨주세요!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    // 댓글이 있는 경우 - 인기순(좋아요 수)으로 정렬하고 최대 3개만 표시
    List<Comment> sortedComments = List.from(_comments!);
    sortedComments.sort((a, b) =>
        (b.likeCount ?? 0).compareTo(a.likeCount ?? 0));

    final displayComments = sortedComments.length > 3 ?
    sortedComments.sublist(0, 3) : sortedComments;

    // 댓글 위젯 생성
    return Column(
      children: displayComments.map((comment) => _buildCommentItem(comment)).toList(),
    );
  }

  // 댓글 아이템 위젯
  Widget _buildCommentItem(Comment comment) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: DetailStyles.commentDecoration,
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 댓글, 작성자 및 시간
              Row(
                children: [
                  Text(
                    comment.nick,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatTimeAgo(comment.createdAt.toString()),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // 댓글 내용
              Text(
                comment.comment,
                style: TextStyle(fontSize: 15.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),

              // 좋아요, 싫어요, 댓글 수
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.thumb_up_outlined, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    (comment.likeCount ?? 0).toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Icon(Icons.thumb_down_outlined, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    (comment.dislikeCount ?? 0).toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Icon(Icons.comment_outlined, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    (comment.replies ?? 0).toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedNewsSection() {
    if (_keyword!.references.isEmpty) {
      return SizedBox.shrink();
    }

    // 펼쳐보기 버튼이 필요한지 확인
    final bool needExpand = _keyword!.references.length > 3;

    // 기본 표시할 뉴스 (항상 고정)
    final int baseCount = _keyword!.references.length > 3 ? 3 : _keyword!.references.length;

    // 추가로 표시할 뉴스 (애니메이션으로 표시)
    final List<Reference> additionalNews = _isNewsExpanded && _keyword!.references.length > 3
        ? _keyword!.references.sublist(3)
        : [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: DetailStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              '관련 뉴스',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 기본 뉴스 목록 (고정, 애니메이션 없음)
          for (int i = 0; i < baseCount; i++)
            Column(
              children: [
                _buildNewsItem(_keyword!.references[i]),
                if (i < baseCount - 1 || additionalNews.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[200],
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
              ],
            ),

          // 추가 뉴스 목록 (애니메이션으로 표시)
          ClipRect(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isNewsExpanded ? (additionalNews.length * 105).h : 0,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    for (int i = 0; i < additionalNews.length; i++)
                      Column(
                        children: [
                          _buildNewsItem(additionalNews[i]),
                          if (i < additionalNews.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey[200],
                              indent: 16.w,
                              endIndent: 16.w,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 펼쳐보기/접기 버튼 (3개 이상일 때만 표시)
          if (needExpand)
            _buildExpandButton(),

          SizedBox(height: 8.h)
        ],
      ),
    );
  }

  // 뉴스 아이템 위젯
  Widget _buildNewsItem(Reference ref) {
    final HtmlUnescape _htmlUnescape = HtmlUnescape();

    return InkWell(
      onTap: () => _launchNewsUrl(ref.link),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 뉴스 썸네일
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
                image: ref.thumbnail != null && ref.thumbnail!.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(ref.thumbnail!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: ref.thumbnail == null || ref.thumbnail!.isEmpty
                  ? Icon(
                Icons.article,
                color: Colors.grey[500],
                size: 30.sp,
              )
                  : null,
            ),
            SizedBox(width: 12.w),

            // 뉴스 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _htmlUnescape.convert(ref.title),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${ref.type} · ${ref.date}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 펼쳐보기/접기 버튼
  Widget _buildExpandButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextButton(
        onPressed: () {
          setState(() {
            _isNewsExpanded = !_isNewsExpanded;
          });
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          backgroundColor: Colors.grey[50],
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isNewsExpanded ? '접기' : '펼쳐보기',
              style: TextStyle(
                color: Color(0xFF19B3F6),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              _isNewsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 18.sp,
              color: Color(0xFF19B3F6),
            ),
          ],
        ),
      ),
    );
  }

  // URL 열기 함수
  Future<void> _launchNewsUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView, // 내장 브라우저로 변경
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL을 열 수 없습니다: $url')),
        );
      }
    } catch (e) {
      print('URL 열기 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('링크를 여는 중 오류가 발생했습니다')),
      );
    }
  }

  // 시간 포맷팅 함수
  String _formatTimeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}일 전';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 전';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}분 전';
      } else {
        return '방금 전';
      }
    } catch (e) {
      return '알 수 없음'; // 기본값
    }
  }
}

// 요약 토글 위젯 최적화
class DetailSummaryToggleWidget extends StatefulWidget {
  final String currentType;
  final Function(String) onChanged;

  const DetailSummaryToggleWidget({
    Key? key,
    required this.currentType,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DetailSummaryToggleWidget> createState() => _DetailSummaryToggleWidgetState();
}

class _DetailSummaryToggleWidgetState extends State<DetailSummaryToggleWidget> {
  final List<String> options = ['3줄', '짧은 글', '긴 글'];
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = options.indexOf(widget.currentType);
    if (selectedIndex < 0) selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final double totalWidth = 200.w;
    final double buttonWidth = totalWidth / 3;
    final double buttonHeight = 30.h;

    return SizedBox(
      width: totalWidth,
      height: buttonHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 배경
          Container(
            width: totalWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: Color(0xFF1CB3F8),
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),

          // 흰색 선택 버튼
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
            left: selectedIndex * buttonWidth,
            top: 0,
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    spreadRadius: 0.5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // 터치 가능한 버튼 텍스트
          Row(
            children: List.generate(
              options.length,
                  (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (index != selectedIndex) {
                      setState(() {
                        selectedIndex = index;
                      });
                      widget.onChanged(options[index]);
                    }
                  },
                  child: Container(
                    height: buttonHeight,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                        color: index == selectedIndex ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}