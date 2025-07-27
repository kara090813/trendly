import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../models/filter_state_model.dart';
import 'package:intl/intl.dart';

class AdvancedFilterWidget extends StatefulWidget {
  final HistoryFilterState filterState;
  final Function(HistoryFilterState) onFilterChanged;
  final List<String> availableCategories;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;
  
  const AdvancedFilterWidget({
    super.key,
    required this.filterState,
    required this.onFilterChanged,
    required this.availableCategories,
    required this.isExpanded,
    required this.onToggleExpansion,
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;
  late TabController _tabController;
  
  // Controllers for number fields
  final Map<String, TextEditingController> _controllers = {
    'minComments': TextEditingController(),
    'maxComments': TextEditingController(),
    'minPositiveReactions': TextEditingController(),
    'maxPositiveReactions': TextEditingController(),
    'minNeutralReactions': TextEditingController(),
    'maxNeutralReactions': TextEditingController(),
    'minNegativeReactions': TextEditingController(),
    'maxNegativeReactions': TextEditingController(),
    'minTotalReactions': TextEditingController(),
    'maxTotalReactions': TextEditingController(),
  };
  
  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );
    
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
    
    _updateControllers();
    
    if (widget.isExpanded) {
      _expansionController.value = 1.0;
    }
  }
  
  void _updateControllers() {
    final state = widget.filterState;
    _controllers['minComments']?.text = state.minComments?.toString() ?? '';
    _controllers['maxComments']?.text = state.maxComments?.toString() ?? '';
    _controllers['minPositiveReactions']?.text = state.minPositiveReactions?.toString() ?? '';
    _controllers['maxPositiveReactions']?.text = state.maxPositiveReactions?.toString() ?? '';
    _controllers['minNeutralReactions']?.text = state.minNeutralReactions?.toString() ?? '';
    _controllers['maxNeutralReactions']?.text = state.maxNeutralReactions?.toString() ?? '';
    _controllers['minNegativeReactions']?.text = state.minNegativeReactions?.toString() ?? '';
    _controllers['maxNegativeReactions']?.text = state.maxNegativeReactions?.toString() ?? '';
    _controllers['minTotalReactions']?.text = state.minTotalReactions?.toString() ?? '';
    _controllers['maxTotalReactions']?.text = state.maxTotalReactions?.toString() ?? '';
  }
  
  @override
  void didUpdateWidget(AdvancedFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    }
    if (widget.filterState != oldWidget.filterState) {
      _updateControllers();
    }
  }
  
  @override
  void dispose() {
    _expansionController.dispose();
    _tabController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isDark),
          AnimatedBuilder(
            animation: _expansionAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _expansionAnimation,
                child: child,
              );
            },
            child: _buildAdvancedFilters(isDark),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(bool isDark) {
    final hasActiveFilters = widget.filterState.hasActiveFilters;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onToggleExpansion,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '고급 필터',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    if (hasActiveFilters)
                      Text(
                        '${widget.filterState.filterComplexity}개 필터 활성화',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Quick preset buttons
              _buildQuickPresets(isDark),
              SizedBox(width: 8.w),
              if (hasActiveFilters)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.filterState.filterComplexity}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              SizedBox(width: 8.w),
              AnimatedRotation(
                turns: widget.isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickPresets(bool isDark) {
    return PopupMenuButton<String>(
      onSelected: (preset) {
        widget.onFilterChanged(widget.filterState.applyPreset(preset));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'high_activity',
          child: Row(
            children: [
              Icon(Icons.local_fire_department, size: 16.sp, color: Colors.orange),
              SizedBox(width: 8.w),
              Text('활발한 토론'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'recent_week',
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16.sp, color: Colors.blue),
              SizedBox(width: 8.w),
              Text('최근 일주일'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'popular_discussions',
          child: Row(
            children: [
              Icon(Icons.trending_up, size: 16.sp, color: Colors.green),
              SizedBox(width: 8.w),
              Text('인기 토론'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'controversial',
          child: Row(
            children: [
              Icon(Icons.warning, size: 16.sp, color: Colors.red),
              SizedBox(width: 8.w),
              Text('논쟁적 토론'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'long_discussions',
          child: Row(
            children: [
              Icon(Icons.forum, size: 16.sp, color: Colors.purple),
              SizedBox(width: 8.w),
              Text('긴 토론'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.speed,
          size: 16.sp,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }
  
  Widget _buildAdvancedFilters(bool isDark) {
    return Container(
      height: 400.h, // Fixed height for tab content
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF334155) : Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.getTextColor(context),
              labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('날짜'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mood, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('감정'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('활동'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('기타'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDateFiltersTab(isDark),
                _buildSentimentFiltersTab(isDark),
                _buildActivityFiltersTab(isDark),
                _buildMiscFiltersTab(isDark),
              ],
            ),
          ),
          
          // Action buttons
          _buildFilterActions(isDark),
        ],
      ),
    );
  }
  
  Widget _buildDateFiltersTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date filter type selector
          _buildSectionTitle('날짜 기준', isDark),
          SizedBox(height: 8.h),
          _buildDropdownField(
            '날짜 타입',
            widget.filterState.dateFilterType,
            [
              {'value': 'created_at', 'label': '생성일'},
              {'value': 'updated_at', 'label': '수정일'},
              {'value': 'closed_at', 'label': '종료일'},
            ],
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(dateFilterType: value),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Date range based on selected type
          _buildDateRangeSection(isDark),
          
          SizedBox(height: 16.h),
          
          // Time of day filter
          _buildSectionTitle('시간대', isDark),
          SizedBox(height: 8.h),
          _buildChipSelector(
            widget.filterState.timeOfDay,
            [
              {'value': 'all', 'label': '전체'},
              {'value': 'morning', 'label': '오전'},
              {'value': 'afternoon', 'label': '오후'},
              {'value': 'evening', 'label': '저녁'},
              {'value': 'night', 'label': '밤'},
            ],
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(timeOfDay: value),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Day of week filter
          _buildSectionTitle('요일', isDark),
          SizedBox(height: 8.h),
          _buildChipSelector(
            widget.filterState.dayOfWeek,
            [
              {'value': 'all', 'label': '전체'},
              {'value': 'weekday', 'label': '평일'},
              {'value': 'weekend', 'label': '주말'},
              {'value': 'monday', 'label': '월요일'},
              {'value': 'tuesday', 'label': '화요일'},
              {'value': 'wednesday', 'label': '수요일'},
              {'value': 'thursday', 'label': '목요일'},
              {'value': 'friday', 'label': '금요일'},
              {'value': 'saturday', 'label': '토요일'},
              {'value': 'sunday', 'label': '일요일'},
            ],
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(dayOfWeek: value),
            ),
            isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSentimentFiltersTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dominant sentiment
          _buildSectionTitle('지배적 감정', isDark),
          SizedBox(height: 8.h),
          _buildChipSelector(
            widget.filterState.dominantSentiment,
            [
              {'value': 'all', 'label': '전체', 'color': Colors.grey},
              {'value': 'positive', 'label': '긍정적', 'color': Colors.green},
              {'value': 'neutral', 'label': '중립적', 'color': Colors.blue},
              {'value': 'negative', 'label': '부정적', 'color': Colors.red},
            ],
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(dominantSentiment: value),
            ),
            isDark,
            showColors: true,
          ),
          
          SizedBox(height: 16.h),
          
          // Positive reactions range
          _buildSectionTitle('긍정 반응 수', isDark),
          SizedBox(height: 8.h),
          _buildRangeFields(
            '긍정 반응',
            _controllers['minPositiveReactions']!,
            _controllers['maxPositiveReactions']!,
            (min, max) => widget.onFilterChanged(
              widget.filterState.copyWith(
                minPositiveReactions: min,
                maxPositiveReactions: max,
              ),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Neutral reactions range
          _buildSectionTitle('중립 반응 수', isDark),
          SizedBox(height: 8.h),
          _buildRangeFields(
            '중립 반응',
            _controllers['minNeutralReactions']!,
            _controllers['maxNeutralReactions']!,
            (min, max) => widget.onFilterChanged(
              widget.filterState.copyWith(
                minNeutralReactions: min,
                maxNeutralReactions: max,
              ),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Negative reactions range
          _buildSectionTitle('부정 반응 수', isDark),
          SizedBox(height: 8.h),
          _buildRangeFields(
            '부정 반응',
            _controllers['minNegativeReactions']!,
            _controllers['maxNegativeReactions']!,
            (min, max) => widget.onFilterChanged(
              widget.filterState.copyWith(
                minNegativeReactions: min,
                maxNegativeReactions: max,
              ),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Total reactions range
          _buildSectionTitle('총 반응 수', isDark),
          SizedBox(height: 8.h),
          _buildRangeFields(
            '총 반응',
            _controllers['minTotalReactions']!,
            _controllers['maxTotalReactions']!,
            (min, max) => widget.onFilterChanged(
              widget.filterState.copyWith(
                minTotalReactions: min,
                maxTotalReactions: max,
              ),
            ),
            isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityFiltersTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment count range
          _buildSectionTitle('댓글 수', isDark),
          SizedBox(height: 8.h),
          _buildRangeFields(
            '댓글',
            _controllers['minComments']!,
            _controllers['maxComments']!,
            (min, max) => widget.onFilterChanged(
              widget.filterState.copyWith(
                minComments: min,
                maxComments: max,
              ),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Activity level
          _buildSectionTitle('활동 수준', isDark),
          SizedBox(height: 8.h),
          _buildChipSelector(
            widget.filterState.activityLevel,
            [
              {'value': 'all', 'label': '전체'},
              {'value': 'high', 'label': '높음 (20+ 점수)'},
              {'value': 'medium', 'label': '보통 (5-19 점수)'},
              {'value': 'low', 'label': '낮음 (5점 미만)'},
            ],
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(activityLevel: value),
            ),
            isDark,
          ),
          
          SizedBox(height: 12.h),
          
          _buildInfoCard(
            '활동 점수 = 댓글 수 + (총 반응 수 × 0.5)',
            Icons.info_outline,
            isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiscFiltersTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room status
          _buildSectionTitle('토론방 상태', isDark),
          SizedBox(height: 8.h),
          _buildChipSelector(
            widget.filterState.roomStatus,
            [
              {'value': 'all', 'label': '전체'},
              {'value': 'active', 'label': '진행 중'},
              {'value': 'closed', 'label': '종료됨'},
            ],
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(roomStatus: value),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Has summary
          _buildSectionTitle('요약 정보', isDark),
          SizedBox(height: 8.h),
          _buildSwitchTile(
            '요약이 있는 토론방만',
            '자동 생성된 요약이 있는 토론방만 표시',
            widget.filterState.hasSummary,
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(hasSummary: value),
            ),
            isDark,
          ),
          
          SizedBox(height: 16.h),
          
          // Has multiple keywords
          _buildSectionTitle('키워드 연관성', isDark),
          SizedBox(height: 8.h),
          _buildSwitchTile(
            '다중 키워드 토론방만',
            '여러 키워드와 연관된 토론방만 표시',
            widget.filterState.hasMultipleKeywords,
            (value) => widget.onFilterChanged(
              widget.filterState.copyWith(hasMultipleKeywords: value),
            ),
            isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextColor(context),
      ),
    );
  }
  
  Widget _buildDateRangeSection(bool isDark) {
    DateTime? fromDate, toDate;
    Function(DateTime?) onFromChanged, onToChanged;
    
    switch (widget.filterState.dateFilterType) {
      case 'created_at':
        fromDate = widget.filterState.dateFromCreated;
        toDate = widget.filterState.dateToCreated;
        onFromChanged = (date) => widget.onFilterChanged(
          widget.filterState.copyWith(dateFromCreated: date),
        );
        onToChanged = (date) => widget.onFilterChanged(
          widget.filterState.copyWith(dateToCreated: date),
        );
        break;
      case 'updated_at':
        fromDate = widget.filterState.dateFromUpdated;
        toDate = widget.filterState.dateToUpdated;
        onFromChanged = (date) => widget.onFilterChanged(
          widget.filterState.copyWith(dateFromUpdated: date),
        );
        onToChanged = (date) => widget.onFilterChanged(
          widget.filterState.copyWith(dateToUpdated: date),
        );
        break;
      case 'closed_at':
        fromDate = widget.filterState.dateFromClosed;
        toDate = widget.filterState.dateToClosed;
        onFromChanged = (date) => widget.onFilterChanged(
          widget.filterState.copyWith(dateFromClosed: date),
        );
        onToChanged = (date) => widget.onFilterChanged(
          widget.filterState.copyWith(dateToClosed: date),
        );
        break;
      default:
        fromDate = null;
        toDate = null;
        onFromChanged = (_) {};
        onToChanged = (_) {};
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildDateField('시작일', fromDate, onFromChanged, isDark),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildDateField('종료일', toDate, onToChanged, isDark),
        ),
      ],
    );
  }
  
  Widget _buildDateField(String label, DateTime? value, Function(DateTime?) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.sp,
                    color: Color(0xFF6366F1),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      value != null 
                          ? DateFormat('MM/dd').format(value)
                          : '선택',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: value != null 
                            ? AppTheme.getTextColor(context)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                  if (value != null)
                    GestureDetector(
                      onTap: () => onChanged(null),
                      child: Icon(
                        Icons.clear,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField(
    String label,
    String value,
    List<Map<String, String>> options,
    Function(String) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: (newValue) => onChanged(newValue!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.getTextColor(context),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildChipSelector(
    String selectedValue,
    List<Map<String, dynamic>> options,
    Function(String) onChanged,
    bool isDark, {
    bool showColors = false,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final value = option['value'] as String;
        final label = option['label'] as String;
        final color = showColors ? (option['color'] as Color?) : null;
        final isSelected = selectedValue == value;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(value),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (color?.withOpacity(0.1) ?? Color(0xFF6366F1).withOpacity(0.1))
                    : null,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected 
                      ? (color ?? Color(0xFF6366F1))
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showColors && color != null) ...[
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? (color ?? Color(0xFF6366F1))
                          : AppTheme.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRangeFields(
    String label,
    TextEditingController minController,
    TextEditingController maxController,
    Function(int?, int?) onChanged,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            '최소',
            minController,
            (value) {
              final min = value.isEmpty ? null : int.tryParse(value);
              final max = maxController.text.isEmpty ? null : int.tryParse(maxController.text);
              onChanged(min, max);
            },
            isDark,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildNumberField(
            '최대',
            maxController,
            (value) {
              final min = minController.text.isEmpty ? null : int.tryParse(minController.text);
              final max = value.isEmpty ? null : int.tryParse(value);
              onChanged(min, max);
            },
            isDark,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '숫자',
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.getTextColor(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF334155) : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String text, IconData icon, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: Color(0xFF6366F1),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterActions(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Clear all controllers
                _controllers.values.forEach((controller) => controller.clear());
                // Reset filter state
                widget.onFilterChanged(widget.filterState.resetFilters());
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                '초기화',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onToggleExpansion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 16.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    '적용',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}