package com.mindlabs.quest.viewmodel

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.database.QuestDao
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

@HiltViewModel
class SettingsViewModel @Inject constructor(
    @ApplicationContext private val context: Context,
    private val characterDao: CharacterDao,
    private val questDao: QuestDao
) : ViewModel() {
    
    private val dataStore = context.dataStore
    
    private val _settings = MutableStateFlow(Settings())
    val settings: StateFlow<Settings> = _settings.asStateFlow()
    
    init {
        loadSettings()
    }
    
    private fun loadSettings() {
        viewModelScope.launch {
            val preferences = dataStore.data.first()
            _settings.value = Settings(
                isDarkMode = preferences[PreferencesKeys.IS_DARK_MODE] ?: false,
                animationsEnabled = preferences[PreferencesKeys.ANIMATIONS_ENABLED] ?: true,
                hapticFeedback = preferences[PreferencesKeys.HAPTIC_FEEDBACK] ?: true,
                defaultTimerMinutes = preferences[PreferencesKeys.DEFAULT_TIMER_MINUTES] ?: 25,
                breakRemindersEnabled = preferences[PreferencesKeys.BREAK_REMINDERS_ENABLED] ?: true,
                breakIntervalMinutes = preferences[PreferencesKeys.BREAK_INTERVAL_MINUTES] ?: 60,
                focusModeEnabled = preferences[PreferencesKeys.FOCUS_MODE_ENABLED] ?: false,
                cloudSyncEnabled = preferences[PreferencesKeys.CLOUD_SYNC_ENABLED] ?: false,
                analyticsEnabled = preferences[PreferencesKeys.ANALYTICS_ENABLED] ?: true,
                notificationsEnabled = preferences[PreferencesKeys.NOTIFICATIONS_ENABLED] ?: true,
                soundEnabled = preferences[PreferencesKeys.SOUND_ENABLED] ?: true
            )
        }
    }
    
    fun toggleDarkMode() {
        viewModelScope.launch {
            val newValue = !_settings.value.isDarkMode
            _settings.value = _settings.value.copy(isDarkMode = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.IS_DARK_MODE] = newValue
            }
        }
    }
    
    fun toggleAnimations() {
        viewModelScope.launch {
            val newValue = !_settings.value.animationsEnabled
            _settings.value = _settings.value.copy(animationsEnabled = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.ANIMATIONS_ENABLED] = newValue
            }
        }
    }
    
    fun toggleHapticFeedback() {
        viewModelScope.launch {
            val newValue = !_settings.value.hapticFeedback
            _settings.value = _settings.value.copy(hapticFeedback = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.HAPTIC_FEEDBACK] = newValue
            }
        }
    }
    
    fun toggleBreakReminders() {
        viewModelScope.launch {
            val newValue = !_settings.value.breakRemindersEnabled
            _settings.value = _settings.value.copy(breakRemindersEnabled = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.BREAK_REMINDERS_ENABLED] = newValue
            }
        }
    }
    
    fun toggleFocusMode() {
        viewModelScope.launch {
            val newValue = !_settings.value.focusModeEnabled
            _settings.value = _settings.value.copy(focusModeEnabled = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.FOCUS_MODE_ENABLED] = newValue
            }
        }
    }
    
    fun toggleCloudSync() {
        viewModelScope.launch {
            val newValue = !_settings.value.cloudSyncEnabled
            _settings.value = _settings.value.copy(cloudSyncEnabled = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.CLOUD_SYNC_ENABLED] = newValue
            }
        }
    }
    
    fun toggleAnalytics() {
        viewModelScope.launch {
            val newValue = !_settings.value.analyticsEnabled
            _settings.value = _settings.value.copy(analyticsEnabled = newValue)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.ANALYTICS_ENABLED] = newValue
            }
        }
    }
    
    fun updateDefaultTimerMinutes(minutes: Int) {
        viewModelScope.launch {
            _settings.value = _settings.value.copy(defaultTimerMinutes = minutes)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.DEFAULT_TIMER_MINUTES] = minutes
            }
        }
    }
    
    fun updateBreakIntervalMinutes(minutes: Int) {
        viewModelScope.launch {
            _settings.value = _settings.value.copy(breakIntervalMinutes = minutes)
            dataStore.edit { preferences ->
                preferences[PreferencesKeys.BREAK_INTERVAL_MINUTES] = minutes
            }
        }
    }
    
    suspend fun resetAllData() {
        // Clear all data
        characterDao.deleteAll()
        questDao.deleteAll()
        
        // Clear preferences
        dataStore.edit { preferences ->
            preferences.clear()
        }
        
        // Reset settings to defaults
        _settings.value = Settings()
    }
    
    data class Settings(
        val isDarkMode: Boolean = false,
        val animationsEnabled: Boolean = true,
        val hapticFeedback: Boolean = true,
        val defaultTimerMinutes: Int = 25,
        val breakRemindersEnabled: Boolean = true,
        val breakIntervalMinutes: Int = 60,
        val focusModeEnabled: Boolean = false,
        val cloudSyncEnabled: Boolean = false,
        val analyticsEnabled: Boolean = true,
        val notificationsEnabled: Boolean = true,
        val soundEnabled: Boolean = true
    )
    
    private object PreferencesKeys {
        val IS_DARK_MODE = booleanPreferencesKey("is_dark_mode")
        val ANIMATIONS_ENABLED = booleanPreferencesKey("animations_enabled")
        val HAPTIC_FEEDBACK = booleanPreferencesKey("haptic_feedback")
        val DEFAULT_TIMER_MINUTES = intPreferencesKey("default_timer_minutes")
        val BREAK_REMINDERS_ENABLED = booleanPreferencesKey("break_reminders_enabled")
        val BREAK_INTERVAL_MINUTES = intPreferencesKey("break_interval_minutes")
        val FOCUS_MODE_ENABLED = booleanPreferencesKey("focus_mode_enabled")
        val CLOUD_SYNC_ENABLED = booleanPreferencesKey("cloud_sync_enabled")
        val ANALYTICS_ENABLED = booleanPreferencesKey("analytics_enabled")
        val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")
        val SOUND_ENABLED = booleanPreferencesKey("sound_enabled")
    }
}