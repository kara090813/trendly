import WidgetKit
import SwiftUI
import Intents
import AppIntents

struct TrendlyWidget: Widget {
    let kind: String = "TrendlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TrendlyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Trendly 트렌드")
        .description("실시간 트렌드 키워드를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), keywords: [
            KeywordData(id: 1, keyword: "로딩중", rank: 1),
            KeywordData(id: 2, keyword: "로딩중", rank: 2),
            KeywordData(id: 3, keyword: "로딩중", rank: 3),
            KeywordData(id: 4, keyword: "로딩중", rank: 4),
            KeywordData(id: 5, keyword: "로딩중", rank: 5)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), keywords: getKeywordsFromUserDefaults())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let keywords = getKeywordsFromUserDefaults()
        let currentDate = Date()
        
        // 현재 엔트리 + 자동 업데이트 엔트리들 생성
        var entries: [SimpleEntry] = []
        
        // 현재 엔트리
        entries.append(SimpleEntry(date: currentDate, keywords: keywords))
        
        // 30분 간격으로 업데이트 (고정)
        let intervals = [30, 60, 120] // 30분, 1시간, 2시간 후
        for interval in intervals {
            let futureDate = Calendar.current.date(byAdding: .minute, value: interval, to: currentDate)!
            entries.append(SimpleEntry(date: futureDate, keywords: keywords))
        }
        
        // 1시간 후에 다시 새로고침하도록 설정 (배터리 절약)
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
    
    func getKeywordsFromUserDefaults() -> [KeywordData] {
        let userDefaults = UserDefaults(suiteName: "group.net.lamoss.trendly.widgdet")
        guard let keywordsData = userDefaults?.string(forKey: "keywords"),
              let jsonData = keywordsData.data(using: .utf8) else {
            print("⚠️ iOS Widget: No keywords data found in UserDefaults")
            return []
        }
        
        do {
            if let keywordsArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                return keywordsArray.compactMap { dict in
                    guard let id = dict["id"] as? Int,
                          let keyword = dict["keyword"] as? String,
                          let rank = dict["rank"] as? Int else {
                        return nil
                    }
                    return KeywordData(id: id, keyword: keyword, rank: rank)
                }
            }
        } catch {
            print("❌ iOS Widget: Error parsing keywords: \(error)")
        }
        
        print("⚠️ iOS Widget: Returning empty keywords array")
        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let keywords: [KeywordData]
}

struct KeywordData: Identifiable {
    let id: Int
    let keyword: String
    let rank: Int
}

struct TrendlyWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Text("🔥 실시간 트렌드")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(DateFormatter.widgetFormatter.string(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 새로고침 버튼 (iOS 17+ 지원)
                if #available(iOS 17.0, *) {
                    Button(intent: RefreshIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // iOS 16 이하는 새로고침 아이콘만 표시
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 4)
            
            // 키워드 목록 - 위젯 크기에 따라 다른 수 표시
            if entry.keywords.isEmpty {
                Spacer()
                Text("트렌드 데이터 로딩 중...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("앱에서 키워드를 업데이트해주세요")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                let keywordCount = getKeywordCountForSize(family)
                ForEach(entry.keywords.prefix(keywordCount)) { keywordData in
                    HStack {
                        Text("\(keywordData.rank)")
                            .font(getFontSizeForFamily(family))
                            .fontWeight(.bold)
                            .foregroundColor(colorForRank(keywordData.rank))
                            .frame(width: getRankWidthForFamily(family), alignment: .center)
                        
                        Text(keywordData.keyword)
                            .font(getFontSizeForFamily(family))
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                    }
                    .padding(.vertical, getPaddingForFamily(family))
                }
            }
            
            Spacer()
            
            // 푸터에 새로고침 힌트
            if entry.keywords.isEmpty {
                Text("탭하여 새로고침")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .onTapGesture {
            // iOS 위젯은 전체 탭으로 앱 열기 (iOS 16 이하에서 새로고침 역할)
            if #available(iOS 17.0, *) {
                // iOS 17에서는 버튼이 새로고침 역할
            } else {
                // iOS 16 이하는 탭하여 새로고침
                WidgetCenter.shared.reloadTimelines(ofKind: "TrendlyWidget")
            }
        }
    }
    
    func colorForRank(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.red
        case 2: return Color.orange
        case 3: return Color.yellow
        case 4: return Color.blue
        case 5: return Color.purple
        case 6: return Color.red
        case 7: return Color.orange
        case 8: return Color.yellow
        case 9: return Color.blue
        case 10: return Color.purple
        default: return Color.gray
        }
    }
    
    // 위젯 크기에 따른 키워드 수 반환
    func getKeywordCountForSize(_ family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:
            return 3
        case .systemMedium:
            return 5
        case .systemLarge, .systemExtraLarge:
            return 10
        @unknown default:
            return 5
        }
    }
    
    // 위젯 크기에 따른 폰트 크기 반환
    func getFontSizeForFamily(_ family: WidgetFamily) -> Font {
        switch family {
        case .systemSmall:
            return .caption2
        case .systemMedium:
            return .caption
        case .systemLarge, .systemExtraLarge:
            return .body
        @unknown default:
            return .caption
        }
    }
    
    // 위젯 크기에 따른 순위 영역 너비 반환
    func getRankWidthForFamily(_ family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall:
            return 15
        case .systemMedium:
            return 20
        case .systemLarge, .systemExtraLarge:
            return 25
        @unknown default:
            return 20
        }
    }
    
    // 위젯 크기에 따른 패딩 반환
    func getPaddingForFamily(_ family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall:
            return 0.5
        case .systemMedium:
            return 1
        case .systemLarge, .systemExtraLarge:
            return 2
        @unknown default:
            return 1
        }
    }
}

// iOS 위젯 새로고침을 위한 App Intent
@available(iOS 17.0, *)
struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "새로고침"
    static var description = IntentDescription("위젯 데이터를 새로고침합니다")
    
    func perform() async throws -> some IntentResult {
        // iOS에서는 위젯 타임라인을 새로고침하는 것이 주된 방법
        WidgetCenter.shared.reloadTimelines(ofKind: "TrendlyWidget")
        return .result()
    }
}

extension DateFormatter {
    static let widgetFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
}