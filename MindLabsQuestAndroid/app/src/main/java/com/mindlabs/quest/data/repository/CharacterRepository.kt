package com.mindlabs.quest.data.repository

import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.models.Character
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CharacterRepository @Inject constructor(
    private val characterDao: CharacterDao
) {
    fun getCharacter(): Flow<Character?> = characterDao.getCharacter()
    
    suspend fun createCharacter(character: Character) {
        characterDao.insertCharacter(character)
    }
    
    suspend fun updateCharacter(character: Character) {
        characterDao.updateCharacter(character)
    }
    
    suspend fun addXP(xp: Int) {
        val character = getCharacter().first()
        character?.let { char ->
            char.addXP(xp)
            characterDao.updateXpAndLevel(char.id, char.xp, char.level)
        }
    }
    
    suspend fun completeQuest(xpReward: Int): Pair<Int, Int>? {
        val character = getCharacter().first()
        return character?.let { char ->
            val levelBefore = char.level
            // Add XP and potentially level up
            char.addXP(xpReward)
            val levelAfter = char.level
            
            // Update database
            characterDao.updateXpAndLevel(char.id, char.xp, char.level)
            // Increment quests completed
            characterDao.incrementQuestsCompleted(char.id)
            
            // Return level before and after
            Pair(levelBefore, levelAfter)
        }
    }
    
    suspend fun updateStreak(newStreak: Int) {
        val character = getCharacter().first()
        character?.let { char ->
            characterDao.updateStreak(char.id, newStreak)
        }
    }
    
    suspend fun updateFocusTime(minutes: Int) {
        val character = getCharacter().first()
        character?.let { char ->
            characterDao.addFocusMinutes(char.id, minutes)
        }
    }
    
    suspend fun deleteAllCharacters() {
        characterDao.deleteAll()
    }
}