package com.mindlabs.quest.data.database

import androidx.room.*
import com.mindlabs.quest.data.models.Achievement
import com.mindlabs.quest.data.models.AchievementCategory
import kotlinx.coroutines.flow.Flow

@Dao
interface AchievementDao {
    @Query("SELECT * FROM achievements ORDER BY category, progress DESC")
    fun getAllAchievements(): Flow<List<Achievement>>
    
    @Query("SELECT * FROM achievements WHERE isUnlocked = 1 ORDER BY unlockedDate DESC")
    fun getUnlockedAchievements(): Flow<List<Achievement>>
    
    @Query("SELECT * FROM achievements WHERE isUnlocked = 0 AND hidden = 0 ORDER BY progress DESC")
    fun getLockedAchievements(): Flow<List<Achievement>>
    
    @Query("SELECT * FROM achievements WHERE category = :category ORDER BY progress DESC")
    fun getAchievementsByCategory(category: AchievementCategory): Flow<List<Achievement>>
    
    @Query("SELECT * FROM achievements WHERE id = :id")
    suspend fun getAchievementById(id: String): Achievement?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAchievements(achievements: List<Achievement>)
    
    @Update
    suspend fun updateAchievement(achievement: Achievement)
    
    @Query("UPDATE achievements SET progress = :progress WHERE id = :id")
    suspend fun updateProgress(id: String, progress: Int)
    
    @Query("UPDATE achievements SET isUnlocked = 1, unlockedDate = :unlockedDate WHERE id = :id")
    suspend fun unlockAchievement(id: String, unlockedDate: Long)
    
    @Query("SELECT COUNT(*) FROM achievements")
    suspend fun getTotalCount(): Int
    
    @Query("SELECT COUNT(*) FROM achievements WHERE isUnlocked = 1")
    suspend fun getUnlockedCount(): Int
    
    @Query("DELETE FROM achievements")
    suspend fun deleteAll()
}