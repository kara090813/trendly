package net.lamoss.trendly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class TrendlyWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val WIDGET_CLICK_ACTION = "com.trendly.WIDGET_CLICK"
        private const val REFRESH_ACTION = "com.trendly.REFRESH"
        private const val MANUAL_REFRESH_ACTION = "com.trendly.MANUAL_REFRESH"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // 자동 업데이트 스케줄링 시작
        WidgetUpdateReceiver.scheduleUpdates(context)
        
        // 각 위젯 인스턴스 업데이트
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // 위젯이 처음 활성화될 때 자동 업데이트 시작
        WidgetUpdateReceiver.scheduleUpdates(context)
        println("✅ Widget enabled and auto-update scheduled")
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            WIDGET_CLICK_ACTION -> {
                // 위젯 클릭 시 앱 열기
                val keywordId = intent.getStringExtra("keywordId")
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                
                // 키워드 ID가 있으면 딥링크로 전달
                keywordId?.let {
                    launchIntent?.putExtra("keywordId", it)
                }
                
                context.startActivity(launchIntent)
            }
            REFRESH_ACTION -> {
                // 새로고침 요청
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val thisWidget = ComponentName(context, TrendlyWidgetProvider::class.java)
                val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                onUpdate(context, appWidgetManager, allWidgetIds)
            }
            MANUAL_REFRESH_ACTION -> {
                // 수동 새로고침 버튼 클릭 - 즉시 API 호출
                println("🔄 Manual refresh button clicked")
                WidgetUpdateReceiver().updateWidgetData(context)
            }
        }
    }

    fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_trendly)
        
        // 다크 모드 감지
        val isDarkMode = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        
        // SharedPreferences에서 위젯 데이터 가져오기
        val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)
        val keywordsJson = prefs.getString("keywords", "") ?: ""
        val lastUpdate = prefs.getString("lastUpdate", "")
        
        try {
            if (keywordsJson.isNotEmpty()) {
                val keywordsArray = JSONArray(keywordsJson)
                
                if (keywordsArray.length() > 0) {
                    // 실제 API 데이터가 있는 경우
                    setupKeywordViews(context, views, keywordsArray, isDarkMode)
                } else {
                    // 빈 배열인 경우
                    setupEmptyView(views, isDarkMode)
                }
            } else {
                // 데이터가 없는 경우 (앱에서 아직 위젯을 활성화하지 않음)
                setupEmptyView(views, isDarkMode)
            }
            
            // 마지막 업데이트 시간 표시
            if (!lastUpdate.isNullOrEmpty()) {
                val updateTime = formatUpdateTime(lastUpdate)
                views.setTextViewText(R.id.last_update_text, "업데이트: $updateTime")
                views.setViewVisibility(R.id.last_update_text, android.view.View.VISIBLE)
                
                // 마지막 업데이트 시간 색상 설정
                val lastUpdateColor = if (isDarkMode) Color.parseColor("#AAAAAA") else Color.parseColor("#999999")
                views.setTextColor(R.id.last_update_text, lastUpdateColor)
            } else {
                views.setViewVisibility(R.id.last_update_text, android.view.View.GONE)
            }
            
        } catch (e: Exception) {
            setupErrorView(views, e.message ?: "데이터를 불러올 수 없습니다", isDarkMode)
        }
        
        // 위젯 제목 색상 설정
        val titleColor = if (isDarkMode) Color.WHITE else Color.parseColor("#333333")
        views.setTextColor(R.id.widget_title, titleColor)
        
        // 위젯 배경 설정
        val backgroundResource = if (isDarkMode) R.drawable.widget_background_dark else R.drawable.widget_background_light
        views.setInt(R.id.widget_container, "setBackgroundResource", backgroundResource)
        
        // 수동 새로고침 버튼 클릭 이벤트
        val manualRefreshIntent = Intent(context, TrendlyWidgetProvider::class.java).apply {
            action = MANUAL_REFRESH_ACTION
        }
        val manualRefreshPendingIntent = PendingIntent.getBroadcast(
            context, 1, manualRefreshIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.refresh_button, manualRefreshPendingIntent)
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    private fun setupKeywordViews(context: Context, views: RemoteViews, keywordsArray: JSONArray, isDarkMode: Boolean) {
        val keywordViews = listOf(
            R.id.keyword_1, R.id.keyword_2, R.id.keyword_3, R.id.keyword_4, R.id.keyword_5,
            R.id.keyword_6, R.id.keyword_7, R.id.keyword_8, R.id.keyword_9, R.id.keyword_10
        )
        val rankViews = listOf(
            R.id.rank_1, R.id.rank_2, R.id.rank_3, R.id.rank_4, R.id.rank_5,
            R.id.rank_6, R.id.rank_7, R.id.rank_8, R.id.rank_9, R.id.rank_10
        )
        
        // 테마별 색상 정의
        val keywordTextColor = if (isDarkMode) Color.WHITE else Color.parseColor("#333333")
        val rankColors = listOf(
            Color.parseColor("#FF6B6B"),  // 1위 - 빨간색
            Color.parseColor("#FF9F43"),  // 2위 - 주황색
            Color.parseColor("#FFA502"),  // 3위 - 노란색
            Color.parseColor("#70A1FF"),  // 4위 - 파란색
            Color.parseColor("#5F27CD"),  // 5위 - 보라색
            Color.parseColor("#FF6B6B"),  // 6위 - 빨간색 (반복)
            Color.parseColor("#FF9F43"),  // 7위 - 주황색 (반복)
            Color.parseColor("#FFA502"),  // 8위 - 노란색 (반복)
            Color.parseColor("#70A1FF"),  // 9위 - 파란색 (반복)
            Color.parseColor("#5F27CD")   // 10위 - 보라색 (반복)
        )
        
        // 위젯 사이즈에 따른 표시 키워드 수 결정
        val maxKeywords = minOf(keywordsArray.length(), 10) // 최대 10개
        
        for (i in 0 until maxKeywords) {
            try {
                val keywordObj = keywordsArray.getJSONObject(i)
                val keyword = keywordObj.getString("keyword")
                val rank = keywordObj.getInt("rank")
                val keywordId = keywordObj.getInt("id").toString()
                
                // 키워드 텍스트 설정
                views.setTextViewText(keywordViews[i], keyword)
                views.setTextViewText(rankViews[i], rank.toString())
                
                // 색상 적용
                views.setTextColor(keywordViews[i], keywordTextColor)
                views.setTextColor(rankViews[i], rankColors[i])
                
                // 키워드 클릭 이벤트
                val clickIntent = Intent(context, TrendlyWidgetProvider::class.java).apply {
                    action = WIDGET_CLICK_ACTION
                    putExtra("keywordId", keywordId)
                }
                val clickPendingIntent = PendingIntent.getBroadcast(
                    context, i, clickIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(keywordViews[i], clickPendingIntent)
                
                // 뷰 표시
                views.setViewVisibility(keywordViews[i], android.view.View.VISIBLE)
                views.setViewVisibility(rankViews[i], android.view.View.VISIBLE)
                
            } catch (e: Exception) {
                // 오류 발생 시 해당 항목 숨기기
                views.setViewVisibility(keywordViews[i], android.view.View.GONE)
                views.setViewVisibility(rankViews[i], android.view.View.GONE)
            }
        }
        
        // 사용하지 않는 뷰 숨기기 (10개까지 처리)
        for (i in maxKeywords until 10) {
            if (i < keywordViews.size && i < rankViews.size) {
                views.setViewVisibility(keywordViews[i], android.view.View.GONE)
                views.setViewVisibility(rankViews[i], android.view.View.GONE)
            }
        }
        
        views.setViewVisibility(R.id.empty_view, android.view.View.GONE)
        views.setViewVisibility(R.id.error_view, android.view.View.GONE)
    }
    
    private fun setupEmptyView(views: RemoteViews, isDarkMode: Boolean) {
        // 모든 키워드 뷰 숨기기 (10개까지 처리)
        val keywordViews = listOf(
            R.id.keyword_1, R.id.keyword_2, R.id.keyword_3, R.id.keyword_4, R.id.keyword_5,
            R.id.keyword_6, R.id.keyword_7, R.id.keyword_8, R.id.keyword_9, R.id.keyword_10
        )
        val rankViews = listOf(
            R.id.rank_1, R.id.rank_2, R.id.rank_3, R.id.rank_4, R.id.rank_5,
            R.id.rank_6, R.id.rank_7, R.id.rank_8, R.id.rank_9, R.id.rank_10
        )
        
        for (i in 0 until 10) {
            if (i < keywordViews.size && i < rankViews.size) {
                views.setViewVisibility(keywordViews[i], android.view.View.GONE)
                views.setViewVisibility(rankViews[i], android.view.View.GONE)
            }
        }
        
        views.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE)
        views.setViewVisibility(R.id.error_view, android.view.View.GONE)
        views.setTextViewText(R.id.empty_text, "트렌드 데이터 로딩 중...")
        
        // 빈 상태 텍스트 색상 설정
        val emptyTextColor = if (isDarkMode) Color.parseColor("#AAAAAA") else Color.parseColor("#666666")
        views.setTextColor(R.id.empty_text, emptyTextColor)
    }
    
    private fun setupErrorView(views: RemoteViews, error: String, isDarkMode: Boolean) {
        // 모든 키워드 뷰 숨기기 (10개까지 처리)
        val keywordViews = listOf(
            R.id.keyword_1, R.id.keyword_2, R.id.keyword_3, R.id.keyword_4, R.id.keyword_5,
            R.id.keyword_6, R.id.keyword_7, R.id.keyword_8, R.id.keyword_9, R.id.keyword_10
        )
        val rankViews = listOf(
            R.id.rank_1, R.id.rank_2, R.id.rank_3, R.id.rank_4, R.id.rank_5,
            R.id.rank_6, R.id.rank_7, R.id.rank_8, R.id.rank_9, R.id.rank_10
        )
        
        for (i in 0 until 10) {
            if (i < keywordViews.size && i < rankViews.size) {
                views.setViewVisibility(keywordViews[i], android.view.View.GONE)
                views.setViewVisibility(rankViews[i], android.view.View.GONE)
            }
        }
        
        views.setViewVisibility(R.id.empty_view, android.view.View.GONE)
        views.setViewVisibility(R.id.error_view, android.view.View.VISIBLE)
        views.setTextViewText(R.id.error_text, error)
        
        // 에러 텍스트 색상 설정 (어두운 테마에서도 빨간색 유지하되 약간 밝게)
        val errorTextColor = if (isDarkMode) Color.parseColor("#FF8A8A") else Color.parseColor("#FF6B6B")
        views.setTextColor(R.id.error_text, errorTextColor)
    }
    
    private fun formatUpdateTime(isoString: String): String {
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
            val outputFormat = SimpleDateFormat("MM/dd HH:mm", Locale.getDefault())
            val date = inputFormat.parse(isoString)
            date?.let { outputFormat.format(it) } ?: "방금"
        } catch (e: Exception) {
            "방금"
        }
    }
}