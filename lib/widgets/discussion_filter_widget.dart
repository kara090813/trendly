import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
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
    widget.onFilterChanged(newFilter);
  }

  void _resetFilters() {
    final resetFilter = const HistoryFilterState();
    _updateFilter(resetFilter);
    _initializeControllers();
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
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          _buildDragHandle(),
          
          // 헤더
          _buildHeader(),
          
          // 메인 필터 섹션들 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                children: [
                  // 1. 날짜 섹션
                  _buildDateSection(),
                  
                  SizedBox(height: 32.h),
                  
                  // 2. 감정 섹션
                  _buildEmotionSection(),
                  
                  SizedBox(height: 32.h),
                  
                  // 3. 댓글/공감 섹션
                  _buildEngagementSection(),
                  
                  SizedBox(height: 32.h),
                  
                  // 액션 버튼들
                  _buildActionButtons(),
                  
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

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Colors.white,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '토론방 필터',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '원하는 조건으로 토론방을 찾아보세요',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // 활성 필터 개수 표시
          if (_currentFilter.hasActiveFilters)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${_currentFilter.filterComplexity}개 적용됨',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildSection(
      title: '📅 날짜 필터',
      description: '토론방 생성, 업데이트, 또는 종료 날짜를 기준으로 필터링',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 타입 선택
          _buildSectionLabel('날짜 기준 선택'),
          SizedBox(height: 8.h),
          _buildDateTypeSelector(),
          
          SizedBox(height: 16.h),
          
          // 날짜 범위 선택
          _buildSectionLabel('날짜 범위'),
          SizedBox(height: 8.h),
          _buildDateRangeSelector(),
        ],
      ),
    );
  }

  Widget _buildEmotionSection() {
    return _buildSection(
      title: '😊 감정 필터',
      description: '토론방의 감정 분위기와 반응 수를 기준으로 필터링',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지배적 감정 선택
          _buildSectionLabel('지배적 감정'),
          SizedBox(height: 8.h),
          _buildDominantSentimentSelector(),
          
          SizedBox(height: 16.h),
          
          // 감정별 반응 수 범위
          _buildSectionLabel('감정별 반응 수 범위'),
          SizedBox(height: 8.h),
          _buildEmotionRanges(),
          
          SizedBox(height: 16.h),
          
          // 전체 반응 수 범위
          _buildSectionLabel('전체 반응 수'),
          SizedBox(height: 8.h),
          _buildTotalReactionRange(),
        ],
      ),
    );
  }

  Widget _buildEngagementSection() {
    return _buildSection(
      title: '💬 댓글/공감 필터',
      description: '토론방의 활동 수준을 댓글 수와 반응 수로 측정',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 댓글 수 범위
          _buildSectionLabel('댓글 수 범위'),
          SizedBox(height: 8.h),
          _buildCommentRange(),
          
          SizedBox(height: 16.h),
          
          // 활동 수준 선택
          _buildSectionLabel('활동 수준'),
          SizedBox(height: 8.h),
          _buildActivityLevelSelector(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B3A) : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: (AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextColor(context),
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
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                date != null 
                  ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}'
                  : '선택해주세요',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: date != null ? AppTheme.getTextColor(context) : (isDark ? Colors.grey[500] : Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildActivityLevelSelector() {
    final options = [
      {'value': 'all', 'label': '전체'},
      {'value': 'high', 'label': '높음'},
      {'value': 'medium', 'label': '보통'},
      {'value': 'low', 'label': '낮음'},
    ];
    
    return Wrap(
      spacing: 8.w,
      children: options.map((option) {
        final bool isSelected = _currentFilter.activityLevel == option['value'];
        return _buildChoiceChip(
          label: option['label'] as String,
          isSelected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _updateFilter(_currentFilter.copyWith(activityLevel: option['value'] as String));
            }
          },
        );
      }).toList(),
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
    
    return SizedBox(
      height: 40.h,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextColor(context),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: (isDark ? Colors.grey[500] : Colors.grey[400]),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(
              color: Color(0xFF6366F1),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: isSelected 
            ? Colors.white 
            : AppTheme.getTextColor(context),
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      selectedColor: effectiveColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected 
          ? effectiveColor 
          : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool isDark = AppTheme.isDark(context);
    
    return Row(
      children: [
        // 초기화 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetFilters,
            icon: Icon(
              Icons.refresh,
              size: 18.sp,
              color: (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            label: Text(
              '초기화',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // 적용 버튼
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              // 필터 적용은 실시간으로 이미 적용되고 있음
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.check,
              size: 18.sp,
              color: Colors.white,
            ),
            label: Text(
              '필터 적용',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}