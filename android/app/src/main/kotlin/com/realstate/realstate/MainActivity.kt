package com.realstate.realstate

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val UPI_CHANNEL = "com.upi.channel"
    private var pendingResult: MethodChannel.Result? = null
    private var selectedPackage: String? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UPI_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "startUpi") {
                val upiUrl = call.argument<String>("url")!!
                selectedPackage = call.argument<String>("package")

                startUpiIntent(upiUrl, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startUpiIntent(url: String, result: MethodChannel.Result) {
        pendingResult = result

        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))

            if (!selectedPackage.isNullOrEmpty()) {
                intent.setPackage(selectedPackage)
            }

            startActivityForResult(intent, 1444)

        } catch (e: ActivityNotFoundException) {

            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivityForResult(intent, 1444)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 1444) {

            var response = ""

            // ALL UPI apps support this
            if (data?.getStringExtra("response") != null) {
                response = data.getStringExtra("response")!!
            }

            // Some apps send dataString
            if (response.isEmpty() && data?.dataString != null) {
                response = data.dataString!!
            }

            if (response.isEmpty()) response = "UNKNOWN"

            // Parse into single string result
            val finalString = parseUpiResponse(response)

            pendingResult?.success(finalString)
            pendingResult = null
        }
    }

    // ---------------------------------------------------
    // 🔥 FINAL PARSER (WORKS FOR GPAY / PAYTM / PHONEPE)
    // ---------------------------------------------------
    private fun parseUpiResponse(response: String): String {

        val map = HashMap<String, String>()
        val lower = response.lowercase()

        // break key=value pairs
        try {
            val parts = response.split("&")
            for (p in parts) {
                val kv = p.split("=")
                if (kv.size == 2) {
                    map[kv[0].lowercase()] = kv[1]
                }
            }
        } catch (_: Exception) { }

        val statusRaw = map["status"]?.lowercase() ?: ""

        // extract IDs
        val txnId = map["txnId"] ?: map["txn_id"] ?: ""
        val approval = map["approvalrefno"] ?: ""
        val responseCode = map["responsecode"] ?: ""

        val finalStatus = when {
            statusRaw.contains("success") -> "SUCCESS"
            responseCode == "0" -> "SUCCESS"           // Paytm
            approval.isNotEmpty() -> "SUCCESS"         // PhonePe, Paytm
            statusRaw.contains("failure") -> "FAILED"
            statusRaw.contains("fail") -> "FAILED"
            statusRaw.contains("cancel") -> "CANCELLED"
            lower == "success" -> "SUCCESS"            // GPay short response
            else -> "UNKNOWN"
        }

        // Return SINGLE STRING (no JSON)
        return "status=$finalStatus|txnId=$txnId|approvalRef=$approval|raw=$response"
    }
}
