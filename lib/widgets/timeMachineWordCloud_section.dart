import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../app_theme.dart';

class TimeMachineWordCloudSection extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final String? wordCloudImagePath;

  const TimeMachineWordCloudSection({
    Key? key,
    required this.categoryColors,
    this.wordCloudImagePath,
  }) : super(key: key);

  @override
  State<TimeMachineWordCloudSection> createState() => _TimeMachineWordCloudSectionState();
}

class _TimeMachineWordCloudSectionState extends State<TimeMachineWordCloudSection> 
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  final List<WordParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeParticles();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeParticles() {
    final keywords = ['포켓몬', '갤럭시', 'AI', '트렌드', '뉴스', '키워드'];
    for (int i = 0; i < keywords.length; i++) {
      _particles.add(WordParticle(
        text: keywords[i],
        color: widget.categoryColors.values.elementAt(i % widget.categoryColors.length),
        initialX: math.Random().nextDouble(),
        initialY: math.Random().nextDouble(),
        speed: 0.3 + math.Random().nextDouble() * 0.4,
        size: 12 + math.Random().nextDouble() * 8,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFB39DDB), Color(0xFF9C27B0)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "키워드 클라우드",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "AI가 분석한 키워드 연관성을 시각화",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 워드클라우드 컨테이너
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            width: double.infinity,
            height: 260.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                    : [Colors.white, Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Stack(
                children: [
                  // 배경 그라데이션
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: isDark
                            ? [
                                Color(0xFF1E293B).withOpacity(0.8),
                                Color(0xFF0F172A),
                              ]
                            : [
                                Color(0xFFF8FAFC),
                                Color(0xFFE2E8F0),
                              ],
                      ),
                    ),
                  ),
                  
                  // 애니메이션 파티클
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WordCloudPainter(
                          particles: _particles,
                          animationValue: _particleController.value,
                          pulseValue: _pulseController.value,
                          isDark: isDark,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                  
                  // 중앙 AI 로고
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF3B82F6).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 32.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // 글래스 오버레이
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
              .scale(begin: Offset(0.98, 0.98), end: Offset(1, 1), duration: 600.ms),
          
          SizedBox(height: 24.h),
          
          // 카테고리 레전드
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Color(0xFF1E3A8A).withOpacity(0.2), Color(0xFF3B82F6).withOpacity(0.1)]
                    : [Color(0xFFE0E7FF), Color(0xFFEEF2FF)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "카테고리 색상 가이드",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  children: widget.categoryColors.entries.map((entry) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: entry.value.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: entry.value.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: entry.value.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: entry.value,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 500.ms, delay: 1000.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isDark) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B82F6).withOpacity(0.1),
                      Color(0xFFB39DDB).withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFFB39DDB)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 36.sp,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          Text(
            "AI 분석 중...",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            "키워드 연관성을 분석하여\n워드클라우드를 생성하고 있습니다",
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 24.h),
          
          Container(
            width: 200.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFFB39DDB)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms)
                    .slideX(duration: 2000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WordParticle {
  final String text;
  final Color color;
  final double initialX;
  final double initialY;
  final double speed;
  final double size;

  WordParticle({
    required this.text,
    required this.color,
    required this.initialX,
    required this.initialY,
    required this.speed,
    required this.size,
  });
}

class WordCloudPainter extends CustomPainter {
  final List<WordParticle> particles;
  final double animationValue;
  final double pulseValue;
  final bool isDark;

  WordCloudPainter({
    required this.particles,
    required this.animationValue,
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      
      // 원형 궤도 계산
      final angle = (animationValue * math.pi * 2 * particle.speed) + (i * math.pi * 2 / particles.length);
      final radius = (size.width * 0.25) + (math.sin(animationValue * math.pi * 2 + i) * 20);
      
      final x = size.width * 0.5 + math.cos(angle) * radius;
      final y = size.height * 0.5 + math.sin(angle) * radius;
      
      // 텍스트 스타일
      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.text,
          style: TextStyle(
            color: particle.color.withOpacity(0.7 + pulseValue * 0.3),
            fontSize: particle.size + (pulseValue * 4),
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: particle.color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // 텍스트 중심 맞추기
      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      
      // 글로우 효과
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(Offset(x, y), 15 + pulseValue * 5, glowPaint);
      
      // 텍스트 그리기
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}