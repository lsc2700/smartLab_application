package com.gosca.smartlab_application

import android.content.Context
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun attachBaseContext(newBase: Context) {
        val configuration = Configuration(newBase.resources.configuration)
        configuration.fontScale = 1.0f
        super.attachBaseContext(newBase.createConfigurationContext(configuration))
    }
}
