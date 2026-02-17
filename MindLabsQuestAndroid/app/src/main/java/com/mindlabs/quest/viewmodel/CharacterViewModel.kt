package com.mindlabs.quest.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindlabs.quest.data.models.Character
import com.mindlabs.quest.data.models.CharacterClass
import com.mindlabs.quest.data.repository.CharacterRepository
import com.mindlabs.quest.data.repository.QuestRepository
import com.mindlabs.quest.ui.screens.QuestTemplate
import com.mindlabs.quest.data.models.Quest
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class CharacterViewModel @Inject constructor(
    private val characterRepository: CharacterRepository,
    private val questRepository: QuestRepository
) : ViewModel() {
    
    private val _character = MutableStateFlow<Character?>(null)
    val character: StateFlow<Character?> = _character.asStateFlow()
    
    init {
        viewModelScope.launch {
            characterRepository.getCharacter().collect { char ->
                _character.value = char
            }
        }
    }
    
    fun createCharacter(name: String, characterClass: CharacterClass) {
        viewModelScope.launch {
            val newCharacter = Character(
                name = name,
                characterClass = characterClass
            )
            characterRepository.createCharacter(newCharacter)
            // Create initial quests when character is created
            questRepository.createInitialQuests()
        }
    }
    
    fun createCharacterWithQuests(
        name: String, 
        characterClass: CharacterClass,
        selectedQuests: Set<QuestTemplate>
    ) {
        viewModelScope.launch {
            val newCharacter = Character(
                name = name,
                characterClass = characterClass
            )
            characterRepository.createCharacter(newCharacter)
            
            // Create selected quests
            val today = System.currentTimeMillis()
            selectedQuests.forEach { questTemplate ->
                val quest = Quest(
                    title = questTemplate.title,
                    description = questTemplate.description,
                    category = questTemplate.category,
                    difficulty = questTemplate.difficulty,
                    estimatedMinutes = questTemplate.estimatedMinutes,
                    xpReward = questTemplate.xpReward,
                    dueDate = if (questTemplate.isDaily) today else null
                )
                questRepository.createQuest(quest)
            }
        }
    }
    
    fun addXP(amount: Int) {
        viewModelScope.launch {
            characterRepository.addXP(amount)
        }
    }
    
    fun updateStreak(newStreak: Int) {
        viewModelScope.launch {
            characterRepository.updateStreak(newStreak)
        }
    }
    
    fun completeQuest(xpReward: Int) {
        viewModelScope.launch {
            characterRepository.completeQuest(xpReward)
        }
    }
    
    fun addFocusMinutes(minutes: Int) {
        viewModelScope.launch {
            characterRepository.updateFocusTime(minutes)
        }
    }
}