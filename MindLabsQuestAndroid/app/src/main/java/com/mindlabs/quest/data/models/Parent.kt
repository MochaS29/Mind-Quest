package com.mindlabs.quest.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "parents")
data class Parent(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val email: String,
    val hashedPassword: String, // In production, use proper authentication
    val createdAt: Long = System.currentTimeMillis(),
    val childIds: List<String> = emptyList() // List of linked child character IDs
)

// Parent reward model
@Entity(tableName = "rewards")
data class Reward(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val parentId: String,
    val title: String,
    val description: String,
    val xpCost: Int,
    val isActive: Boolean = true,
    val createdAt: Long = System.currentTimeMillis(),
    val category: RewardCategory = RewardCategory.GENERAL
)

enum class RewardCategory {
    SCREEN_TIME,
    TREATS,
    ACTIVITIES,
    PRIVILEGES,
    MONEY,
    GENERAL
}

// Progress report for parents
data class ChildProgress(
    val characterId: String,
    val characterName: String,
    val todayQuestsCompleted: Int,
    val todayQuestsTotal: Int,
    val weeklyQuestsCompleted: Int,
    val currentStreak: Int,
    val totalXpEarned: Int,
    val focusMinutesToday: Int,
    val lastActiveTime: Long
)