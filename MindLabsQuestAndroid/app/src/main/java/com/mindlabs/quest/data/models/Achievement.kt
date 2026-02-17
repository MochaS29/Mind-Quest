package com.mindlabs.quest.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "achievements")
data class Achievement(
    @PrimaryKey
    val id: String,
    val title: String,
    val description: String,
    val icon: String,
    val category: AchievementCategory,
    val requiredValue: Int,
    var progress: Int = 0,
    var isUnlocked: Boolean = false,
    var unlockedDate: Long? = null,
    val xpReward: Int = 50,
    val hidden: Boolean = false
) {
    val progressPercentage: Float
        get() = if (requiredValue > 0) progress.toFloat() / requiredValue.toFloat() else 0f
}

enum class AchievementCategory(val displayName: String) {
    QUEST("Quest Master"),
    FOCUS("Focus Champion"),
    STREAK("Consistency King"),
    LEVEL("Level Up"),
    SOCIAL("Social Butterfly"),
    SPECIAL("Special")
}