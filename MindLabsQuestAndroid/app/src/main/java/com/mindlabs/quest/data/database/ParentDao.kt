package com.mindlabs.quest.data.database

import androidx.room.*
import com.mindlabs.quest.data.models.Parent
import com.mindlabs.quest.data.models.Reward
import kotlinx.coroutines.flow.Flow

@Dao
interface ParentDao {
    @Insert
    suspend fun insertParent(parent: Parent)
    
    @Update
    suspend fun updateParent(parent: Parent)
    
    @Query("SELECT * FROM parents WHERE email = :email LIMIT 1")
    suspend fun getParentByEmail(email: String): Parent?
    
    @Query("SELECT * FROM parents WHERE id = :id")
    suspend fun getParentById(id: String): Parent?
    
    @Query("UPDATE parents SET childIds = :childIds WHERE id = :parentId")
    suspend fun updateChildIds(parentId: String, childIds: List<String>)
}

@Dao
interface RewardDao {
    @Insert
    suspend fun insertReward(reward: Reward)
    
    @Update
    suspend fun updateReward(reward: Reward)
    
    @Delete
    suspend fun deleteReward(reward: Reward)
    
    @Query("SELECT * FROM rewards WHERE parentId = :parentId AND isActive = 1 ORDER BY xpCost ASC")
    fun getActiveRewardsByParent(parentId: String): Flow<List<Reward>>
    
    @Query("SELECT * FROM rewards WHERE id = :id")
    suspend fun getRewardById(id: String): Reward?
    
    @Query("UPDATE rewards SET isActive = 0 WHERE id = :rewardId")
    suspend fun deactivateReward(rewardId: String)
}