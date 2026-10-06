package com.paattufy.music

import android.webkit.CookieManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi

/**
 * audio_service requires the activity to share its cached FlutterEngine. All
 * Paattufy channels live in the `paattufy_native` plugin so background engines
 * get them too; only the WebView download hook needs the engine itself, so it
 * is registered here.
 */
class MainActivity : AudioServiceActivity() {
    private var hook: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "paattufy/download_hook")
        channel.setMethodCallHandler { call, result -> onHookCall(flutterEngine, channel, call, result) }
        hook = channel
    }

    /**
     * Browse-mode download interception (AP §3.8, TP §5.9.1): attaches the
     * Android WebView's DownloadListener, which fires whenever a tapped link
     * resolves to a downloadable file rather than an HTML page. The event is
     * sent to Dart with the cookies/user-agent the download needs.
     */
    @Suppress("DEPRECATION")
    private fun onHookCall(engine: FlutterEngine, channel: MethodChannel, call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "attach") {
            result.notImplemented()
            return
        }
        val id = (call.argument<Number>("webViewIdentifier"))?.toLong()
        val webView = id?.let { WebViewFlutterAndroidExternalApi.getWebView(engine, it) }
        if (webView == null) {
            result.success(false)
            return
        }
        webView.setDownloadListener { url, userAgent, contentDisposition, mimeType, contentLength ->
            channel.invokeMethod(
                "download",
                mapOf(
                    "url" to url,
                    "userAgent" to userAgent,
                    "contentDisposition" to contentDisposition,
                    "mimeType" to mimeType,
                    "contentLength" to contentLength,
                    "cookies" to CookieManager.getInstance().getCookie(url),
                    "referer" to webView.url,
                ),
            )
        }
        result.success(true)
    }
}
