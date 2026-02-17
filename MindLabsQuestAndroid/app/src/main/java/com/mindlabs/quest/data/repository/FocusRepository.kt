package com.mindlabs.quest.data.repository

import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.database.QuestDao
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FocusRepository @Inject constructor(
    private val questDao: QuestDao,
    private val characterDao: CharacterDao
) {
    suspend fun recordFocusSession(questId: String, durationMinutes: Int) {
        // Update quest with actual time
        questDao.getQuestById(questId)?.let { quest ->
            questDao.updateQuest(
                quest.copy(actualMinutes = (quest.actualMinutes ?: 0) + durationMinutes)
            )
        }
        
        // Update character focus time
        characterDao.getCharacter().collect { character ->
            character?.let {
                characterDao.addFocusMinutes(it.id, durationMinutes)
            }
        }
    }
}