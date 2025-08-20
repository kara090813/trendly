import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/firebase_messaging_service.dart';
import '../app_theme.dart';

/// 푸시 알림 설정 위젯
/// 사용자가 푸시 알림 허용/거부를 설정할 수 있는 토글 스위치
class PushNotificationSettingWidget extends StatefulWidget {
  const PushNotificationSettingWidget({Key? key}) : super(key: key);

  @override
  State<PushNotificationSettingWidget> createState() => _PushNotificationSettingWidgetState();
}

class _PushNotificationSettingWidgetState extends State<PushNotificationSettingWidget> {
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();
  bool _isPushAllowed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSetting();
  }

  /// 현재 푸시 알림 설정 상태 로드
  Future<void> _loadCurrentSetting() async {
    try {
      final bool isAllowed = await _fcmService.isPushNotificationAllowed();
      setState(() {
        _isPushAllowed = isAllowed;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading push setting: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 푸시 알림 설정 변경
  Future<void> _updatePushSetting(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _fcmService.updatePushNotificationPermission(value);
      setState(() {
        _isPushAllowed = value;
        _isLoading = false;
      });

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? '실시간 검색어 알림이 켜졌습니다' : '실시간 검색어 알림이 꺼졌습니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: value ? Colors.green : Colors.orange,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error updating push setting: $e');
      setState(() {
        _isLoading = false;
      });

      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '설정 변경에 실패했습니다. 다시 시도해주세요.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _isPushAllowed 
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _isPushAllowed ? Icons.notifications_active : Icons.notifications_off,
              color: _isPushAllowed 
                  ? Colors.blue
                  : isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20.sp,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '실시간 검색어 알림',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '인기 급상승 키워드를 실시간으로 알려드립니다',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 로딩 또는 스위치
          if (_isLoading)
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.blue[300]! : Colors.blue,
                ),
              ),
            )
          else
            Switch(
              value: _isPushAllowed,
              onChanged: _updatePushSetting,
              activeColor: Colors.blue,
              activeTrackColor: Colors.blue.withOpacity(0.3),
              inactiveThumbColor: isDark ? Colors.grey[600] : Colors.grey[400],
              inactiveTrackColor: isDark 
                  ? Colors.grey[800] 
                  : Colors.grey[300],
            ),
        ],
      ),
    );
  }
}

/// 푸시 알림 초기 설정 다이얼로그
/// 앱 최초 설치 후 사용자에게 푸시 알림 허용을 묻는 커스텀 다이얼로그
class PushNotificationPermissionDialog extends StatelessWidget {
  final VoidCallback? onAllowed;
  final VoidCallback? onDenied;

  const PushNotificationPermissionDialog({
    Key? key,
    this.onAllowed,
    this.onDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Colors.blue,
                size: 30.sp,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // 제목
            Text(
              '실시간 검색어 알림',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // 설명
            Text(
              '인기 급상승하는 검색어를\n실시간으로 알려드립니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // 버튼들
            Row(
              children: [
                // 거부 버튼
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDenied?.call();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Text(
                      '나중에',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 허용 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAllowed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '허용',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}