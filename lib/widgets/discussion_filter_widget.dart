import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../models/filter_state_model.dart';

/// 사용자 친화적인 토론방 필터 컴포넌트
/// 세 개의 주요 섹션으로 구성:
/// 1. 날짜 섹션: 날짜 타입 선택, 시작일/종료일 입력
/// 2. 감정 섹션: 지배적 감정 선택, 긍정/중립/부정 반응 수 범위 설정
/// 3. 댓글/공감 섹션: 댓글 수/공감 수 범위 설정
class DiscussionFilterComponent extends StatefulWidget {
  final HistoryFilterState initialFilter;
  final Function(HistoryFilterState) onFilterChanged;
  final VoidCallback? onReset;

  const DiscussionFilterComponent({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
    this.onReset,
  });

  @override
  State<DiscussionFilterComponent> createState() => _DiscussionFilterComponentState();
}

class _DiscussionFilterComponentState extends State<DiscussionFilterComponent> {
  late HistoryFilterState _currentFilter;
  Timer? _debounceTimer;
  
  // 텍스트 컨트롤러들
  final TextEditingController _minCommentsController = TextEditingController();
  final TextEditingController _maxCommentsController = TextEditingController();
  final TextEditingController _minPositiveController = TextEditingController();
  final TextEditingController _maxPositiveController = TextEditingController();
  final TextEditingController _minNeutralController = TextEditingController();
  final TextEditingController _maxNeutralController = TextEditingController();
  final TextEditingController _minNegativeController = TextEditingController();
  final TextEditingController _maxNegativeController = TextEditingController();
  final TextEditingController _minTotalReactionsController = TextEditingController();
  final TextEditingController _maxTotalReactionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _initializeControllers();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _minCommentsController.text = _currentFilter.minComments?.toString() ?? '';
    _maxCommentsController.text = _currentFilter.maxComments?.toString() ?? '';
    _minPositiveController.text = _currentFilter.minPositiveReactions?.toString() ?? '';
    _maxPositiveController.text = _currentFilter.maxPositiveReactions?.toString() ?? '';
    _minNeutralController.text = _currentFilter.minNeutralReactions?.toString() ?? '';
    _maxNeutralController.text = _currentFilter.maxNeutralReactions?.toString() ?? '';
    _minNegativeController.text = _currentFilter.minNegativeReactions?.toString() ?? '';
    _maxNegativeController.text = _currentFilter.maxNegativeReactions?.toString() ?? '';
    _minTotalReactionsController.text = _currentFilter.minTotalReactions?.toString() ?? '';
    _maxTotalReactionsController.text = _currentFilter.maxTotalReactions?.toString() ?? '';
  }

  void _disposeControllers() {
    _minCommentsController.dispose();
    _maxCommentsController.dispose();
    _minPositiveController.dispose();
    _maxPositiveController.dispose();
    _minNeutralController.dispose();
    _maxNeutralController.dispose();
    _minNegativeController.dispose();
    _maxNegativeController.dispose();
    _minTotalReactionsController.dispose();
    _maxTotalReactionsController.dispose();
  }

  void _updateFilter(HistoryFilterState newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
    
    // Debounce parent callback to reduce cascade rebuilds
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onFilterChanged(newFilter);
    });
  }


  void _resetFilters() {
    final resetFilter = const HistoryFilterState();
    setState(() {
      _currentFilter = resetFilter;
    });
    _initializeControllers();
    
    // Cancel any pending debounced updates and notify immediately
    _debounceTimer?.cancel();
    widget.onFilterChanged(resetFilter);
    
    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate, String dateType) async {
    DateTime? currentDate;
    
    switch (dateType) {
      case 'created_at':
        currentDate = isStartDate ? _currentFilter.dateFromCreated : _currentFilter.dateToCreated;
        break;
      case 'updated_at':
        currentDate = isStartDate ? _currentFilter.dateFromUpdated : _currentFilter.dateToUpdated;
        break;
      case 'closed_at':
        currentDate = isStartDate ? _currentFilter.dateFromClosed : _currentFilter.dateToClosed;
        break;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isStartDate ? '시작일 선택' : '종료일 선택',
      cancelText: '취소',
      confirmText: '확인',
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF6366F1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      HistoryFilterState newFilter;
      
      switch (dateType) {
        case 'created_at':
          newFilter = _currentFilter.copyWith(
            dateFromCreated: isStartDate ? pickedDate : _currentFilter.dateFromCreated,
            dateToCreated: !isStartDate ? pickedDate : _currentFilter.dateToCreated,
            dateFilterType: 'created_at',
          );
          break;
        case 'updated_at':
          newFilter = _currentFilter.copyWith(
            dateFromUpdated: isStartDate ? pickedDate : _currentFilter.dateFromUpdated,
            dateToUpdated: !isStartDate ? pickedDate : _currentFilter.dateToUpdated,
            dateFilterType: 'updated_at',
          );
          break;
        case 'closed_at':
          newFilter = _currentFilter.copyWith(
            dateFromClosed: isStartDate ? pickedDate : _currentFilter.dateFromClosed,
            dateToClosed: !isStartDate ? pickedDate : _currentFilter.dateToClosed,
            dateFilterType: 'closed_at',
          );
          break;
        default:
          return;
      }
      
      _updateFilter(newFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cache theme values to eliminate repeated calculations
    final bool isDark = AppTheme.isDark(context);
    final Color textColor = AppTheme.getTextColor(context);
    final Color backgroundColor = isDark 
        ? const Color(0xFF21202C)
        : Colors.white;
    final Color shadowColor = isDark 
        ? Colors.black
        : const Color(0xFF6366F1);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(isDark ? 0.95 : 0.98),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          if (!isDark)
            BoxShadow(
              color: shadowColor.withOpacity(0.04),
              blurRadius: 48,
              offset: const Offset(0, -16),
              spreadRadius: 0,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          _buildDragHandle(textColor: textColor),
          
          // 헤더
          _buildHeader(textColor: textColor),
          
          // 메인 필터 섹션들 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                children: [
                  // 1. 날짜 섹션
                  _buildDateSection(isDark: isDark, textColor: textColor, shadowColor: shadowColor),
                  
                  SizedBox(height: 32.h),
                  
                  // 2. 감정 섹션
                  _buildEmotionSection(isDark: isDark, textColor: textColor, shadowColor: shadowColor),
                  
                  SizedBox(height: 32.h),
                  
                  // 3. 댓글/공감 섹션
                  _buildEngagementSection(isDark: isDark, textColor: textColor, shadowColor: shadowColor),
                  
                  SizedBox(height: 32.h),
                  
                  // 액션 버튼들
                  _buildActionButtons(isDark: isDark, textColor: textColor),
                  
                  // 하단 안전 여백
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle({required Color textColor}) {
    return RepaintBoundary(
      child: _FilterDragHandle(textColor: textColor),
    );
  }

  Widget _buildHeader({required Color textColor}) {
    return Semantics(
      header: true,
      label: '토론방 필터 헤더',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF818CF8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ).animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .shimmer(duration: 1200.ms, delay: 400.ms),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '토론방 필터',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ).animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.1, end: 0),
                  SizedBox(height: 2.h),
                  Text(
                    '원하는 조건으로 토론방을 찾아보세요',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: textColor.withOpacity(0.6),
                      letterSpacing: -0.2,
                    ),
                  ).animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideX(begin: -0.1, end: 0),
                ],
              ),
            ),
            // 활성 필터 개수 표시
            if (_currentFilter.hasActiveFilters)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Color(0xFF6366F1).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                    ).animate(autoPlay: true, onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: Offset(1, 1),
                          end: Offset(1.3, 1.3),
                          duration: 1000.ms,
                        )
                        .then()
                        .scale(
                          begin: Offset(1.3, 1.3),
                          end: Offset(1, 1),
                          duration: 1000.ms,
                        ),
                    SizedBox(width: 6.w),
                    Text(
                      '${_currentFilter.filterComplexity}개 적용',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ).animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection({required bool isDark, required Color textColor, required Color shadowColor}) {
    return _buildSection(
      title: '📅 날짜 필터',
      description: '토론방 생성, 업데이트, 또는 종료 날짜를 기준으로 필터링',
      isDark: isDark,
      textColor: textColor,
      shadowColor: shadowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 타입 선택
          _buildSectionLabel('날짜 기준 선택', textColor: textColor),
          SizedBox(height: 8.h),
          _buildDateTypeSelector(),
          
          SizedBox(height: 16.h),
          
          // 날짜 범위 선택
          _buildSectionLabel('날짜 범위', textColor: textColor),
          SizedBox(height: 8.h),
          _buildDateRangeSelector(),
        ],
      ),
    );
  }

  Widget _buildEmotionSection({required bool isDark, required Color textColor, required Color shadowColor}) {
    return _buildSection(
      title: '😊 감정 필터',
      description: '토론방의 감정 분위기와 반응 수를 기준으로 필터링',
      isDark: isDark,
      textColor: textColor,
      shadowColor: shadowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지배적 감정 선택
          _buildSectionLabel('지배적 감정', textColor: textColor),
          SizedBox(height: 8.h),
          _buildDominantSentimentSelector(),
          
          SizedBox(height: 16.h),
          
          // 감정별 반응 수 범위
          _buildSectionLabel('감정별 반응 수 범위', textColor: textColor),
          SizedBox(height: 8.h),
          _buildEmotionRanges(),
          
          SizedBox(height: 16.h),
          
          // 전체 반응 수 범위
          _buildSectionLabel('전체 반응 수', textColor: textColor),
          SizedBox(height: 8.h),
          _buildTotalReactionRange(),
        ],
      ),
    );
  }

  Widget _buildEngagementSection({required bool isDark, required Color textColor, required Color shadowColor}) {
    return _buildSection(
      title: '💬 댓글 필터',
      description: '토론방의 댓글 수를 기준으로 필터링',
      isDark: isDark,
      textColor: textColor,
      shadowColor: shadowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 댓글 수 범위
          _buildSectionLabel('댓글 수 범위', textColor: textColor),
          SizedBox(height: 8.h),
          _buildCommentRange(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
    required bool isDark,
    required Color textColor,
    required Color shadowColor,
  }) {
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? Color(0xFF2D2C3D).withOpacity(0.5)
          : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
            ? Colors.white.withOpacity(0.06)
            : shadowColor.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? Colors.black.withOpacity(0.2)
              : shadowColor.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,  // 전체 너비로 설정
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                  ? [
                      Color(0xFF6366F1).withOpacity(0.15),
                      Color(0xFF6366F1).withOpacity(0.05),
                    ]
                  : [
                      Color(0xFF6366F1).withOpacity(0.08),
                      Color(0xFF6366F1).withOpacity(0.03),
                    ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textColor.withOpacity(0.6),
                    letterSpacing: -0.2,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.02, end: 0);
  }

  Widget _buildSectionLabel(String label, {required Color textColor}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildDateTypeSelector() {
    final options = [
      {'value': 'created_at', 'label': '생성일'},
      {'value': 'updated_at', 'label': '업데이트일'},
      {'value': 'closed_at', 'label': '종료일'},
    ];
    
    return Wrap(
      spacing: 8.w,
      children: options.map((option) {
        final bool isSelected = _currentFilter.dateFilterType == option['value'];
        return _buildChoiceChip(
          label: option['label'] as String,
          isSelected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _updateFilter(_currentFilter.copyWith(dateFilterType: option['value'] as String));
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector() {
    DateTime? startDate;
    DateTime? endDate;
    
    switch (_currentFilter.dateFilterType) {
      case 'created_at':
        startDate = _currentFilter.dateFromCreated;
        endDate = _currentFilter.dateToCreated;
        break;
      case 'updated_at':
        startDate = _currentFilter.dateFromUpdated;
        endDate = _currentFilter.dateToUpdated;
        break;
      case 'closed_at':
        startDate = _currentFilter.dateFromClosed;
        endDate = _currentFilter.dateToClosed;
        break;
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: '시작일',
            date: startDate,
            onTap: () => _selectDate(context, true, _currentFilter.dateFilterType),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          '~',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildDateButton(
            label: '종료일',
            date: endDate,
            onTap: () => _selectDate(context, false, _currentFilter.dateFilterType),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final bool isDark = AppTheme.isDark(context);
    final bool hasDate = date != null;
    
    return Semantics(
      button: true,
      label: '$label ${hasDate ? "${date.year}년 ${date.month}월 ${date.day}일" : "선택 안됨"}',
      hint: '탭하여 날짜를 선택하세요',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark
                ? Color(0xFF2D2C3D).withOpacity(0.6)
                : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: hasDate
                  ? Color(0xFF6366F1).withOpacity(0.3)
                  : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08)),
                width: hasDate ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasDate
                    ? Color(0xFF6366F1).withOpacity(0.1)
                    : (isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05)),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: hasDate
                      ? Color(0xFF6366F1).withOpacity(0.1)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: hasDate
                      ? Color(0xFF6366F1)
                      : AppTheme.getTextColor(context).withOpacity(0.4),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context).withOpacity(0.6),
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        hasDate
                          ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}'
                          : '날짜 선택',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: hasDate ? FontWeight.w700 : FontWeight.w500,
                          color: hasDate
                            ? AppTheme.getTextColor(context)
                            : AppTheme.getTextColor(context).withOpacity(0.4),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextColor(context).withOpacity(0.3),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.02, end: 0);
  }

  Widget _buildDominantSentimentSelector() {
    final options = [
      {'value': 'all', 'label': '전체', 'color': Colors.grey},
      {'value': 'positive', 'label': '긍정적', 'color': const Color(0xFF10B981)},
      {'value': 'neutral', 'label': '중립적', 'color': const Color(0xFF6B7280)},
      {'value': 'negative', 'label': '부정적', 'color': const Color(0xFFEF4444)},
    ];
    
    return Wrap(
      spacing: 8.w,
      children: options.map((option) {
        final bool isSelected = _currentFilter.dominantSentiment == option['value'];
        return _buildChoiceChip(
          label: option['label'] as String,
          isSelected: isSelected,
          color: option['color'] as Color,
          onSelected: (selected) {
            if (selected) {
              _updateFilter(_currentFilter.copyWith(dominantSentiment: option['value'] as String));
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmotionRanges() {
    return Column(
      children: [
        _buildRangeInput(
          label: '긍정 반응',
          minController: _minPositiveController,
          maxController: _maxPositiveController,
          onChanged: (min, max) {
            _updateFilter(_currentFilter.copyWith(
              minPositiveReactions: min,
              maxPositiveReactions: max,
            ));
          },
          color: const Color(0xFF10B981),
        ),
        SizedBox(height: 12.h),
        _buildRangeInput(
          label: '중립 반응',
          minController: _minNeutralController,
          maxController: _maxNeutralController,
          onChanged: (min, max) {
            _updateFilter(_currentFilter.copyWith(
              minNeutralReactions: min,
              maxNeutralReactions: max,
            ));
          },
          color: const Color(0xFF6B7280),
        ),
        SizedBox(height: 12.h),
        _buildRangeInput(
          label: '부정 반응',
          minController: _minNegativeController,
          maxController: _maxNegativeController,
          onChanged: (min, max) {
            _updateFilter(_currentFilter.copyWith(
              minNegativeReactions: min,
              maxNegativeReactions: max,
            ));
          },
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildTotalReactionRange() {
    return _buildRangeInput(
      label: '전체 반응 수',
      minController: _minTotalReactionsController,
      maxController: _maxTotalReactionsController,
      onChanged: (min, max) {
        _updateFilter(_currentFilter.copyWith(
          minTotalReactions: min,
          maxTotalReactions: max,
        ));
      },
      color: const Color(0xFF8B5CF6),
    );
  }

  Widget _buildCommentRange() {
    return _buildRangeInput(
      label: '댓글 수',
      minController: _minCommentsController,
      maxController: _maxCommentsController,
      onChanged: (min, max) {
        _updateFilter(_currentFilter.copyWith(
          minComments: min,
          maxComments: max,
        ));
      },
      color: const Color(0xFF8B5CF6),
    );
  }


  Widget _buildRangeInput({
    required String label,
    required TextEditingController minController,
    required TextEditingController maxController,
    required Function(int?, int?) onChanged,
    Color? color,
  }) {
    return Row(
      children: [
        // 라벨과 색상 인디케이터
        SizedBox(
          width: 80.w,
          child: Row(
            children: [
              if (color != null)
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              if (color != null) SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        // 최소값 입력
        Expanded(
          child: _buildNumberInput(
            controller: minController,
            hint: '최소',
            onChanged: (value) {
              final min = int.tryParse(value);
              final max = int.tryParse(maxController.text);
              onChanged(min, max);
            },
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '~',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        SizedBox(width: 8.w),
        // 최대값 입력
        Expanded(
          child: _buildNumberInput(
            controller: maxController,
            hint: '최대',
            onChanged: (value) {
              final min = int.tryParse(minController.text);
              final max = int.tryParse(value);
              onChanged(min, max);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
    final bool isDark = AppTheme.isDark(context);
    
    return Semantics(
      textField: true,
      label: hint,
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: isDark
            ? Color(0xFF2D2C3D).withOpacity(0.6)
            : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
              ? Colors.white.withOpacity(0.08)
              : Color(0xFF6366F1).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.getTextColor(context).withOpacity(0.4),
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    final bool isDark = AppTheme.isDark(context);
    final effectiveColor = color ?? const Color(0xFF6366F1);
    
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label ${isSelected ? "선택됨" : "선택 안됨"}',
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(!isSelected),
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                  ? effectiveColor
                  : (isDark 
                      ? Color(0xFF2D2C3D).withOpacity(0.6)
                      : Colors.white.withOpacity(0.9)),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isSelected
                    ? effectiveColor
                    : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Color(0xFF6366F1).withOpacity(0.2)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: effectiveColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                        ? Colors.white
                        : AppTheme.getTextColor(context),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .scale(
          begin: Offset(0.95, 0.95),
          end: Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildActionButtons({required bool isDark, required Color textColor}) {
    
    return Row(
      children: [
        // 초기화 버튼
        Expanded(
          child: Semantics(
            button: true,
            label: '필터 초기화',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _resetFilters,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: isDark
                      ? Color(0xFF2D2C3D).withOpacity(0.6)
                      : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 20.sp,
                        color: AppTheme.getTextColor(context).withOpacity(0.7),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '초기화',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context).withOpacity(0.7),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
        SizedBox(width: 12.w),
        // 적용 버튼
        Expanded(
          flex: 2,
          child: Semantics(
            button: true,
            label: '필터 적용하고 닫기',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // 필터 적용은 실시간으로 이미 적용되고 있음
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF818CF8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '필터 적용',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, end: 0)
            .shimmer(duration: 1500.ms, delay: 800.ms, color: Colors.white.withOpacity(0.3)),
      ],
    );
  }
}

/// Optimized drag handle widget with RepaintBoundary
class _FilterDragHandle extends StatelessWidget {
  const _FilterDragHandle({required this.textColor});
  
  final Color textColor;
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '필터 창 드래그 핸들',
      hint: '위아래로 드래그하여 크기를 조절할 수 있습니다',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Center(
          child: Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.5.r),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0);
  }
}