import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import '../models/_models.dart';
import '../services/api_service.dart';
import '../services/firebase_messaging_service.dart';
import '../widgets/_widgets.dart';
import '../app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 공통 스타일을 정의한 클래스 - 다크모드 지원 추가

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
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();
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
      
      // 키워드 조회 로그 기록
      _logKeywordView(keyword);

      // 현재 활성화된 토론방 정보 로드
      DiscussionRoom? discussionRoom;
      List<Comment>? comments;

      try {
        if (keyword.current_discussion_room != null && keyword.current_discussion_room! > 0) {
          // 토론방 정보가 있는 경우 댓글 목록 가져오기 (인기순으로 변경)
          comments = await _apiService.getDiscussionComments(keyword.current_discussion_room!, isPopular: true);

          // 토론방 정보도 가져오기
          try {
            discussionRoom = await _apiService.getDiscussionRoomById(keyword.current_discussion_room!);
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
  
  // 키워드 조회 로그 기록 메서드
  Future<void> _logKeywordView(Keyword keyword) async {
    try {
      final token = await _fcmService.getCurrentToken();
      if (token != null) {
        await _apiService.logKeywordView(
          token: token,
          category: keyword.category ?? '기타',
          keyword: keyword.keyword,
        );
        print('📊 [LOG] Keyword detail view logged: ${keyword.keyword}');
      }
    } catch (e) {
      print('❌ [LOG] Failed to log keyword detail view: $e');
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
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF19B3F6)))
          : _error != null
          ? _buildErrorWidget()
          : _keyword == null
          ? Center(child: Text('키워드 정보가 없습니다.', style: TextStyle(color: AppTheme.getTextColor(context))))
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
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadKeywordDetails,
            child: Text('다시 시도'),
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
          backgroundColor: AppTheme.getContainerColor(context),
          elevation: 8,
          expandedHeight: 0,
          toolbarHeight: 54.h,
          centerTitle: true,
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
          shadowColor: AppTheme.isDark(context)
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.3),
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
                          color: AppTheme.getTextColor(context),
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
                          color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
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
        decoration: AppTheme.cardDecoration(context),
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
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    Spacer(),
                    // 여기서 DetailSummaryToggleWidget을 SummaryToggleWidget으로 변경
                    SummaryToggleWidget(
                      currentType: _selectedSummaryType,
                      onChanged: _onSummaryTypeChanged,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              Divider(
                color: AppTheme.isDark(context) ? Colors.grey[700] : Color(0xFFE2E2E2),
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
    final textColor = AppTheme.isDark(context) ? Colors.grey[300] : Colors.black87;

    switch (_selectedSummaryType) {
      case '3줄':
        if (_keyword!.type1.isEmpty) {
          return Text('요약 내용이 없습니다.', style: TextStyle(color: textColor));
        }
        // 반복문 대신 map과 spread 연산자 활용
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(_keyword!.type1 is List ? (_keyword!.type1 as List) : []).asMap().entries.map((entry) {
              int index = entry.key;
              String content = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < (_keyword!.type1 is List ? (_keyword!.type1 as List).length : 0) - 1 ? 15.h : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.5,
                          color: textColor,
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
            color: textColor,
          ),
        );
      case '긴 글':
        return Text(
          _keyword!.type3,
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.5,
            color: textColor,
          ),
        );
      default:
        return Text('요약 내용이 없습니다.', style: TextStyle(color: textColor));
    }
  }

  // 토론방 반응 섹션 - discussionHome 컴포넌트 스타일로 변경
  Widget _buildDiscussionReactionSection() {
    return DiscussionReactionWidget(
      discussionRoom: _discussionRoom,
      keyword: _keyword,
      onEnterTap: () {
        if (_discussionRoom != null) {
          // 토론방으로 이동
          context.push('/discussion/${_discussionRoom!.id}');
        }
      },
    );
  }

  // 토론방 인기글 섹션
  Widget _buildTopDiscussionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: AppTheme.cardDecoration(context),
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
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_keyword!.current_discussion_room != null && _keyword!.current_discussion_room! > 0) {
                      context.push('/discussion/${_keyword!.current_discussion_room}');
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
              color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[500],
            ),
            SizedBox(width: 8.w),
            Text(
              '아직 의견이 없어요! 첫 의견을 남겨주세요!',
              style: TextStyle(
                color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[500],
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
        (b.like_count ?? 0).compareTo(a.like_count ?? 0));

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
        decoration: AppTheme.commentDecoration(context),
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
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatTimeAgo(comment.created_at.toString()),
                    style: TextStyle(
                      color: AppTheme.isDark(context) ? Colors.grey[500] : Colors.grey,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // 댓글 내용
              Text(
                comment.comment,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppTheme.isDark(context) ? Colors.grey[300] : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),

              // 좋아요, 싫어요, 댓글 수
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.thumb_up_outlined,
                      size: 16.sp,
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600]
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    (comment.like_count ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Icon(Icons.thumb_down_outlined,
                      size: 16.sp,
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600]
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    (comment.dislike_count ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Icon(Icons.comment_outlined,
                      size: 16.sp,
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600]
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    (comment.sub_comment_count ?? comment.replies ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
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

    // references를 List로 안전하게 변환 (early conversion)
    final List<dynamic> referencesListForCheck = _keyword!.references is List ? (_keyword!.references as List) : [];
    
    // 펼쳐보기 버튼이 필요한지 확인
    final bool needExpand = referencesListForCheck.length > 3;

    // references를 List로 안전하게 변환
    final List<dynamic> referencesList = _keyword!.references is List ? (_keyword!.references as List) : [];
    
    // 기본 표시할 뉴스 (항상 고정)
    final int baseCount = referencesList.length > 3 ? 3 : referencesList.length;

    // 추가로 표시할 뉴스 (애니메이션으로 표시)
    final List<dynamic> additionalNews = _isNewsExpanded && referencesList.length > 3
        ? referencesList.sublist(3)
        : [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: AppTheme.cardDecoration(context),
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
                color: AppTheme.getTextColor(context),
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
                    color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[200],
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
                              color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[200],
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
  Widget _buildNewsItem(dynamic ref) {
    final HtmlUnescape _htmlUnescape = HtmlUnescape();
    
    // ref를 Map으로 안전하게 변환
    final Map<String, dynamic> refData = ref is Map<String, dynamic> ? ref : {};

    return InkWell(
      onTap: () => _launchNewsUrl(refData['link']?.toString() ?? ''),
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
                color: AppTheme.isDark(context) ? Color(0xFF333340) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
                image: refData['thumbnail'] != null && refData['thumbnail']!.toString().isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(refData['thumbnail']!.toString()),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: refData['thumbnail'] == null || refData['thumbnail']!.toString().isEmpty
                  ? Icon(
                Icons.article,
                color: AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[500],
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
                    _htmlUnescape.convert(refData['title']?.toString() ?? ''),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${refData['type']?.toString() ?? ''} · ${refData['date']?.toString() ?? ''}',
                    style: TextStyle(
                      color: AppTheme.isDark(context) ? Colors.grey[500] : Colors.grey[600],
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
            side: BorderSide(
                color: AppTheme.isDark(context) ? Colors.grey[700]! : Colors.grey[300]!
            ),
          ),
          backgroundColor: AppTheme.isDark(context) ? Color(0xFF2D2D3A) : Colors.grey[50],
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