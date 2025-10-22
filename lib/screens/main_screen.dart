import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../components/_components.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/eula_dialog.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // 홈을 기본 탭으로 설정
  bool _hasCheckedEula = false;

  final List<Widget> _widgetOptions = <Widget>[
    HistoryHomeComponent(),  // 0: 탐험
    KeywordHomeComponent(),   // 1: 홈
    MypageHomeComponent(),    // 2: 설정
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // EULA 체크는 첫 번째 화면 빌드 후에 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEulaAgreement();
    });
  }

  void _checkEulaAgreement() {
    // iOS에서만 EULA 확인
    if (!Platform.isIOS) return;

    final userPrefs = Provider.of<UserPreferenceProvider>(context, listen: false);

    // 이미 체크했거나 동의했으면 더 이상 체크하지 않음
    if (_hasCheckedEula || userPrefs.hasAcceptedEula) {
      setState(() {
        _hasCheckedEula = true;
      });
      return;
    }

    // EULA 미동의 상태이면 팝업 표시
    _showEulaDialog();
  }

  void _showEulaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부 탭으로 닫을 수 없음
      builder: (context) => const EulaDialog(),
    ).then((_) {
      // 다이얼로그가 닫힌 후 상태 업데이트
      setState(() {
        _hasCheckedEula = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = Provider.of<UserPreferenceProvider>(context);

    // iOS에서 EULA 미동의 상태면 컨텐츠 숨김
    final shouldShowContent = !Platform.isIOS || userPrefs.hasAcceptedEula;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        top: true,
        bottom: false, // 하단 SafeArea는 AppBarComponent에서 처리
        child: shouldShowContent
          ? Column(
              children: [
                // 메인 컨텐츠 영역
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _widgetOptions,
                  ),
                ),

                // 하단 앱바
                AppBarComponent(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                )
              ],
            )
          : Container(
              color: AppTheme.getBackgroundColor(context),
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF2196F3),
                ),
              ),
            ),
      ),
    );
  }
}