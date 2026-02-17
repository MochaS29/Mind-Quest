package com.mindlabs.quest.data.repository

import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.database.ParentDao
import com.mindlabs.quest.data.database.QuestDao
import com.mindlabs.quest.data.database.RewardDao
import com.mindlabs.quest.data.models.ChildProgress
import com.mindlabs.quest.data.models.Parent
import com.mindlabs.quest.data.models.Reward
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ParentRepository @Inject constructor(
    private val parentDao: ParentDao,
    private val rewardDao: RewardDao,
    private val characterDao: CharacterDao,
    private val questDao: QuestDao
) {
    
    suspend fun getCurrentParent(): Parent? {
        // In a real app, this would get the logged-in parent
        // For now, return the first parent or create a demo one
        return parentDao.getParentById("demo-parent-id") ?: createDemoParent()
    }
    
    private suspend fun createDemoParent(): Parent {
        val demoParent = Parent(
            id = "demo-parent-id",
            name = "Demo Parent",
            email = "parent@demo.com",
            hashedPassword = "demo" // In production, use proper hashing
        )
        parentDao.insertParent(demoParent)
        return demoParent
    }
    
    fun getActiveRewards(): Flow<List<Reward>> {
        return rewardDao.getActiveRewardsByParent("demo-parent-id")
    }
    
    suspend fun createReward(reward: Reward) {
        rewardDao.insertReward(reward.copy(parentId = "demo-parent-id"))
    }
    
    suspend fun updateReward(reward: Reward) {
        rewardDao.updateReward(reward)
    }
    
    suspend fun deleteReward(reward: Reward) {
        rewardDao.deleteReward(reward)
    }
    
    suspend fun getChildrenProgress(childIds: List<String>): List<ChildProgress> {
        return childIds.mapNotNull { childId ->
            val character = characterDao.getCharacterById(childId) ?: return@mapNotNull null
            
            val today = System.currentTimeMillis()
            val todayStart = today - (today % 86400000) // Start of today
            val weekStart = todayStart - (7 * 86400000) // 7 days ago
            
            val todayQuestsCompleted = questDao.getCompletedQuestsCountSince(todayStart)
            val todayTotalQuests = questDao.getQuestsCountBetweenDates(todayStart, todayStart + 86400000)
            
            val weeklyCompleted = questDao.getCompletedQuestsCountSince(weekStart)
            val todayFocusMinutes = questDao.getTotalFocusMinutesSince(todayStart) ?: 0
            val todayXp = calculateTodayXp(character, todayStart)
            
            ChildProgress(
                characterId = character.id,
                characterName = character.displayName,
                todayQuestsCompleted = todayQuestsCompleted,
                todayQuestsTotal = todayTotalQuests,
                weeklyQuestsCompleted = weeklyCompleted,
                currentStreak = character.streak,
                totalXpEarned = todayXp,
                focusMinutesToday = todayFocusMinutes,
                lastActiveTime = character.joinedDate // In a real app, track last activity
            )
        }
    }
    
    private suspend fun calculateTodayXp(character: com.mindlabs.quest.data.models.Character, todayStart: Long): Int {
        // In a real app, you would track daily XP separately
        // For now, return a demo value
        return 250
    }
    
    suspend fun linkChildByCode(parentId: String, childCode: String): Boolean {
        // In a real app, you would validate the code and link the accounts
        // For now, just return true
        return true
    }
    
    suspend fun authenticateParent(email: String, password: String): Parent? {
        val parent = parentDao.getParentByEmail(email)
        // In production, use proper password hashing and verification
        return if (parent?.hashedPassword == password) parent else null
    }
    
    suspend fun createParentAccount(name: String, email: String, password: String): Parent {
        val parent = Parent(
            name = name,
            email = email,
            hashedPassword = password // In production, hash the password
        )
        parentDao.insertParent(parent)
        return parent
    }
}