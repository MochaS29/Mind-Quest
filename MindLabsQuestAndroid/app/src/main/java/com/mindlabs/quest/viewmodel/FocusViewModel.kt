package com.mindlabs.quest.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.repository.FocusRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FocusViewModel @Inject constructor(
    private val focusRepository: FocusRepository
) : ViewModel() {
    
    private val _focusState = MutableStateFlow(FocusState())
    val focusState: StateFlow<FocusState> = _focusState.asStateFlow()
    
    private var timerJob: Job? = null
    
    fun selectQuest(quest: Quest) {
        _focusState.update { state ->
            state.copy(
                currentQuest = quest,
                totalTime = quest.estimatedMinutes * 60,
                timeRemaining = quest.estimatedMinutes * 60,
                sessionType = SessionType.FOCUS
            )
        }
    }
    
    fun setTimer(minutes: Int) {
        _focusState.update { state ->
            state.copy(
                totalTime = minutes * 60,
                timeRemaining = minutes * 60,
                progress = 0f
            )
        }
    }
    
    fun startTimer() {
        if (_focusState.value.isRunning) return
        
        _focusState.update { it.copy(isRunning = true, isPaused = false) }
        
        timerJob = viewModelScope.launch {
            while (_focusState.value.timeRemaining > 0 && _focusState.value.isRunning) {
                delay(1000) // 1 second
                _focusState.update { state ->
                    val newTimeRemaining = state.timeRemaining - 1
                    val progress = 1f - (newTimeRemaining.toFloat() / state.totalTime.toFloat())
                    
                    state.copy(
                        timeRemaining = newTimeRemaining,
                        progress = progress
                    )
                }
            }
            
            // Timer completed
            if (_focusState.value.timeRemaining == 0) {
                completeSession()
            }
        }
    }
    
    fun pauseTimer() {
        timerJob?.cancel()
        _focusState.update { it.copy(isRunning = false, isPaused = true) }
    }
    
    fun stopTimer() {
        timerJob?.cancel()
        _focusState.update { state ->
            state.copy(
                isRunning = false,
                isPaused = false,
                timeRemaining = state.totalTime,
                progress = 0f
            )
        }
    }
    
    fun startBreak(minutes: Int) {
        timerJob?.cancel()
        _focusState.update { state ->
            state.copy(
                sessionType = SessionType.BREAK,
                totalTime = minutes * 60,
                timeRemaining = minutes * 60,
                progress = 0f,
                isRunning = false,
                isPaused = false,
                currentQuest = null
            )
        }
    }
    
    private fun completeSession() {
        viewModelScope.launch {
            val state = _focusState.value
            
            if (state.sessionType == SessionType.FOCUS) {
                // Record focus session
                state.currentQuest?.let { quest ->
                    focusRepository.recordFocusSession(
                        questId = quest.id,
                        durationMinutes = state.totalTime / 60
                    )
                }
                
                // Update stats
                _focusState.update { it.copy(
                    completedSessions = it.completedSessions + 1,
                    totalFocusMinutes = it.totalFocusMinutes + (state.totalTime / 60),
                    currentStreak = it.currentStreak + 1
                ) }
                
                // Suggest break after focus session
                if (state.completedSessions % 4 == 0) {
                    startBreak(15) // Long break after 4 sessions
                } else {
                    startBreak(5) // Short break
                }
            } else {
                // Break completed, ready for next focus session
                _focusState.update { it.copy(
                    sessionType = SessionType.FOCUS,
                    isRunning = false,
                    timeRemaining = 25 * 60, // Default to Pomodoro
                    totalTime = 25 * 60,
                    progress = 0f
                ) }
            }
        }
    }
    
    override fun onCleared() {
        super.onCleared()
        timerJob?.cancel()
    }
    
    data class FocusState(
        val currentQuest: Quest? = null,
        val isRunning: Boolean = false,
        val isPaused: Boolean = false,
        val timeRemaining: Int = 25 * 60, // Default 25 minutes in seconds
        val totalTime: Int = 25 * 60,
        val progress: Float = 0f,
        val sessionType: SessionType = SessionType.FOCUS,
        val completedSessions: Int = 0,
        val totalFocusMinutes: Int = 0,
        val currentStreak: Int = 0
    )
    
    enum class SessionType {
        FOCUS, BREAK
    }
}