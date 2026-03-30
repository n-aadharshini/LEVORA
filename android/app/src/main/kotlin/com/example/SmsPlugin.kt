package com.example.levora   // ← must match your MainActivity package exactly

import android.telephony.SmsManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.levora/sms")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "sendSms") {
            // ✅ key is 'number' — matches Flutter side
            val number  = call.argument<String>("number")
                ?: return result.error("NO_NUMBER", "No number provided", null)
            val message = call.argument<String>("message")
                ?: return result.error("NO_MSG", "No message provided", null)
            try {
                val smsManager = SmsManager.getDefault()
                val parts = smsManager.divideMessage(message)
                smsManager.sendMultipartTextMessage(number, null, parts, null, null)
                result.success("sent")
            } catch (e: Exception) {
                result.error("SMS_FAILED", e.message, null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}