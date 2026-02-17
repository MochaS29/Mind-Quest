package com.mindlabs.quest.data.database

import androidx.room.*
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.models.QuestCategory
import kotlinx.coroutines.flow.Flow

@Dao
interface QuestDao {
    @Query("SELECT * FROM quests ORDER BY createdDate DESC")
    fun getAllQuests(): Flow<List<Quest>>

    @Query("SELECT * FROM quests WHERE isCompleted = 0 ORDER BY CASE WHEN dueDate IS NULL THEN 1 ELSE 0 END, dueDate ASC, createdDate DESC")
    fun getActiveQuests(): Flow<List<Quest>>

    @Query("SELECT * FROM quests WHERE isCompleted = 1 ORDER BY completedDate DESC")
    fun getCompletedQuests(): Flow<List<Quest>>

    @Query("SELECT * FROM quests WHERE category = :category ORDER BY createdDate DESC")
    fun getQuestsByCategory(category: QuestCategory): Flow<List<Quest>>

    @Query("SELECT * FROM quests WHERE id = :id")
    suspend fun getQuestById(id: String): Quest?

    @Insert
    suspend fun insertQuest(quest: Quest)

    @Update
    suspend fun updateQuest(quest: Quest)

    @Delete
    suspend fun deleteQuest(quest: Quest)

    @Query("UPDATE quests SET isCompleted = 1, completedDate = :completedDate, actualMinutes = :actualMinutes WHERE id = :id")
    suspend fun completeQuest(id: String, completedDate: Long, actualMinutes: Int?)

    @Query("SELECT * FROM quests WHERE dueDate BETWEEN :startDate AND :endDate")
    fun getQuestsBetweenDates(startDate: Long, endDate: Long): Flow<List<Quest>>
    
    @Query("SELECT COUNT(*) FROM quests WHERE dueDate BETWEEN :startDate AND :endDate")
    suspend fun getQuestsCountBetweenDates(startDate: Long, endDate: Long): Int

    @Query("SELECT COUNT(*) FROM quests WHERE isCompleted = 1 AND completedDate >= :startDate")
    suspend fun getCompletedQuestsCountSince(startDate: Long): Int

    @Query("SELECT SUM(actualMinutes) FROM quests WHERE isCompleted = 1 AND completedDate >= :startDate")
    suspend fun getTotalFocusMinutesSince(startDate: Long): Int?

    @Query("DELETE FROM quests")
    suspend fun deleteAll()
}