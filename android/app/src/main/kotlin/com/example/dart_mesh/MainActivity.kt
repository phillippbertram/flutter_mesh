package com.example.flutter_mesh

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.security.Security

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Security.insertProviderAt(org.spongycastle.jce.provider.BouncyCastleProvider(), 1);
    }
}

