package com.example.ai_handwriting_app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 🛡️ Sentinel: Verhindert Screenshots und Screen-Recording von sensiblen Notizen.
        // Dies ist eine "Defense in Depth" Maßnahme für den Fall, dass das Gerät kompromittiert ist.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
