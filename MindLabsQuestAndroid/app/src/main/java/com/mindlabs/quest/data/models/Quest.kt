package com.mindlabs.quest.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "quests")
data class Quest(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val category: QuestCategory,
    val difficulty: Difficulty,
    val estimatedMinutes: Int,
    val xpReward: Int,
    val energyCost: Int = 10,
    var isCompleted: Boolean = false,
    var completedDate: Long? = null,
    var actualMinutes: Int? = null,
    var notes: String = "",
    var dueDate: Long? = null,
    var reminder: Long? = null,
    var recurring: RecurringType = RecurringType.NONE,
    var tags: List<String> = emptyList(),
    var subtasks: List<Subtask> = emptyList(),
    val createdDate: Long = System.currentTimeMillis()
)

data class Subtask(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    var isCompleted: Boolean = false
)

enum class QuestCategory(val displayName: String, val emoji: String) {
    WORK("Work", "💼"),
    PERSONAL("Personal", "🌟"),
    HEALTH("Health", "❤️"),
    LEARNING("Learning", "📚"),
    CREATIVE("Creative", "🎨"),
    SOCIAL("Social", "👥"),
    HOUSEHOLD("Household", "🏠"),
    OTHER("Other", "📌")
}

enum class Difficulty(val displayName: String, val xpMultiplier: Float, val color: Long) {
    EASY("Easy", 1.0f, 0xFF4CAF50),
    MEDIUM("Medium", 1.5f, 0xFFFF9800),
    HARD("Hard", 2.0f, 0xFFF44336),
    LEGENDARY("Legendary", 3.0f, 0xFF9C27B0)
}

enum class RecurringType {
    NONE,
    DAILY,
    WEEKLY,
    MONTHLY
}