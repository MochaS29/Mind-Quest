package com.mindlabs.quest.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.models.QuestCategory
import com.mindlabs.quest.data.repository.CharacterRepository
import com.mindlabs.quest.data.repository.QuestRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class QuestViewModel @Inject constructor(
    private val questRepository: QuestRepository,
    private val characterRepository: CharacterRepository
) : ViewModel() {
    
    val allQuests = questRepository.getAllQuests()
    val activeQuests = questRepository.getActiveQuests()
    val completedQuests = questRepository.getCompletedQuests()
    
    private val _selectedCategory = MutableStateFlow<QuestCategory?>(null)
    val selectedCategory: StateFlow<QuestCategory?> = _selectedCategory.asStateFlow()
    
    // Celebration events
    private val _questCompletedEvent = MutableSharedFlow<QuestCompletionEvent>()
    val questCompletedEvent: SharedFlow<QuestCompletionEvent> = _questCompletedEvent.asSharedFlow()
    
    private val _levelUpEvent = MutableSharedFlow<LevelUpEvent>()
    val levelUpEvent: SharedFlow<LevelUpEvent> = _levelUpEvent.asSharedFlow()
    
    fun createQuest(quest: Quest) {
        viewModelScope.launch {
            questRepository.createQuest(quest)
        }
    }
    
    fun updateQuest(quest: Quest) {
        viewModelScope.launch {
            questRepository.updateQuest(quest)
        }
    }
    
    fun deleteQuest(quest: Quest) {
        viewModelScope.launch {
            questRepository.deleteQuest(quest)
        }
    }
    
    fun completeQuest(quest: Quest, actualMinutes: Int? = null) {
        viewModelScope.launch {
            questRepository.completeQuest(quest, actualMinutes)
            
            // Update character stats and get level change
            val levelChange = characterRepository.completeQuest(quest.xpReward)
            actualMinutes?.let {
                characterRepository.updateFocusTime(it)
            }
            
            // Get updated character
            val character = characterRepository.getCharacter().first()
            
            // Emit quest completion event
            _questCompletedEvent.emit(
                QuestCompletionEvent(
                    questTitle = quest.title,
                    xpEarned = quest.xpReward,
                    totalXp = character?.xp ?: 0
                )
            )
            
            // Check for level up
            levelChange?.let { (levelBefore, levelAfter) ->
                if (levelAfter > levelBefore) {
                    _levelUpEvent.emit(
                        LevelUpEvent(
                            newLevel = levelAfter,
                            newTitle = character?.cleverTitle ?: "",
                            characterName = character?.name ?: ""
                        )
                    )
                }
            }
        }
    }
    
    fun setSelectedCategory(category: QuestCategory?) {
        _selectedCategory.value = category
    }
    
    fun getQuestsByCategory(category: QuestCategory) = questRepository.getQuestsByCategory(category)
    
    suspend fun getQuestById(id: String): Quest? = questRepository.getQuestById(id)
}

// Event data classes
data class QuestCompletionEvent(
    val questTitle: String,
    val xpEarned: Int,
    val totalXp: Int
)

data class LevelUpEvent(
    val newLevel: Int,
    val newTitle: String,
    val characterName: String
)