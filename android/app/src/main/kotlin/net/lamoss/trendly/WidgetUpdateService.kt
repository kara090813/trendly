package net.lamoss.trendly

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONArray
import org.json.JSONObject
import java.io.InputStreamReader
import java.io.BufferedReader
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager
import java.security.cert.X509Certificate

class WidgetUpdateReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_UPDATE_WIDGET = "com.trendly.UPDATE_WIDGET"
        private const val API_URL = "https://trendly.servehttp.com:10443/api/keyword/now/"
        
        fun scheduleUpdates(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, WidgetUpdateReceiver::class.java).apply {
                action = ACTION_UPDATE_WIDGET
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // 30분마다 업데이트 (고정)
            val intervalMillis = 30 * 60 * 1000L // 30분 고정
            
            alarmManager.setInexactRepeating(
                AlarmManager.ELAPSED_REALTIME,
                SystemClock.elapsedRealtime() + intervalMillis,
                intervalMillis,
                pendingIntent
            )
            
            println("✅ Widget auto-update scheduled every 30 minutes")
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_UPDATE_WIDGET) {
            println("🔄 Widget auto-update triggered")
            updateWidgetData(context)
        }
    }
    
    fun updateWidgetData(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val keywordsData = fetchKeywordsFromAPI()
                if (keywordsData.isNotEmpty()) {
                    // SharedPreferences에 저장
                    val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)
                    val currentTime = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.getDefault()).format(java.util.Date())
                    prefs.edit().apply {
                        putString("keywords", keywordsData)
                        putString("lastUpdate", currentTime)
                        apply()
                    }
                    println("✅ Widget data saved to SharedPreferences")
                    
                    // 위젯 업데이트
                    withContext(Dispatchers.Main) {
                        val appWidgetManager = AppWidgetManager.getInstance(context)
                        val thisWidget = ComponentName(context, TrendlyWidgetProvider::class.java)
                        val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                        
                        // 각 위젯 직접 업데이트
                        for (appWidgetId in allWidgetIds) {
                            val widgetProvider = TrendlyWidgetProvider()
                            widgetProvider.updateAppWidget(context, appWidgetManager, appWidgetId)
                        }
                        
                        println("✅ Widget updated with fresh data (${allWidgetIds.size} widgets)")
                    }
                } else {
                    println("⚠️ Empty API response received")
                }
            } catch (e: Exception) {
                println("❌ Failed to update widget: ${e.message}")
                e.printStackTrace()
            }
        }
    }
    
    // 수동 새로고침을 위한 별도 메소드
    fun triggerManualRefresh(context: Context) {
        println("🔄 Manual refresh triggered")
        updateWidgetData(context)
    }
    
    private suspend fun fetchKeywordsFromAPI(): String {
        return withContext(Dispatchers.IO) {
            try {
                // SSL 인증서 우회 설정 (개발용)
                val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
                    override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
                    override fun checkClientTrusted(certs: Array<X509Certificate>, authType: String) {}
                    override fun checkServerTrusted(certs: Array<X509Certificate>, authType: String) {}
                })
                
                val sslContext = SSLContext.getInstance("SSL")
                sslContext.init(null, trustAllCerts, java.security.SecureRandom())
                HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.socketFactory)
                HttpsURLConnection.setDefaultHostnameVerifier { _, _ -> true }
                
                val url = URL(API_URL)
                val connection = url.openConnection() as HttpURLConnection
                connection.apply {
                    requestMethod = "GET"
                    setRequestProperty("Content-Type", "application/json")
                    setRequestProperty("Accept", "application/json")
                    connectTimeout = 10000
                    readTimeout = 10000
                }
                
                if (connection.responseCode == 200) {
                    val reader = BufferedReader(InputStreamReader(connection.inputStream))
                    val response = reader.readText()
                    reader.close()
                    
                    // JSON 파싱하여 상위 5개만 추출
                    val jsonArray = JSONArray(response)
                    val limitedArray = JSONArray()
                    
                    for (i in 0 until minOf(jsonArray.length(), 5)) {
                        limitedArray.put(jsonArray.getJSONObject(i))
                    }
                    
                    println("✅ Fetched ${limitedArray.length()} keywords from API")
                    return@withContext limitedArray.toString()
                } else {
                    println("❌ API call failed: ${connection.responseCode}")
                    return@withContext ""
                }
            } catch (e: Exception) {
                println("❌ Network error: ${e.message}")
                return@withContext ""
            }
        }
    }
}