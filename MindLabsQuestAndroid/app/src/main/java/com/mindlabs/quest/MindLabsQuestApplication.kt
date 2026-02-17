package com.mindlabs.quest

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class MindLabsQuestApplication : Application() {
    override fun onCreate() {
        super.onCreate()
    }
}