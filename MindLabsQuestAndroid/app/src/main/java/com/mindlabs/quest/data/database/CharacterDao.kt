package com.mindlabs.quest.data.database

import androidx.room.*
import com.mindlabs.quest.data.models.Character
import kotlinx.coroutines.flow.Flow

@Dao
interface CharacterDao {
    @Query("SELECT * FROM characters LIMIT 1")
    fun getCharacter(): Flow<Character?>
    
    @Query("SELECT * FROM characters WHERE id = :id")
    suspend fun getCharacterById(id: String): Character?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCharacter(character: Character)

    @Update
    suspend fun updateCharacter(character: Character)

    @Query("UPDATE characters SET xp = :xp, level = :level WHERE id = :id")
    suspend fun updateXpAndLevel(id: String, xp: Int, level: Int)

    @Query("UPDATE characters SET streak = :streak, longestStreak = CASE WHEN :streak > longestStreak THEN :streak ELSE longestStreak END WHERE id = :id")
    suspend fun updateStreak(id: String, streak: Int)

    @Query("UPDATE characters SET totalQuestsCompleted = totalQuestsCompleted + 1 WHERE id = :id")
    suspend fun incrementQuestsCompleted(id: String)

    @Query("UPDATE characters SET totalFocusMinutes = totalFocusMinutes + :minutes WHERE id = :id")
    suspend fun addFocusMinutes(id: String, minutes: Int)

    @Query("DELETE FROM characters")
    suspend fun deleteAll()
}