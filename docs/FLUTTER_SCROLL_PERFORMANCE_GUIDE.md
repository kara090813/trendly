# Flutter 스크롤 성능 완벽 가이드

## 목차
1. [플랫폼별 스크롤 Physics](#플랫폼별-스크롤-physics)
2. [스크롤 위젯 선택 가이드](#스크롤-위젯-선택-가이드)
3. [성능 최적화 핵심 원칙](#성능-최적화-핵심-원칙)
4. [일반적인 성능 문제와 해결책](#일반적인-성능-문제와-해결책)

---

## 플랫폼별 스크롤 Physics

### ScrollPhysics 종류와 특성

#### 1. **BouncingScrollPhysics** (iOS 스타일)
```dart
CustomScrollView(
  physics: const BouncingScrollPhysics(),
)
```

**특성**:
- iOS 네이티브 스크롤 동작
- 경계를 넘어서면 "튕기는" 효과
- 부드러운 감속 곡선

**장점**:
- ✅ iOS에서 60fps 유지
- ✅ 사용자가 기대하는 iOS 네이티브 느낌
- ✅ 부드러운 UX

**단점**:
- ❌ Android에서 오버드로우(Overdraw) 발생
- ❌ Android 사용자에게 낯선 동작
- ❌ 추가 렌더링 비용

**권장 사용**:
- iOS 전용 앱
- iOS 우선 디자인
- 크로스 플랫폼에서는 조건부 사용

---

#### 2. **ClampingScrollPhysics** (Android 스타일)
```dart
CustomScrollView(
  physics: const ClampingScrollPhysics(),
)
```

**특성**:
- Android 네이티브 스크롤 동작
- 경계에서 멈추고 "글로우" 효과
- 빠른 감속

**장점**:
- ✅ Android에서 최적화된 성능
- ✅ 하드웨어 가속 활용
- ✅ 메모리 효율적

**단점**:
- ❌ iOS에서 어색한 느낌
- ❌ 급격한 멈춤이 부자연스러울 수 있음

**권장 사용**:
- Android 전용 앱
- Android 우선 디자인
- 크로스 플랫폼에서는 조건부 사용

---

#### 3. **AlwaysScrollableScrollPhysics**
```dart
ListView(
  physics: const AlwaysScrollableScrollPhysics(),
)
```

**특성**:
- 내용이 작아도 항상 스크롤 가능
- RefreshIndicator와 함께 사용 시 필수

**사용 시나리오**:
- Pull-to-refresh 구현
- 짧은 리스트도 스크롤 필요
- 일관된 스크롤 동작 보장

---

#### 4. **NeverScrollableScrollPhysics**
```dart
ListView(
  physics: const NeverScrollableScrollPhysics(),
)
```

**특성**:
- 스크롤 완전 비활성화
- 터치 이벤트는 하위 위젯으로 전달

**사용 시나리오**:
- 중첩 스크롤 방지
- PageView 내부 리스트
- 고정된 높이의 리스트

---

### 🎯 권장 패턴: 플랫폼별 조건부 Physics

```dart
import 'dart:io';

class ScrollConfig {
  // 일반 스크롤
  static ScrollPhysics get platformPhysics => Platform.isIOS
      ? const BouncingScrollPhysics()
      : const ClampingScrollPhysics();

  // 항상 스크롤 가능 (RefreshIndicator용)
  static ScrollPhysics get alwaysScrollablePhysics => Platform.isIOS
      ? const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        )
      : const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        );
}

// 사용 예시
CustomScrollView(
  physics: ScrollConfig.platformPhysics,
  slivers: [...],
)

// RefreshIndicator 사용 시
RefreshIndicator(
  onRefresh: _refresh,
  child: ListView(
    physics: ScrollConfig.alwaysScrollablePhysics,
    children: [...],
  ),
)
```

---

## 스크롤 위젯 선택 가이드

### 위젯 성능 비교표

| 위젯 | 성능 | 유연성 | 복잡도 | 권장 시나리오 |
|------|------|--------|--------|---------------|
| `ListView` | ⭐⭐⭐ | ⭐⭐ | ⭐ | 단순 리스트 |
| `ListView.builder` | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | 긴 리스트 |
| `ListView.separated` | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | 구분선 있는 리스트 |
| `CustomScrollView` | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 복합 스크롤 |
| `GridView.builder` | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | 그리드 레이아웃 |
| `SingleChildScrollView` | ⭐⭐ | ⭐⭐⭐⭐ | ⭐ | 작은 컨텐츠 |
| `PageView` | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | 페이지 전환 |

---

### 1. ListView vs ListView.builder

#### ❌ 비효율적: ListView (모든 아이템 즉시 생성)
```dart
ListView(
  children: List.generate(
    1000,
    (index) => ExpensiveWidget(index), // ❌ 1000개 모두 생성
  ),
)
```

**문제점**:
- 모든 위젯을 메모리에 로드
- 초기 빌드 시간 오래 걸림
- 불필요한 렌더링
- 메모리 사용량 급증

**성능**:
- 10개 아이템: 문제 없음
- 100개 아이템: 느려짐
- 1000개 아이템: 심각한 랙

---

#### ✅ 효율적: ListView.builder (지연 로딩)
```dart
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) {
    return ExpensiveWidget(index); // ✅ 보이는 것만 생성
  },
)
```

**장점**:
- 화면에 보이는 아이템만 생성
- 메모리 효율적
- 무한 스크롤 가능
- 빠른 초기 로딩

**성능**:
- 10개든 10000개든 동일한 성능
- 메모리 사용량 일정
- 60fps 유지

---

### 2. SingleChildScrollView의 함정

#### ❌ 피해야 할 패턴
```dart
SingleChildScrollView(
  child: Column(
    children: List.generate(
      1000,
      (index) => ExpensiveWidget(index), // ❌ 모두 즉시 렌더링
    ),
  ),
)
```

**문제점**:
- 모든 자식이 즉시 빌드됨
- 지연 로딩 없음
- 메모리 폭탄
- 스크롤 랙 필연적

**사용해야 하는 경우**:
- ✅ 작은 고정 컨텐츠 (< 10개 위젯)
- ✅ 폼 입력 화면
- ✅ 상세 페이지

---

#### ✅ 대안: CustomScrollView + SliverList
```dart
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ExpensiveWidget(index),
        childCount: 1000,
      ),
    ),
  ],
)
```

---

### 3. CustomScrollView - 최강의 성능과 유연성

#### 기본 구조
```dart
CustomScrollView(
  physics: ScrollConfig.platformPhysics,
  slivers: [
    // 고정 헤더
    SliverAppBar(
      floating: true,
      snap: true,
      title: Text('제목'),
    ),

    // 상단 고정 컨텐츠
    SliverToBoxAdapter(
      child: HeaderWidget(),
    ),

    // 효율적인 리스트
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListItem(index),
        childCount: 1000,
      ),
    ),

    // 그리드
    SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => GridItem(index),
        childCount: 100,
      ),
    ),

    // 하단 여백
    SliverToBoxAdapter(
      child: SizedBox(height: 100),
    ),
  ],
)
```

**장점**:
- ✅ 최고의 성능
- ✅ 무한한 조합 가능
- ✅ 지연 로딩
- ✅ 복잡한 스크롤 구현 가능

---

### 4. PageView 최적화

#### ❌ 비효율적
```dart
PageView(
  children: List.generate(
    100,
    (index) => HeavyPage(index), // ❌ 모든 페이지 생성
  ),
)
```

#### ✅ 효율적
```dart
PageView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return HeavyPage(index); // ✅ 현재 + 인접 페이지만 생성
  },
)
```

**추가 최적화**:
```dart
PageView.builder(
  controller: PageController(
    viewportFraction: 0.9, // 다음 페이지 미리보기
    keepPage: true, // 페이지 상태 유지
  ),
  physics: ScrollConfig.platformPhysics,
  itemCount: 100,
  itemBuilder: (context, index) => HeavyPage(index),
)
```

---

## 성능 최적화 핵심 원칙

### 1. 렌더링 최적화

#### RepaintBoundary - 렌더링 격리
```dart
// 원칙: 독립적으로 변경되는 위젯은 격리

RepaintBoundary(
  child: AnimatedWidget(), // 애니메이션 격리
)

RepaintBoundary(
  child: ComplexStaticWidget(), // 복잡하지만 정적인 위젯
)

RepaintBoundary(
  child: AdWidget(), // 외부 컨텐츠 격리
)
```

**사용 기준**:
- ✅ 자주 변경되는 위젯 (애니메이션, 타이머)
- ✅ 복잡하고 무거운 위젯
- ✅ 외부 컨텐츠 (광고, WebView)
- ❌ 간단한 텍스트나 아이콘
- ❌ 과도한 사용 (오히려 메모리 낭비)

---

#### const 생성자 - 빌드 최적화
```dart
// ❌ 매번 재생성
ListView.builder(
  itemBuilder: (context, index) {
    return Container(
      padding: EdgeInsets.all(16), // 매번 새로 생성
      child: Text('Item $index'),
    );
  },
)

// ✅ 한 번만 생성
const kItemPadding = EdgeInsets.all(16);

ListView.builder(
  itemBuilder: (context, index) {
    return Container(
      padding: kItemPadding, // 재사용
      child: Text('Item $index'),
    );
  },
)

// ✅✅ 완전히 const
class StaticWidget extends StatelessWidget {
  const StaticWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Never rebuilds');
  }
}
```

**원칙**:
- 변하지 않는 위젯은 무조건 const
- EdgeInsets, TextStyle 등은 상수로 추출
- const 생성자 최대한 활용

---

### 2. 메모리 최적화

#### cacheExtent - 스크롤 캐시 제어
```dart
// 기본값: 250 픽셀
ListView.builder(
  cacheExtent: 500, // 화면 밖 500px까지 캐싱
  itemBuilder: (context, index) => Item(index),
)
```

**설정 기준**:
| 상황 | cacheExtent | 이유 |
|------|-------------|------|
| 간단한 리스트 | 250-500 | 기본값 적절 |
| 복잡한 아이템 | 100-250 | 메모리 절약 |
| 빠른 스크롤 | 1000-2000 | 버퍼 확보 |
| 무한 스크롤 | 500-1000 | 균형 잡힌 설정 |

---

#### addAutomaticKeepAlives - 위젯 유지 제어
```dart
ListView.builder(
  addAutomaticKeepAlives: true, // 기본값: true
  itemBuilder: (context, index) => Item(index),
)
```

**설정 기준**:
- `true`: 스크롤 해도 위젯 상태 유지 (메모리 많이 사용)
- `false`: 화면 벗어나면 삭제 (메모리 절약)

**권장**:
```dart
// ❌ 상태 없는 간단한 리스트에서 true
ListView.builder(
  addAutomaticKeepAlives: true, // 불필요
  itemBuilder: (context, index) => Text('Item $index'),
)

// ✅ 상태 없으면 false로 설정
ListView.builder(
  addAutomaticKeepAlives: false, // 메모리 절약
  itemBuilder: (context, index) => Text('Item $index'),
)

// ✅ 상태 유지 필요하면 명시적으로 관리
class StatefulItem extends StatefulWidget {
  @override
  State<StatefulItem> createState() => _StatefulItemState();
}

class _StatefulItemState extends State<StatefulItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 명시적 관리

  @override
  Widget build(BuildContext context) {
    super.build(context); // 필수
    return /* 위젯 */;
  }
}
```

---

### 3. 빌드 최적화

#### Builder 패턴으로 리빌드 범위 제한
```dart
// ❌ 전체 화면 리빌드
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveStaticWidget(), // ❌ 매번 리빌드
        Text('Count: $counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// ✅ 필요한 부분만 리빌드
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveStaticWidget(), // ✅ 리빌드 안 됨
        CounterWidget(), // ✅ 이것만 리빌드
      ],
    );
  }
}

class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

---

#### ValueListenableBuilder - 정밀한 리빌드
```dart
class OptimizedCounter extends StatelessWidget {
  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveStaticWidget(), // ✅ 절대 리빌드 안 됨
        ValueListenableBuilder<int>(
          valueListenable: counter,
          builder: (context, value, child) {
            return Text('Count: $value'); // ✅ 이것만 리빌드
          },
        ),
        ElevatedButton(
          onPressed: () => counter.value++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

---

### 4. 이미지 최적화

#### 올바른 이미지 로딩
```dart
// ❌ 비효율적
Image.network(
  'https://example.com/large-image.jpg', // 원본 크기 그대로
)

// ✅ 효율적
Image.network(
  'https://example.com/large-image.jpg',
  cacheWidth: 500, // 실제 표시 크기로 리사이징
  cacheHeight: 500,
  fit: BoxFit.cover,
)

// ✅✅ 더 효율적 (캐싱 + 리사이징)
CachedNetworkImage(
  imageUrl: 'https://example.com/large-image.jpg',
  memCacheWidth: 500,
  memCacheHeight: 500,
  fit: BoxFit.cover,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**원칙**:
- 항상 `cacheWidth`, `cacheHeight` 지정
- 썸네일은 작은 크기로 요청
- `CachedNetworkImage` 사용 (pub.dev)
- 로컬 이미지는 적절한 해상도로 준비

---

### 5. 애니메이션 최적화

#### AnimatedBuilder vs setState
```dart
// ❌ 비효율적 - 전체 위젯 리빌드
class AnimatedWidget extends StatefulWidget {
  @override
  State<AnimatedWidget> createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _controller.addListener(() {
      setState(() {}); // ❌ 전체 리빌드
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveStaticWidget(), // ❌ 매 프레임마다 리빌드
        Transform.rotate(
          angle: _controller.value * 2 * 3.14,
          child: Icon(Icons.refresh),
        ),
      ],
    );
  }
}

// ✅ 효율적 - 애니메이션 부분만 리빌드
class AnimatedWidget extends StatefulWidget {
  @override
  State<AnimatedWidget> createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveStaticWidget(), // ✅ 한 번만 빌드
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14,
              child: child, // ✅ 캐시된 child 재사용
            );
          },
          child: Icon(Icons.refresh), // ✅ 한 번만 생성
        ),
      ],
    );
  }
}
```

---

### 6. 네트워크 최적화

#### 페이지네이션 (무한 스크롤)
```dart
class InfiniteListView extends StatefulWidget {
  @override
  State<InfiniteListView> createState() => _InfiniteListViewState();
}

class _InfiniteListViewState extends State<InfiniteListView> {
  final List<Item> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      // 하단 200px 전에 다음 페이지 로드
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await fetchItems(_page);
      setState(() {
        _items.addAll(newItems);
        _page++;
        _hasMore = newItems.length == 20; // 페이지당 20개
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(child: CircularProgressIndicator());
        }
        return ItemWidget(_items[index]);
      },
    );
  }
}
```

---

## 일반적인 성능 문제와 해결책

### 문제 1: 스크롤하면 버벅거림

**원인**:
- 복잡한 위젯 트리
- 과도한 리빌드
- 무거운 계산

**해결**:
```dart
// 1. RepaintBoundary로 격리
ListView.builder(
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: ComplexItem(index),
    );
  },
)

// 2. const 생성자 사용
ListView.builder(
  itemBuilder: (context, index) {
    return const SimpleItem(); // 변하지 않으면 const
  },
)

// 3. 무거운 계산 분리
class _MyWidgetState extends State<MyWidget> {
  late final computedValue = expensiveCalculation(); // initState나 여기서 한 번만

  @override
  Widget build(BuildContext context) {
    return Text('$computedValue');
  }
}
```

---

### 문제 2: 초기 로딩이 느림

**원인**:
- 모든 데이터 한 번에 로드
- 큰 이미지
- 동기 작업

**해결**:
```dart
// 1. 페이지네이션
final initialItems = await fetchItems(page: 1, limit: 20);

// 2. 이미지 지연 로딩
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => Shimmer(),
)

// 3. 비동기 초기화
@override
void initState() {
  super.initState();
  // ❌ 동기
  final data = fetchData(); // 화면 멈춤

  // ✅ 비동기
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData(); // 화면 그린 후 로드
  });
}
```

---

### 문제 3: 메모리 사용량 증가

**원인**:
- 이미지 캐시 과다
- 위젯 상태 과도하게 유지
- 리스너/컨트롤러 해제 안 함

**해결**:
```dart
// 1. 이미지 캐시 제한
void main() {
  PaintingBinding.instance.imageCache.maximumSize = 100; // 최대 100개
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB

  runApp(MyApp());
}

// 2. AutomaticKeepAlives 제어
ListView.builder(
  addAutomaticKeepAlives: false, // 상태 유지 안 함
  itemBuilder: (context, index) => Item(index),
)

// 3. 리소스 정리
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  _scrollController.dispose();
  super.dispose();
}
```

---

### 문제 4: 중첩 스크롤 충돌

**원인**:
- PageView 안에 ListView
- ListView 안에 ListView

**해결**:
```dart
// ❌ 충돌
PageView(
  children: [
    ListView(...), // 스크롤 방향 충돌
  ],
)

// ✅ 해결 1: 내부 스크롤 비활성화
PageView(
  children: [
    ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [...],
    ),
  ],
)

// ✅ 해결 2: 스크롤 방향 다르게
PageView( // 가로 스크롤
  scrollDirection: Axis.horizontal,
  children: [
    ListView( // 세로 스크롤
      scrollDirection: Axis.vertical,
      children: [...],
    ),
  ],
)

// ✅ 해결 3: NestedScrollView 사용
NestedScrollView(
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [SliverAppBar(...)];
  },
  body: ListView(...),
)
```

---

## 성능 측정 도구

### 1. Flutter DevTools
```bash
flutter run --profile
# DevTools에서 Performance 탭 확인
```

**주요 지표**:
- Frame rendering time: < 16ms (60fps)
- GPU usage: < 80%
- Memory usage: 일정하게 유지
- Rasterization: 최소화

---

### 2. 코드로 측정
```dart
import 'package:flutter/scheduler.dart';

void measurePerformance() {
  // FPS 측정
  SchedulerBinding.instance.addTimingsCallback((timings) {
    for (final timing in timings) {
      final fps = 1000000 / timing.totalSpan.inMicroseconds;
      if (fps < 55) {
        print('⚠️ Frame drop: ${fps.toStringAsFixed(1)} FPS');
      }
    }
  });

  // 빌드 시간 측정
  final stopwatch = Stopwatch()..start();
  final widget = build(context);
  stopwatch.stop();
  print('Build time: ${stopwatch.elapsedMilliseconds}ms');
}
```

---

## 체크리스트

### 새 화면 개발 시
- [ ] 플랫폼별 ScrollPhysics 적용
- [ ] ListView.builder 사용 (리스트가 10개 이상이면)
- [ ] 이미지에 cacheWidth/cacheHeight 지정
- [ ] const 생성자 최대한 활용
- [ ] 복잡한 위젯은 RepaintBoundary로 격리
- [ ] 애니메이션은 AnimatedBuilder 사용
- [ ] 네트워크 데이터는 페이지네이션

### 성능 문제 발생 시
1. [ ] DevTools로 프레임 드롭 확인
2. [ ] 로그에서 반복 렌더링 검토
3. [ ] 이미지 크기 확인 (원본 크기로 로드하는지)
4. [ ] 리스트 위젯 종류 확인 (builder 패턴인지)
5. [ ] setState 호출 범위 확인 (최소화되었는지)
6. [ ] 중첩 스크롤 여부 확인

---

## 참고 자료

### 공식 문서
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Improving Rendering Performance](https://docs.flutter.dev/perf/rendering-performance)
- [Performance Profiling](https://docs.flutter.dev/perf/ui-performance)

### 유용한 패키지
- `flutter_hooks`: 상태 관리 간소화
- `cached_network_image`: 이미지 캐싱
- `shimmer`: 로딩 플레이스홀더
- `visibility_detector`: 뷰포트 감지
- `lazy_load_scrollview`: 무한 스크롤

---

## 성능 최적화 우선순위

### 🔴 Critical (필수)
1. ListView → ListView.builder
2. 플랫폼별 ScrollPhysics
3. 이미지 리사이징 (cacheWidth/Height)
4. 리소스 정리 (dispose)

### 🟡 Important (권장)
1. const 생성자 활용
2. RepaintBoundary 적용
3. 페이지네이션 구현
4. AnimatedBuilder 사용

### 🟢 Nice to Have (선택)
1. cacheExtent 조정
2. addAutomaticKeepAlives 최적화
3. 커스텀 ScrollPhysics 구현
4. 세밀한 리빌드 제어

---

**마지막 업데이트**: 2025-10-13
**작성자**: Flutter Performance Team
