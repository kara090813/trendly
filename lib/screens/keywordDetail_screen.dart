import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import '../models/_models.dart';
import '../services/api_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/ad_service.dart';
import '../widgets/_widgets.dart';
import '../app_theme.dart';
import '../utils/device_utils.dart';
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
  List<Comment>? _topComments;
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
      List<Comment>? topComments;

      try {
        if (keyword.current_discussion_room != null && keyword.current_discussion_room! > 0) {
          // 토론방 정보가 있는 경우 댓글 목록 가져오기 (인기순으로 변경)
          comments = await _apiService.getDiscussionComments(keyword.current_discussion_room!, isPopular: true);

          // 새로운 API를 사용하여 인기 댓글 3개 가져오기
          try {
            final topCommentsResult = await _apiService.getTopComments(keyword.current_discussion_room!, 3);
            topComments = topCommentsResult['comments'] as List<Comment>?;
          } catch (e) {
            print('인기 댓글 로드 실패: $e');
          }

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
          _topComments = topComments;
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
      final token = await _fcmService.getTokenForLogging();
      final result = await _apiService.logKeywordView(
        token: token,
        category: keyword.category ?? '기타',
        keyword: keyword.keyword,
      );
      
      if (result != null) {
        print('📊 [LOG] Keyword detail view logged: ${keyword.keyword}');
      } else {
        print('📊 [LOG] Keyword detail view log skipped (no token): ${keyword.keyword}');
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
          toolbarHeight: DeviceUtils.isTablet(context) ? 70.h : 54.h,
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
              SizedBox(height: 20.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSimplifiedHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: DeviceUtils.isTablet(context) ? 14.h : 10.h, 
        horizontal: 16.w
      ),
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
                  size: DeviceUtils.isTablet(context) ? 18.sp : 22.sp,
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
                          fontSize: DeviceUtils.isTablet(context) ? 16.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                        minFontSize: DeviceUtils.isTablet(context) ? 8 : 10,
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
                          fontSize: DeviceUtils.isTablet(context) ? 16.sp : 20.sp,
                          color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                        ),
                        minFontSize: DeviceUtils.isTablet(context) ? 6 : 8,
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
                        fontSize: DeviceUtils.isTablet(context) ? 18.sp : 22.sp,
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

  // 요약 내용 생성 - 키워드 하이라이팅 적용
  Widget _buildFormattedSummaryContent() {
    final String summaryText = _getSummaryContent();
    
    // 키워드 토큰 생성 (전체 키워드 + 띄어쓰기로 나눈 단어들)
    List<String> keywordTokens = [_keyword!.keyword];
    keywordTokens.addAll(_keyword!.keyword.split(' '));
    keywordTokens = keywordTokens.where((token) => token.isNotEmpty).toSet().toList();
    keywordTokens.sort((a, b) => b.length.compareTo(a.length)); // 긴 토큰부터 매칭
    
    final List<String> paragraphs = summaryText.split('\n\n');
    final List<Widget> paragraphWidgets = [];
    
    for (int i = 0; i < paragraphs.length; i++) {
      if (i > 0) {
        paragraphWidgets.add(SizedBox(height: 16.h));
      }
      
      String paragraph = paragraphs[i];
      List<TextSpan> paragraphSpans = [];
      int currentPos = 0;
      final int paragraphLength = paragraph.length;
      
      // 3줄 요약의 경우만 숫자와 함께 처리
      bool is3LineType = _selectedSummaryType == '3줄' && i < 3;
      
      while (currentPos < paragraphLength) {
        bool foundMatch = false;
        
        // 키워드 토큰 매칭
        for (String token in keywordTokens) {
          if (currentPos + token.length <= paragraphLength &&
              paragraph.substring(currentPos, currentPos + token.length).toLowerCase() == 
              token.toLowerCase()) {
            // 하이라이팅된 키워드
            paragraphSpans.add(TextSpan(
              text: paragraph.substring(currentPos, currentPos + token.length),
              style: TextStyle(
                fontSize: DeviceUtils.isTablet(context) ? 15.sp : 18.sp,
                height: 1.7,
                fontWeight: FontWeight.w700,
                color: Color(0xFF19B3F6),
                backgroundColor: Color(0xFF19B3F6).withOpacity(0.1),
              ),
            ));
            
            currentPos += token.length;
            foundMatch = true;
            break;
          }
        }
        
        if (!foundMatch) {
          // 다음 매칭 위치까지의 일반 텍스트
          int nextMatchPos = paragraphLength;
          
          for (String token in keywordTokens) {
            int pos = paragraph.toLowerCase().indexOf(token.toLowerCase(), currentPos);
            if (pos != -1 && pos < nextMatchPos) {
              nextMatchPos = pos;
            }
          }
          
          paragraphSpans.add(TextSpan(
            text: paragraph.substring(currentPos, nextMatchPos),
            style: TextStyle(
              fontSize: DeviceUtils.isTablet(context) ? 15.sp : 18.sp,
              height: 1.7,
              fontWeight: FontWeight.w400,
              color: AppTheme.isDark(context) 
                  ? Colors.white.withOpacity(0.9) 
                  : Colors.black87,
            ),
          ));
          
          currentPos = nextMatchPos;
        }
      }
      
      // 위젯 추가
      if (is3LineType) {
        // 3줄 요약은 숫자와 함께 Row로 표시
        paragraphWidgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                margin: EdgeInsets.only(right: 8.w, top: 6.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF19B3F6), Color(0xFF0EA5E9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF19B3F6).withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: DeviceUtils.isTablet(context) ? 12.sp : 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(children: paragraphSpans),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );
      } else {
        // 일반 텍스트 표시
        paragraphWidgets.add(
          Container(
            width: double.infinity,
            child: RichText(
              text: TextSpan(children: paragraphSpans),
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphWidgets,
    );
  }
  
  // 요약 타입별 텍스트 가져오기
  String _getSummaryContent() {
    switch (_selectedSummaryType) {
      case '3줄':
        return _getShortSummary();
      case '짧은 글':
        return _getMediumSummary();
      case '긴 글':
        return _getLongSummary();
      default:
        return '요약 내용이 없습니다.';
    }
  }
  
  String _getShortSummary() {
    try {
      List<String> summaryLines = [];
      
      // type1을 안전하게 처리
      if (_keyword!.type1 is List && (_keyword!.type1 as List).isNotEmpty) {
        String type1String = (_keyword!.type1 as List).first.toString();
        
        if (type1String.trim().startsWith('[') && type1String.trim().endsWith(']')) {
          String cleaned = type1String.replaceAll(RegExp(r"[\[\]']"), "");
          summaryLines = cleaned.split(',').map((s) => s.trim()).toList();
        } else {
          summaryLines = (_keyword!.type1 as List).map((e) => e.toString()).toList();
        }
      } else if (_keyword!.type1 is Map) {
        // type1이 Map인 경우 처리
        final Map<String, dynamic> type1Map = _keyword!.type1 as Map<String, dynamic>;
        summaryLines = type1Map.values.map((e) => e.toString()).toList();
      }
      
      if (summaryLines.isNotEmpty) {
        final StringBuffer formattedLines = StringBuffer();
        for (int i = 0; i < summaryLines.length; i++) {
          formattedLines.write('${summaryLines[i]}\n\n');
        }
        return formattedLines.toString().trim();
      }
    } catch (e) {
      print('3줄 요약 파싱 오류: $e');
    }
    
    return '오류가 발생했습니다.';
  }
  
  String _getMediumSummary() {
    return _keyword!.type2.isNotEmpty ? _keyword!.type2 : '오류가 발생했습니다.';
  }
  
  String _getLongSummary() {
    return _keyword!.type3.isNotEmpty ? _keyword!.type3 : '오류가 발생했습니다.';
  }

  // 토론방 반응 섹션 - discussionHome 컴포넌트 스타일로 변경
  Widget _buildDiscussionReactionSection() {
    return DiscussionReactionWidget(
      discussionRoom: _discussionRoom,
      keyword: _keyword,
      topComments: _topComments, // 베스트 댓글 3개 전달
      onEnterTap: () {
        if (_discussionRoom != null) {
          // 토론방으로 이동
          context.push('/discussion/${_discussionRoom!.id}');
        }
      },
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
                fontSize: DeviceUtils.isTablet(context) ? 18.sp : 22.sp,
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
                
                // 첫 번째 뉴스 아이템 뒤에 네이티브 광고 삽입
                if (i == 0 && AdService.isAdEnabled)
                  Column(
                    children: [
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[200],
                        indent: 16.w,
                        endIndent: 16.w,
                      ),
                      const NativeAdWidget(key: ValueKey('keyword_detail_native_ad')),
                    ],
                  ),
                
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
                size: DeviceUtils.isTablet(context) ? 24.sp : 30.sp,
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
                      fontSize: DeviceUtils.isTablet(context) ? 13.sp : 15.sp,
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
                      fontSize: DeviceUtils.isTablet(context) ? 11.sp : 13.sp,
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
                fontSize: DeviceUtils.isTablet(context) ? 12.sp : 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              _isNewsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: DeviceUtils.isTablet(context) ? 16.sp : 18.sp,
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