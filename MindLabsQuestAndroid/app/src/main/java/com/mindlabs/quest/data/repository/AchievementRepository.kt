package com.mindlabs.quest.data.repository

import com.mindlabs.quest.data.database.AchievementDao
import com.mindlabs.quest.data.models.Achievement
import com.mindlabs.quest.data.models.AchievementCategory
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AchievementRepository @Inject constructor(
    private val achievementDao: AchievementDao
) {
    fun getAllAchievements(): Flow<List<Achievement>> = achievementDao.getAllAchievements()
    
    fun getUnlockedAchievements(): Flow<List<Achievement>> = achievementDao.getUnlockedAchievements()
    
    suspend fun initializeAchievements() {
        val count = achievementDao.getTotalCount()
        if (count == 0) {
            achievementDao.insertAchievements(getDefaultAchievements())
        }
    }
    
    suspend fun checkAndUnlockAchievements(
        questsCompleted: Int,
        focusMinutes: Int,
        currentStreak: Int,
        level: Int,
        friendCount: Int
    ) {
        val achievements = achievementDao.getAllAchievements()
        
        achievements.collect { list ->
            list.forEach { achievement ->
                if (!achievement.isUnlocked) {
                    val progress = when (achievement.id) {
                        // Quest achievements
                        "first_quest" -> questsCompleted
                        "quest_10" -> questsCompleted
                        "quest_50" -> questsCompleted
                        "quest_100" -> questsCompleted
                        
                        // Focus achievements
                        "focus_30" -> focusMinutes
                        "focus_60" -> focusMinutes
                        "focus_300" -> focusMinutes
                        "focus_1000" -> focusMinutes
                        
                        // Streak achievements
                        "streak_3" -> currentStreak
                        "streak_7" -> currentStreak
                        "streak_30" -> currentStreak
                        "streak_100" -> currentStreak
                        
                        // Level achievements
                        "level_5" -> level
                        "level_10" -> level
                        "level_25" -> level
                        "level_50" -> level
                        
                        // Social achievements
                        "first_friend" -> friendCount
                        "social_5" -> friendCount
                        "social_20" -> friendCount
                        
                        else -> 0
                    }
                    
                    if (progress != achievement.progress) {
                        achievementDao.updateProgress(achievement.id, progress)
                    }
                    
                    if (progress >= achievement.requiredValue) {
                        achievementDao.unlockAchievement(achievement.id, System.currentTimeMillis())
                    }
                }
            }
        }
    }
    
    private fun getDefaultAchievements(): List<Achievement> = listOf(
        // Quest Achievements
        Achievement(
            id = "first_quest",
            title = "First Steps",
            description = "Complete your first quest",
            icon = "🎯",
            category = AchievementCategory.QUEST,
            requiredValue = 1
        ),
        Achievement(
            id = "quest_10",
            title = "Quest Apprentice",
            description = "Complete 10 quests",
            icon = "⚔️",
            category = AchievementCategory.QUEST,
            requiredValue = 10
        ),
        Achievement(
            id = "quest_50",
            title = "Quest Master",
            description = "Complete 50 quests",
            icon = "🗡️",
            category = AchievementCategory.QUEST,
            requiredValue = 50
        ),
        Achievement(
            id = "quest_100",
            title = "Quest Legend",
            description = "Complete 100 quests",
            icon = "🏆",
            category = AchievementCategory.QUEST,
            requiredValue = 100
        ),
        
        // Focus Achievements
        Achievement(
            id = "focus_30",
            title = "Focus Initiate",
            description = "Focus for 30 minutes total",
            icon = "🧘",
            category = AchievementCategory.FOCUS,
            requiredValue = 30
        ),
        Achievement(
            id = "focus_60",
            title = "Deep Thinker",
            description = "Focus for 1 hour total",
            icon = "🧠",
            category = AchievementCategory.FOCUS,
            requiredValue = 60
        ),
        Achievement(
            id = "focus_300",
            title = "Concentration Master",
            description = "Focus for 5 hours total",
            icon = "🎯",
            category = AchievementCategory.FOCUS,
            requiredValue = 300
        ),
        Achievement(
            id = "focus_1000",
            title = "Zen Master",
            description = "Focus for 1000 minutes total",
            icon = "🧘‍♂️",
            category = AchievementCategory.FOCUS,
            requiredValue = 1000
        ),
        
        // Streak Achievements
        Achievement(
            id = "streak_3",
            title = "Getting Started",
            description = "Maintain a 3-day streak",
            icon = "🔥",
            category = AchievementCategory.STREAK,
            requiredValue = 3
        ),
        Achievement(
            id = "streak_7",
            title = "Week Warrior",
            description = "Maintain a 7-day streak",
            icon = "🔥",
            category = AchievementCategory.STREAK,
            requiredValue = 7
        ),
        Achievement(
            id = "streak_30",
            title = "Consistency Champion",
            description = "Maintain a 30-day streak",
            icon = "🔥",
            category = AchievementCategory.STREAK,
            requiredValue = 30
        ),
        Achievement(
            id = "streak_100",
            title = "Streak Legend",
            description = "Maintain a 100-day streak",
            icon = "🔥",
            category = AchievementCategory.STREAK,
            requiredValue = 100
        ),
        
        // Level Achievements
        Achievement(
            id = "level_5",
            title = "Rising Hero",
            description = "Reach level 5",
            icon = "⭐",
            category = AchievementCategory.LEVEL,
            requiredValue = 5
        ),
        Achievement(
            id = "level_10",
            title = "Seasoned Adventurer",
            description = "Reach level 10",
            icon = "🌟",
            category = AchievementCategory.LEVEL,
            requiredValue = 10
        ),
        Achievement(
            id = "level_25",
            title = "Elite Champion",
            description = "Reach level 25",
            icon = "💫",
            category = AchievementCategory.LEVEL,
            requiredValue = 25
        ),
        Achievement(
            id = "level_50",
            title = "Legendary Hero",
            description = "Reach level 50",
            icon = "🌠",
            category = AchievementCategory.LEVEL,
            requiredValue = 50
        ),
        
        // Social Achievements
        Achievement(
            id = "first_friend",
            title = "Social Butterfly",
            description = "Add your first friend",
            icon = "🤝",
            category = AchievementCategory.SOCIAL,
            requiredValue = 1
        ),
        Achievement(
            id = "social_5",
            title = "Party Leader",
            description = "Add 5 friends",
            icon = "👥",
            category = AchievementCategory.SOCIAL,
            requiredValue = 5
        ),
        Achievement(
            id = "social_20",
            title = "Community Builder",
            description = "Add 20 friends",
            icon = "🌐",
            category = AchievementCategory.SOCIAL,
            requiredValue = 20
        )
    )
}