import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/_models.dart';

class VirtualDiscussionList extends StatefulWidget {
  final List<DiscussionRoom> items;
  final Widget Function(DiscussionRoom room, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;
  final bool isLoading;
  final double itemHeight;
  final int? visibleItemCount;
  
  const VirtualDiscussionList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMoreData = false,
    this.isLoading = false,
    this.itemHeight = 120.0,
    this.visibleItemCount,
  });

  @override
  State<VirtualDiscussionList> createState() => _VirtualDiscussionListState();
}

class _VirtualDiscussionListState extends State<VirtualDiscussionList> {
  late ScrollController _scrollController;
  late int _visibleItemCount;
  
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _visibleItemCount = widget.visibleItemCount ?? 10; // Default value
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleRange();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now we can safely access MediaQuery
    if (widget.visibleItemCount == null) {
      _visibleItemCount = _calculateVisibleItemCount();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  int _calculateVisibleItemCount() {
    // Calculate based on screen height and item height
    final screenHeight = MediaQuery.of(context).size.height;
    return ((screenHeight / widget.itemHeight) * 1.5).ceil(); // 1.5x buffer
  }
  
  void _onScroll() {
    _updateVisibleRange();
    
    // Load more when approaching end
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - (widget.itemHeight * 3)) {
      _loadMore();
    }
  }
  
  void _updateVisibleRange() {
    if (!mounted) return;
    
    final scrollOffset = _scrollController.position.pixels;
    final newFirstVisible = (scrollOffset / widget.itemHeight).floor().clamp(0, widget.items.length - 1);
    final newLastVisible = (newFirstVisible + _visibleItemCount).clamp(0, widget.items.length - 1);
    
    if (newFirstVisible != _firstVisibleIndex || newLastVisible != _lastVisibleIndex) {
      setState(() {
        _firstVisibleIndex = newFirstVisible;
        _lastVisibleIndex = newLastVisible;
      });
    }
  }
  
  void _loadMore() {
    if (!_isLoadingMore && widget.hasMoreData && widget.onLoadMore != null) {
      setState(() {
        _isLoadingMore = true;
      });
      
      widget.onLoadMore!();
      
      // Reset loading state after a delay (will be updated by parent)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text('데이터가 없습니다'),
      );
    }
    
    // For small datasets, use regular ListView
    if (widget.items.length < 100) {
      return _buildRegularList();
    }
    
    // Use virtual scrolling for large datasets
    return _buildVirtualList();
  }
  
  Widget _buildRegularList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return _buildLoadingIndicator();
        }
        
        return SizedBox(
          height: widget.itemHeight,
          child: widget.itemBuilder(widget.items[index], index),
        );
      },
    );
  }
  
  Widget _buildVirtualList() {
    final totalHeight = widget.items.length * widget.itemHeight;
    
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: totalHeight + (widget.hasMoreData ? widget.itemHeight : 0),
          child: Stack(
            children: [
              // Render only visible items
              ..._buildVisibleItems(),
              
              // Loading indicator at bottom if needed
              if (widget.hasMoreData)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: widget.itemHeight,
                    child: _buildLoadingIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildVisibleItems() {
    final visibleItems = <Widget>[];
    
    // Add buffer before and after visible range for smooth scrolling
    final bufferSize = 5;
    final startIndex = (_firstVisibleIndex - bufferSize).clamp(0, widget.items.length - 1);
    final endIndex = (_lastVisibleIndex + bufferSize).clamp(0, widget.items.length - 1);
    
    for (int i = startIndex; i <= endIndex; i++) {
      if (i < widget.items.length) {
        visibleItems.add(
          Positioned(
            top: i * widget.itemHeight,
            left: 0,
            right: 0,
            child: SizedBox(
              height: widget.itemHeight,
              child: widget.itemBuilder(widget.items[i], i),
            ),
          ),
        );
      }
    }
    
    return visibleItems;
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      height: widget.itemHeight,
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}

// Performance monitoring widget
class VirtualListPerformanceMonitor extends StatelessWidget {
  final int totalItems;
  final int visibleItems;
  final double scrollPosition;
  final bool isVirtualized;
  
  const VirtualListPerformanceMonitor({
    super.key,
    required this.totalItems,
    required this.visibleItems,
    required this.scrollPosition,
    required this.isVirtualized,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Total: $totalItems items',
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
          Text(
            'Visible: $visibleItems items',
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
          Text(
            'Scroll: ${scrollPosition.toStringAsFixed(1)}px',
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
          Text(
            'Mode: ${isVirtualized ? "Virtual" : "Regular"}',
            style: TextStyle(
              color: isVirtualized ? Colors.green : Colors.orange,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}