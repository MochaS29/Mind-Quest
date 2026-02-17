package com.mindlabs.quest.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "characters")
data class Character(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    var name: String = "",
    var characterClass: CharacterClass? = null,
    var level: Int = 1,
    var xp: Int = 0,
    var hp: Int = 100,
    var maxHp: Int = 100,
    var energy: Int = 100,
    var maxEnergy: Int = 100,
    var streak: Int = 0,
    var longestStreak: Int = 0,
    var totalQuestsCompleted: Int = 0,
    var totalFocusMinutes: Int = 0,
    var joinedDate: Long = System.currentTimeMillis(),
    var parentId: String? = null, // Link to parent account if exists
    var availableRewardXp: Int = 0 // XP that can be spent on rewards
) {
    val xpForNextLevel: Int
        get() = level * 100
    
    val xpProgress: Float
        get() = xp.toFloat() / xpForNextLevel.toFloat()
    
    // Clever title generation
    val displayName: String
        get() = "$name $cleverTitle"
    
    val cleverTitle: String
        get() {
            val titles = when {
                level >= 50 -> epicTitles
                level >= 25 -> advancedTitles
                level >= 10 -> intermediateTitles
                level >= 5 -> beginnerTitles
                else -> noviceTitles
            }
            
            // Use a combination of level and character name to generate consistent title
            val index = (name.hashCode() + level) % titles.size
            return titles[index.coerceAtLeast(0)]
        }
    
    fun addXP(amount: Int) {
        val startXp = xp
        val startLevel = level
        xp += amount
        while (xp >= xpForNextLevel) {
            xp -= xpForNextLevel
            levelUp()
        }
        // Log for debugging
        println("Character XP Update: Start($startLevel, $startXp) + $amount = Current($level, $xp)")
    }
    
    private fun levelUp() {
        level++
        maxHp += 10
        hp = maxHp
        maxEnergy += 10
        energy = maxEnergy
    }
    
    companion object {
        private val noviceTitles = listOf(
            "the Task Apprentice",
            "the Quest Seeker",
            "the Time Wanderer",
            "the Scroll Scribbler",
            "the Dungeon Delver",
            "the Potion Sipper",
            "the Novice Adventurer",
            "the Rookie Champion"
        )
        
        private val beginnerTitles = listOf(
            "the Habit Forger",
            "the Streak Keeper",
            "the Focus Mage",
            "the Quest Walker",
            "the Time Bender",
            "the XP Hunter",
            "the Daily Crusader",
            "the Task Warrior"
        )
        
        private val intermediateTitles = listOf(
            "the Procrastination Banisher",
            "the Productivity Paladin",
            "the Time Wizard",
            "the Quest Master",
            "the Focus Knight",
            "the Habit Champion",
            "the Deadline Destroyer",
            "the Task Assassin"
        )
        
        private val advancedTitles = listOf(
            "the Legendary Achiever",
            "the Epic Questmaster",
            "the Grand Time Lord",
            "the Master of Scrolls",
            "the Productivity Dragon",
            "the Focus Archmage",
            "the Habit Overlord",
            "the Task Titan"
        )
        
        private val epicTitles = listOf(
            "the Procrastination Slayer",
            "the Eternal Productivity Guardian",
            "the Supreme Focus Master",
            "the Legendary Quest Conqueror",
            "the Time Lord of All Realms",
            "Destroyer of Deadlines",
            "the Unstoppable Force",
            "Master of the Infinite Todo List"
        )
    }
}

enum class CharacterClass(val displayName: String, val description: String, val emoji: String) {
    WARRIOR("Warrior", "Masters of discipline and strength", "⚔️"),
    SCHOLAR("Scholar", "Seekers of knowledge and wisdom", "📚"),
    RANGER("Ranger", "Explorers and jack-of-all-trades", "🏹"),
    HEALER("Healer", "Nurturers of mind and body", "💚");
}