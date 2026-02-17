package com.mindlabs.quest.data.repository

import com.mindlabs.quest.data.database.QuestDao
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.models.QuestCategory
import com.mindlabs.quest.data.models.Difficulty
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class QuestRepository @Inject constructor(
    private val questDao: QuestDao
) {
    fun getAllQuests(): Flow<List<Quest>> = questDao.getAllQuests()
    
    fun getActiveQuests(): Flow<List<Quest>> = questDao.getActiveQuests()
    
    fun getCompletedQuests(): Flow<List<Quest>> = questDao.getCompletedQuests()
    
    fun getQuestsByCategory(category: QuestCategory): Flow<List<Quest>> = 
        questDao.getQuestsByCategory(category)
    
    suspend fun getQuestById(id: String): Quest? = questDao.getQuestById(id)
    
    suspend fun createQuest(quest: Quest) {
        questDao.insertQuest(quest)
    }
    
    suspend fun updateQuest(quest: Quest) {
        questDao.updateQuest(quest)
    }
    
    suspend fun deleteQuest(quest: Quest) {
        questDao.deleteQuest(quest)
    }
    
    suspend fun completeQuest(quest: Quest, actualMinutes: Int? = null) {
        questDao.completeQuest(
            id = quest.id,
            completedDate = System.currentTimeMillis(),
            actualMinutes = actualMinutes
        )
    }
    
    suspend fun getQuestsBetweenDates(startDate: Long, endDate: Long): Flow<List<Quest>> =
        questDao.getQuestsBetweenDates(startDate, endDate)
    
    suspend fun getCompletedQuestsCountSince(startDate: Long): Int =
        questDao.getCompletedQuestsCountSince(startDate)
    
    suspend fun getTotalFocusMinutesSince(startDate: Long): Int =
        questDao.getTotalFocusMinutesSince(startDate) ?: 0
    
    suspend fun deleteAllQuests() {
        questDao.deleteAll()
    }
    
    suspend fun createInitialQuests() {
        val today = System.currentTimeMillis()
        val tomorrow = today + 86400000 // 24 hours in milliseconds
        
        val initialQuests = listOf(
            // Morning Hygiene & Preparation
            Quest(
                title = "The Cleansing Ritual of Dawn",
                description = "Morning Shower - Start your day with refreshing cleanliness",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 10,
                xpReward = 50,
                dueDate = today
            ),
            Quest(
                title = "Defend the Ivory Gates",
                description = "Brush Teeth (Morning) - Protect your smile from cavity invaders",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 3,
                xpReward = 30,
                dueDate = today
            ),
            Quest(
                title = "Thread the Needle of Dental Excellence",
                description = "Floss Teeth - Master the art of deep dental defense",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 2,
                xpReward = 25,
                dueDate = today
            ),
            Quest(
                title = "Tame the Wild Mane",
                description = "Brush/Style Hair - Transform chaos into order atop your crown",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 5,
                xpReward = 30,
                dueDate = today
            ),
            Quest(
                title = "The Nighttime Dental Defense",
                description = "Brush Teeth (Night) - End the day with protective oral magic",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 3,
                xpReward = 30,
                dueDate = today
            ),
            
            // School Preparation
            Quest(
                title = "Prepare the Adventurer's Feast",
                description = "Pack Lunch - Gather sustenance for your daily quest",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 10,
                xpReward = 40,
                dueDate = tomorrow
            ),
            Quest(
                title = "Secure the Sacred Scrolls",
                description = "Pack Homework - Ensure all completed quests are ready for submission",
                category = QuestCategory.WORK,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 5,
                xpReward = 35,
                dueDate = tomorrow
            ),
            Quest(
                title = "Ready the Explorer's Arsenal",
                description = "Pack Backpack - Prepare your inventory for the day's adventures",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 5,
                xpReward = 35,
                dueDate = tomorrow
            ),
            
            // Academic Quests
            Quest(
                title = "Conquer the Academic Challenges",
                description = "Complete Homework - Face your assigned trials with courage",
                category = QuestCategory.WORK,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 45,
                xpReward = 150,
                dueDate = today
            ),
            Quest(
                title = "Delve into the Tomes of Knowledge",
                description = "Study Session - Absorb wisdom from ancient texts",
                category = QuestCategory.WORK,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 30,
                xpReward = 120,
                dueDate = today
            ),
            Quest(
                title = "Journey Through Literary Realms",
                description = "Read for 20 Minutes - Explore new worlds through written word",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 20,
                xpReward = 80,
                dueDate = today
            ),
            Quest(
                title = "Forge Knowledge in the Crucible of Study",
                description = "Study for Test/Quiz - Prepare for upcoming knowledge trials",
                category = QuestCategory.WORK,
                difficulty = Difficulty.HARD,
                estimatedMinutes = 60,
                xpReward = 200,
                dueDate = tomorrow
            ),
            Quest(
                title = "Face the Trial of Knowledge",
                description = "Complete Quiz/Test - Demonstrate your accumulated wisdom",
                category = QuestCategory.WORK,
                difficulty = Difficulty.HARD,
                estimatedMinutes = 60,
                xpReward = 250,
                dueDate = null
            ),
            Quest(
                title = "Decipher the Ancient Scrolls",
                description = "Review Class Notes - Study the wisdom recorded in your chronicles",
                category = QuestCategory.WORK,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 15,
                xpReward = 60,
                dueDate = today
            ),
            
            // Physical Activity
            Quest(
                title = "Train at the Dawn Dojo",
                description = "Morning Exercise - Strengthen your warrior's body",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 20,
                xpReward = 100,
                dueDate = tomorrow
            ),
            Quest(
                title = "Master the Art of Flexibility",
                description = "Stretching Routine - Enhance your agility and grace",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 10,
                xpReward = 50,
                dueDate = today
            ),
            Quest(
                title = "Venture into the Wild",
                description = "30 Min Outdoor Activity - Explore the realm beyond your walls",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 30,
                xpReward = 120,
                dueDate = today
            ),
            Quest(
                title = "Dance with the Energy Dragons",
                description = "5-Minute Movement Break - Release restless energy through motion",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 5,
                xpReward = 30,
                dueDate = today
            ),
            
            // Life Skills & Chores
            Quest(
                title = "Restore Order to Your Sanctuary",
                description = "Tidy Room - Transform chaos into a peaceful haven",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 20,
                xpReward = 80,
                dueDate = today
            ),
            Quest(
                title = "Craft the Perfect Resting Chamber",
                description = "Make Bed - Create an inviting sanctuary for future rest",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 5,
                xpReward = 30,
                dueDate = today
            ),
            Quest(
                title = "Master Your Command Center",
                description = "Organize Desk/Workspace - Create order in your productivity realm",
                category = QuestCategory.WORK,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 15,
                xpReward = 70,
                dueDate = today
            ),
            
            // Evening Routines
            Quest(
                title = "Plan Tomorrow's Campaign",
                description = "Prepare for Tomorrow - Map out your future adventures",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 10,
                xpReward = 50,
                dueDate = today
            ),
            Quest(
                title = "Meditate on Today's Adventures",
                description = "Evening Reflection/Journal - Record your daily victories and lessons",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 10,
                xpReward = 60,
                dueDate = today
            ),
            
            // Social & Creative
            Quest(
                title = "Aid Your Fellow Adventurers",
                description = "Help Family Member - Strengthen bonds through acts of service",
                category = QuestCategory.SOCIAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 15,
                xpReward = 70,
                dueDate = today
            ),
            Quest(
                title = "Channel Your Creative Energy",
                description = "Creative Activity (Draw/Music/Write) - Express your inner artist",
                category = QuestCategory.CREATIVE,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 30,
                xpReward = 100,
                dueDate = tomorrow
            ),
            Quest(
                title = "Hone Your Chosen Craft",
                description = "Practice Instrument/Skill - Level up your special abilities",
                category = QuestCategory.CREATIVE,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 30,
                xpReward = 120,
                dueDate = tomorrow
            ),
            Quest(
                title = "Venture Into the Unknown",
                description = "Try a New Activity - Expand your realm of experience",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 30,
                xpReward = 150,
                dueDate = null
            ),
            Quest(
                title = "Gather with the Alliance",
                description = "Attend Club/Group Meeting - Join your fellow adventurers",
                category = QuestCategory.SOCIAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 60,
                xpReward = 100,
                dueDate = null
            ),
            Quest(
                title = "Forge New Alliances",
                description = "Talk to Someone New - Expand your network of allies",
                category = QuestCategory.SOCIAL,
                difficulty = Difficulty.HARD,
                estimatedMinutes = 10,
                xpReward = 100,
                dueDate = today
            ),
            
            // Focus & Organization
            Quest(
                title = "Chart the Path of Destiny",
                description = "Update Planner/Calendar - Map your future conquests",
                category = QuestCategory.WORK,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 10,
                xpReward = 50,
                dueDate = today
            ),
            Quest(
                title = "Divide and Conquer the Mountain",
                description = "Break Big Task into Steps - Transform overwhelming quests into manageable victories",
                category = QuestCategory.WORK,
                difficulty = Difficulty.MEDIUM,
                estimatedMinutes = 15,
                xpReward = 80,
                dueDate = today
            ),
            
            // Emotional Regulation
            Quest(
                title = "Commune with the Inner Spirit",
                description = "5-Minute Mindfulness - Find peace in the present moment",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 5,
                xpReward = 40,
                dueDate = today
            ),
            Quest(
                title = "Chronicle the Emotional Journey",
                description = "Journal Thoughts/Feelings - Record your inner adventures",
                category = QuestCategory.PERSONAL,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 15,
                xpReward = 70,
                dueDate = today
            ),
            Quest(
                title = "Summon the Wisdom of Allies",
                description = "Ask for Help When Needed - Recognize when to call upon your support network",
                category = QuestCategory.SOCIAL,
                difficulty = Difficulty.HARD,
                estimatedMinutes = 10,
                xpReward = 100,
                dueDate = null
            ),
            Quest(
                title = "Channel the Restless Energy",
                description = "Use Fidget Tool During Task - Transform nervous energy into focused power",
                category = QuestCategory.HEALTH,
                difficulty = Difficulty.EASY,
                estimatedMinutes = 30,
                xpReward = 60,
                dueDate = today
            )
        )
        
        initialQuests.forEach { quest ->
            questDao.insertQuest(quest)
        }
    }
}