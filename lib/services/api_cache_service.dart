import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCacheService {
  static final ApiCacheService _instance = ApiCacheService._internal();
  factory ApiCacheService() => _instance;
  ApiCacheService._internal();

  static const String _cachePrefix = 'api_cache_';
  static const String _statsPrefix = 'stats_cache_';
  static const Duration _defaultTtl = Duration(minutes: 15);
  static const Duration _statsTtl = Duration(hours: 1);
  
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Performance metrics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _cacheEvictions = 0;
  
  // Cache history data with TTL
  Future<void> cacheHistoryData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': _defaultTtl.inMilliseconds,
      };
      
      // Store in both memory and persistent cache
      _memoryCache[key] = cacheEntry;
      _cacheTimestamps[key] = DateTime.now();
      
      await prefs.setString('$_cachePrefix$key', jsonEncode(cacheEntry));
      
      // Cleanup old entries to prevent cache bloat
      await _cleanupExpiredEntries();
    } catch (e) {
      print('Cache write failed: $e');
    }
  }
  
  // Retrieve cached history data
  Future<Map<String, dynamic>?> getHistoryData(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key] as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);
        final ttl = Duration(milliseconds: entry['ttl']);
        
        if (DateTime.now().difference(timestamp) < ttl) {
          _cacheHits++;
          return entry['data'] as Map<String, dynamic>;
        } else {
          _memoryCache.remove(key);
          _cacheTimestamps.remove(key);
        }
      }
      
      // Check persistent cache
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('$_cachePrefix$key');
      
      if (cachedJson != null) {
        final entry = jsonDecode(cachedJson) as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);
        final ttl = Duration(milliseconds: entry['ttl']);
        
        if (DateTime.now().difference(timestamp) < ttl) {
          // Promote to memory cache
          _memoryCache[key] = entry;
          _cacheTimestamps[key] = timestamp;
          _cacheHits++;
          return entry['data'] as Map<String, dynamic>;
        } else {
          // Remove expired entry
          await prefs.remove('$_cachePrefix$key');
        }
      }
      
      _cacheMisses++;
      return null;
    } catch (e) {
      print('Cache read failed: $e');
      _cacheMisses++;
      return null;
    }
  }
  
  // Get cache performance metrics
  Map<String, dynamic> getMetrics() {
    final totalRequests = _cacheHits + _cacheMisses;
    final hitRatio = totalRequests > 0 ? _cacheHits / totalRequests : 0.0;
    
    return {
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_evictions': _cacheEvictions,
      'hit_ratio': hitRatio,
      'memory_cache_size': _memoryCache.length,
      'total_requests': totalRequests,
    };
  }
  
  // Preload commonly accessed statistics
  Future<void> preloadStatistics() async {
    try {
      // This is a placeholder for preloading commonly accessed statistics
      // In a real implementation, this would preload aggregated data
      print('Preloading statistics cache...');
      
      // For now, this is a no-op method that can be extended later
      // to cache frequently accessed aggregations
    } catch (e) {
      print('Statistics preload failed: $e');
    }
  }
  
  // Clear expired cache entries
  Future<void> _cleanupExpiredEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
        key.startsWith(_cachePrefix) || key.startsWith(_statsPrefix)
      ).toList();
      
      int cleanedCount = 0;
      for (final key in keys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final entry = jsonDecode(cachedJson) as Map<String, dynamic>;
            final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);
            final ttl = Duration(milliseconds: entry['ttl']);
            
            if (DateTime.now().difference(timestamp) >= ttl) {
              await prefs.remove(key);
              cleanedCount++;
            }
          } catch (e) {
            // Remove corrupted entries
            await prefs.remove(key);
            cleanedCount++;
          }
        }
      }
      
      _cacheEvictions += cleanedCount;
    } catch (e) {
      print('Cache cleanup failed: $e');
    }
  }
}