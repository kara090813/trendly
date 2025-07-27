# Large-Scale Discussion History System Architecture

## Executive Summary

This document outlines the architectural design for a scalable discussion history system capable of handling 10,000+ discussion rooms with advanced filtering, search, and pagination capabilities. The design addresses performance, scalability, and user experience challenges through a multi-layered approach combining database optimization, intelligent caching, and modern UI patterns.

## Current System Limitations

### Performance Issues
- Client-side timeline grouping fails at scale (10,000+ items)
- No efficient database indexing strategy
- Simple offset-based pagination degrades with large datasets
- Filtering happens after data fetch instead of server-side
- No caching layer for frequently accessed data

### Scalability Concerns
- Memory consumption grows linearly with dataset size
- API response times increase with data volume
- No horizontal scaling strategy
- Missing optimization for common query patterns

## Proposed Architecture

### 1. Database Layer Design

#### Optimized Schema
```sql
-- Enhanced discussion_rooms table with optimized indexes
CREATE TABLE discussion_rooms_optimized (
    id SERIAL PRIMARY KEY,
    keyword VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    closed_at TIMESTAMP WITH TIME ZONE,
    comment_count INTEGER DEFAULT 0,
    reaction_total INTEGER DEFAULT 0,
    positive_count INTEGER DEFAULT 0,
    neutral_count INTEGER DEFAULT 0,
    negative_count INTEGER DEFAULT 0,
    comment_summary TEXT,
    search_vector TSVECTOR -- Full-text search
);

-- Composite indexes for efficient filtering
CREATE INDEX idx_rooms_closed_category_date ON discussion_rooms_optimized 
    (is_closed, category, created_at DESC);
CREATE INDEX idx_rooms_closed_date ON discussion_rooms_optimized 
    (is_closed, created_at DESC);
CREATE INDEX idx_rooms_search ON discussion_rooms_optimized 
    USING gin(search_vector);
CREATE INDEX idx_rooms_category ON discussion_rooms_optimized (category);

-- Partitioning by date for historical data
CREATE TABLE discussion_rooms_2024_q1 PARTITION OF discussion_rooms_optimized
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
```

#### Denormalized Views
```sql
-- Pre-aggregated statistics view
CREATE MATERIALIZED VIEW discussion_stats AS
SELECT 
    category,
    DATE_TRUNC('month', created_at) as month,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_closed THEN 1 END) as closed_count,
    AVG(comment_count) as avg_comments,
    AVG(reaction_total) as avg_reactions
FROM discussion_rooms_optimized
GROUP BY category, DATE_TRUNC('month', created_at);

-- Refresh strategy
CREATE INDEX idx_discussion_stats_category_month ON discussion_stats (category, month);
```

### 2. API Design

#### RESTful Endpoints
```typescript
// Advanced history API with cursor-based pagination
GET /api/discussion/history
Query Parameters:
- cursor: string (base64 encoded pagination token)
- limit: number (default: 20, max: 100)
- category: string[] (multiple categories)
- date_from: ISO8601 date
- date_to: ISO8601 date
- search: string (full-text search)
- sort: 'newest' | 'oldest' | 'popular' | 'active'
- min_comments: number
- max_comments: number
- sentiment_ratio: 'positive' | 'neutral' | 'negative'

Response:
{
  "data": DiscussionRoom[],
  "pagination": {
    "next_cursor": string | null,
    "has_next_page": boolean,
    "total_count": number,
    "page_info": {
      "current_page": number,
      "total_pages": number
    }
  },
  "aggregations": {
    "categories": { [key: string]: number },
    "date_distribution": { [key: string]: number },
    "sentiment_summary": {
      "positive": number,
      "neutral": number, 
      "negative": number
    }
  }
}

// Filter suggestions endpoint
GET /api/discussion/history/suggest
Query Parameters:
- type: 'category' | 'keyword' | 'date_range'
- context: string (current filter context)

// Export endpoint for large datasets
POST /api/discussion/history/export
Body: {
  "filters": FilterObject,
  "format": "csv" | "json" | "excel",
  "email": string (for async delivery)
}
```

#### GraphQL Alternative (Future)
```graphql
type Query {
  discussionHistory(
    filters: HistoryFilters!
    pagination: PaginationInput!
    sort: SortInput
  ): HistoryResult!
}

type HistoryFilters {
  categories: [String!]
  dateRange: DateRangeInput
  search: String
  commentRange: IntRangeInput
  sentimentRatio: SentimentFilter
}

type HistoryResult {
  discussions: [DiscussionRoom!]!
  aggregations: Aggregations!
  pagination: PaginationInfo!
}
```

### 3. Caching Strategy

#### Multi-Layer Caching
```typescript
// Redis caching structure
interface CacheStructure {
  // Frequently accessed aggregations (TTL: 1 hour)
  "stats:categories": { [category: string]: number };
  "stats:monthly": { [month: string]: MonthlyStats };
  
  // Query result caching (TTL: 15 minutes)
  "query:{hash}": {
    data: DiscussionRoom[];
    timestamp: number;
    filters: FilterObject;
  };
  
  // User-specific caches (TTL: 30 minutes)
  "user:{id}:recent_searches": string[];
  "user:{id}:saved_filters": FilterObject[];
}

// Cache invalidation strategy
class CacheManager {
  async invalidateOnNewDiscussion(discussionId: number) {
    // Invalidate category stats
    await redis.del('stats:categories');
    
    // Invalidate relevant monthly stats
    const month = new Date().toISOString().substring(0, 7);
    await redis.del(`stats:monthly:${month}`);
    
    // Invalidate query caches containing this discussion
    const pattern = 'query:*';
    const keys = await redis.keys(pattern);
    // Batch invalidation logic
  }
}
```

#### Client-Side Caching
```typescript
// React Query configuration for client caching
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 3,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
    },
  },
});

// Custom hook for history data
function useDiscussionHistory(filters: FilterObject) {
  return useInfiniteQuery(
    ['discussion-history', filters],
    ({ pageParam }) => fetchHistoryPage(filters, pageParam),
    {
      getNextPageParam: (lastPage) => lastPage.pagination.next_cursor,
      select: (data) => ({
        pages: data.pages,
        pageParams: data.pageParams,
        allDiscussions: data.pages.flatMap(page => page.data),
      }),
    }
  );
}
```

### 4. UI Component Architecture

#### Component Hierarchy
```typescript
// Main container component
export const DiscussionHistorySystem: React.FC = () => {
  return (
    <HistoryProvider>
      <HistoryLayout>
        <FilterPanel />
        <SearchBar />
        <ResultsSection>
          <ViewModeSelector />
          <VirtualizedResultsList />
          <LoadMoreTrigger />
        </ResultsSection>
        <StatsPanel />
      </HistoryLayout>
    </HistoryProvider>
  );
};

// Context for shared state management
interface HistoryContextValue {
  filters: FilterState;
  updateFilters: (updates: Partial<FilterState>) => void;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  sortOption: SortOption;
  setSortOption: (sort: SortOption) => void;
  viewMode: 'timeline' | 'list' | 'grid';
  setViewMode: (mode: ViewMode) => void;
}

// Filter state management with useReducer
interface FilterState {
  categories: string[];
  dateRange: [Date?, Date?];
  commentRange: [number, number];
  sentimentFilter: SentimentFilter | null;
  savedSearches: SavedSearch[];
}

type FilterAction = 
  | { type: 'SET_CATEGORIES'; payload: string[] }
  | { type: 'SET_DATE_RANGE'; payload: [Date?, Date?] }
  | { type: 'RESET_FILTERS' }
  | { type: 'APPLY_SAVED_SEARCH'; payload: SavedSearch };
```

#### Advanced Filtering Components
```typescript
// Filter builder component
export const AdvancedFilterPanel: React.FC = () => {
  const [filterGroups, setFilterGroups] = useState<FilterGroup[]>([]);
  const [logicalOperator, setLogicalOperator] = useState<'AND' | 'OR'>('AND');

  return (
    <FilterBuilder>
      <FilterGroupList>
        {filterGroups.map((group, index) => (
          <FilterGroup key={group.id} group={group} index={index}>
            <FilterField type={group.type} />
            <FilterOperator operator={group.operator} />
            <FilterValue value={group.value} />
          </FilterGroup>
        ))}
      </FilterGroupList>
      <FilterActions>
        <AddFilterButton />
        <LogicalOperatorSelector />
        <SaveFilterButton />
        <ApplyFiltersButton />
      </FilterActions>
    </FilterBuilder>
  );
};

// Virtualized results list for performance
export const VirtualizedResultsList: React.FC = () => {
  const { data, fetchNextPage, hasNextPage } = useDiscussionHistory(filters);
  
  const allItems = useMemo(() => 
    data?.pages.flatMap(page => page.data) ?? [], [data]
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={allItems.length}
      itemSize={120}
      onItemsRendered={({ visibleStopIndex }) => {
        // Trigger next page load when near end
        if (visibleStopIndex > allItems.length - 5 && hasNextPage) {
          fetchNextPage();
        }
      }}
    >
      {({ index, style }) => (
        <div style={style}>
          <DiscussionHistoryItem 
            discussion={allItems[index]} 
            index={index}
          />
        </div>
      )}
    </FixedSizeList>
  );
};
```

### 5. Performance Optimizations

#### Database Query Optimization
```sql
-- Optimized query for common filtering scenarios
WITH filtered_discussions AS (
  SELECT *
  FROM discussion_rooms_optimized
  WHERE is_closed = true
    AND ($1::text IS NULL OR category = ANY($1::text[]))
    AND ($2::timestamp IS NULL OR created_at >= $2::timestamp)
    AND ($3::timestamp IS NULL OR created_at <= $3::timestamp)
    AND ($4::text IS NULL OR search_vector @@ plainto_tsquery($4))
    AND comment_count BETWEEN $5 AND $6
  ORDER BY 
    CASE WHEN $7 = 'newest' THEN created_at END DESC,
    CASE WHEN $7 = 'oldest' THEN created_at END ASC,
    CASE WHEN $7 = 'popular' THEN reaction_total END DESC,
    CASE WHEN $7 = 'active' THEN comment_count END DESC
  LIMIT $8 OFFSET $9
)
SELECT 
  fd.*,
  COUNT(*) OVER() as total_count
FROM filtered_discussions fd;

-- Query plan analysis and index usage monitoring
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM discussion_rooms_optimized 
WHERE is_closed = true AND category = '정치' 
ORDER BY created_at DESC LIMIT 20;
```

#### Client-Side Performance
```typescript
// Memoization strategies
const DiscussionHistoryItem = React.memo<HistoryItemProps>(({ discussion }) => {
  const formattedDate = useMemo(() => 
    formatDistanceToNow(discussion.created_at), [discussion.created_at]
  );
  
  const categoryColor = useMemo(() => 
    getCategoryColor(discussion.category), [discussion.category]
  );

  return (
    <HistoryItemContainer>
      <CategoryBadge color={categoryColor} />
      <DiscussionTitle>{discussion.keyword}</DiscussionTitle>
      <TimeStamp>{formattedDate}</TimeStamp>
      <StatsRow>
        <CommentCount count={discussion.comment_count} />
        <ReactionSummary reactions={discussion.reactions} />
      </StatsRow>
    </HistoryItemContainer>
  );
}, (prevProps, nextProps) => {
  // Custom comparison for deep equality on discussion object
  return prevProps.discussion.id === nextProps.discussion.id &&
         prevProps.discussion.comment_count === nextProps.discussion.comment_count;
});

// Debounced search with smart caching
const useDebounedSearch = (query: string, delay: number = 300) => {
  const [debouncedQuery, setDebouncedQuery] = useState(query);
  
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), delay);
    return () => clearTimeout(timer);
  }, [query, delay]);
  
  return debouncedQuery;
};
```

### 6. Migration Strategy

#### Phase 1: Database Foundation (Week 1-2)
```sql
-- Migration script for existing data
-- Add new indexes without blocking
CREATE INDEX CONCURRENTLY idx_rooms_closed_category_date_new 
ON discussion_rooms (is_closed, category, created_at DESC);

-- Create new optimized table structure
CREATE TABLE discussion_rooms_v2 AS 
SELECT *, 
  to_tsvector('korean', coalesce(keyword, '') || ' ' || coalesce(comment_summary, '')) as search_vector
FROM discussion_rooms;

-- Data verification and validation
SELECT 
  (SELECT COUNT(*) FROM discussion_rooms) as old_count,
  (SELECT COUNT(*) FROM discussion_rooms_v2) as new_count,
  (SELECT COUNT(*) FROM discussion_rooms_v2 WHERE search_vector IS NOT NULL) as search_ready;
```

#### Phase 2: API Enhancement (Week 3-4)
```typescript
// Feature flag implementation
interface FeatureFlags {
  useAdvancedHistoryAPI: boolean;
  enableCursorPagination: boolean;
  enableAdvancedFiltering: boolean;
}

// Gradual rollout with A/B testing
const HistoryComponent: React.FC = () => {
  const featureFlags = useFeatureFlags();
  
  if (featureFlags.useAdvancedHistoryAPI) {
    return <AdvancedHistorySystem />;
  }
  
  return <LegacyHistorySystem />;
};
```

#### Phase 3: Performance & Caching (Week 5-6)
- Redis cluster setup
- Query result caching implementation
- Client-side optimization deployment

#### Phase 4: Advanced Features (Week 7-8)
- ML-based recommendations
- Advanced analytics dashboard
- Export functionality

### 7. Monitoring & Analytics

#### Performance Metrics
```typescript
// Performance monitoring integration
interface PerformanceMetrics {
  queryResponseTime: number[];
  cacheHitRatio: number;
  searchQueryFrequency: Map<string, number>;
  filterUsagePatterns: FilterAnalytics;
  userEngagementMetrics: EngagementData;
}

// Custom hooks for performance tracking
const usePerformanceTracking = () => {
  const trackQuery = useCallback((queryType: string, duration: number) => {
    analytics.track('history_query_performance', {
      query_type: queryType,
      duration_ms: duration,
      timestamp: Date.now()
    });
  }, []);
  
  const trackFilterUsage = useCallback((filters: FilterState) => {
    analytics.track('filter_usage', {
      active_filters: Object.keys(filters).filter(key => filters[key]),
      filter_complexity: calculateComplexity(filters)
    });
  }, []);
  
  return { trackQuery, trackFilterUsage };
};
```

#### Alert System
```yaml
# Performance monitoring alerts
alerts:
  - name: slow_history_queries
    condition: avg(query_duration_ms) > 1000
    duration: 5m
    action: notify_team
    
  - name: low_cache_hit_ratio
    condition: cache_hit_ratio < 0.7
    duration: 10m
    action: scale_redis
    
  - name: high_search_error_rate
    condition: error_rate > 0.05
    duration: 2m
    action: immediate_alert
```

### 8. Security Considerations

#### Input Validation & Sanitization
```typescript
// Search input sanitization
const sanitizeSearchQuery = (query: string): string => {
  // Remove SQL injection patterns
  const cleaned = query
    .replace(/[<>]/g, '')
    .replace(/script|javascript|vbscript/gi, '')
    .trim();
    
  // Limit length
  return cleaned.substring(0, 200);
};

// Rate limiting implementation
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many search requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
});
```

#### Data Privacy & GDPR Compliance
```sql
-- Data anonymization for old discussions
UPDATE discussion_rooms 
SET comment_summary = '[내용이 익명화되었습니다]'
WHERE created_at < NOW() - INTERVAL '2 years'
  AND contains_personal_info = true;

-- Right to be forgotten implementation
CREATE PROCEDURE anonymize_user_data(user_identifier TEXT)
AS $$
BEGIN
  UPDATE discussion_rooms 
  SET 
    keyword = regexp_replace(keyword, user_identifier, '[익명]', 'gi'),
    comment_summary = regexp_replace(comment_summary, user_identifier, '[익명]', 'gi')
  WHERE 
    keyword ILIKE '%' || user_identifier || '%' 
    OR comment_summary ILIKE '%' || user_identifier || '%';
END;
$$ LANGUAGE plpgsql;
```

## Implementation Timeline

### Phase 1: Foundation (Weeks 1-2)
- [ ] Database schema optimization
- [ ] Index creation and migration
- [ ] Basic API endpoint redesign
- [ ] Performance baseline establishment

### Phase 2: Core Features (Weeks 3-4)
- [ ] Cursor-based pagination
- [ ] Server-side filtering
- [ ] Redis caching layer
- [ ] A/B testing framework

### Phase 3: Advanced Features (Weeks 5-6)
- [ ] Advanced filtering UI
- [ ] Virtual scrolling implementation
- [ ] Full-text search optimization
- [ ] Export functionality

### Phase 4: Polish & Scale (Weeks 7-8)
- [ ] Performance monitoring
- [ ] Analytics dashboard
- [ ] Mobile optimization
- [ ] Documentation and training

## Success Metrics

### Performance Targets
- API response time: < 200ms (95th percentile)
- Cache hit ratio: > 80%
- Client-side render time: < 100ms
- Search query processing: < 500ms

### User Experience Goals
- Filter application: < 1s feedback
- Infinite scroll smoothness: 60fps
- Mobile responsiveness: Full feature parity
- Accessibility: WCAG 2.1 AA compliance

### Scalability Benchmarks
- Support 50,000+ concurrent discussions
- Handle 1,000+ concurrent users
- Process 10,000+ search queries/hour
- Maintain performance with 100,000+ historical records

## Risk Mitigation

### Technical Risks
- **Database migration downtime**: Use online migration tools and blue-green deployment
- **Cache invalidation complexity**: Implement gradual rollout with fallback to database
- **Performance regression**: Comprehensive load testing and rollback procedures

### Business Risks
- **User adoption**: Gradual feature rollout with user feedback loops
- **Data integrity**: Extensive testing and validation procedures
- **Compliance**: Regular security audits and privacy impact assessments

## Conclusion

This architecture provides a scalable, performant foundation for handling large-scale discussion history data while maintaining excellent user experience. The phased implementation approach minimizes risk while delivering incremental value. The system is designed to scale beyond current requirements and adapt to future needs through modular design and comprehensive monitoring.