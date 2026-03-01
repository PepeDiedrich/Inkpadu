package com.example.ai_handwriting_app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 🛡️ Sentinel: Füge FLAG_SECURE für Screens mit sensiblen Daten hinzu
        // Verhindert Screenshots und Screen-Recording in der Android App
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
