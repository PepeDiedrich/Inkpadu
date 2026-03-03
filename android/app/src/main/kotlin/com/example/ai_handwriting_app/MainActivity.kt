package com.example.ai_handwriting_app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 🛡️ Sentinel: Prevent screenshots and screen recording of sensitive data
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
