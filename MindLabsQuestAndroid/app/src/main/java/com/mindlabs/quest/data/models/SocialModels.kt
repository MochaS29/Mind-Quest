package com.mindlabs.quest.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "friends")
data class Friend(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val username: String,
    val displayName: String,
    val avatar: String,
    val level: Int,
    val currentStreak: Int,
    val totalQuestsCompleted: Int,
    val characterClass: CharacterClass? = null,
    val status: FriendStatus = FriendStatus.OFFLINE,
    val addedDate: Long = System.currentTimeMillis(),
    val lastActive: Long = System.currentTimeMillis()
)

enum class FriendStatus {
    ONLINE,
    IN_QUEST,
    OFFLINE
}

@Entity(tableName = "friend_requests")
data class FriendRequest(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val fromUserId: String,
    val toUserId: String,
    val fromUser: FriendUser,
    val message: String = "",
    val sentDate: Long = System.currentTimeMillis(),
    val status: RequestStatus = RequestStatus.PENDING
)

data class FriendUser(
    val username: String,
    val displayName: String,
    val avatar: String,
    val level: Int
)

enum class RequestStatus {
    PENDING,
    ACCEPTED,
    DECLINED
}

@Entity(tableName = "shared_activities")
data class SharedActivity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val userId: String,
    val friendId: String? = null,
    val activityType: ActivityType,
    val title: String,
    val description: String = "",
    val timestamp: Long = System.currentTimeMillis(),
    val metadata: Map<String, String> = emptyMap()
)

enum class ActivityType {
    QUEST_COMPLETED,
    LEVEL_UP,
    ACHIEVEMENT_UNLOCKED,
    CHALLENGE_JOINED,
    STREAK_MILESTONE
}

@Entity(tableName = "community_challenges")
data class CommunityChallenge(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val category: ChallengeCategory,
    val difficulty: Difficulty,
    val type: ChallengeType,
    val startDate: Long,
    val endDate: Long,
    val goal: Int,
    val unit: String,
    val reward: ChallengeReward,
    val participants: List<ChallengeParticipant> = emptyList(),
    val isActive: Boolean = true,
    val createdBy: String? = null
) {
    val timeRemaining: String
        get() {
            val now = System.currentTimeMillis()
            val diff = endDate - now
            return when {
                diff <= 0 -> "Ended"
                diff < 3_600_000 -> "${diff / 60_000}m"
                diff < 86_400_000 -> "${diff / 3_600_000}h"
                else -> "${diff / 86_400_000}d"
            }
        }
}

data class ChallengeParticipant(
    val userId: String,
    val username: String,
    val avatar: String,
    val progress: Int = 0,
    val joinedDate: Long = System.currentTimeMillis()
)

data class ChallengeReward(
    val xp: Int,
    val badge: String? = null,
    val title: String? = null,
    val bonusRewards: List<String> = emptyList()
)

enum class ChallengeCategory {
    DAILY,
    WEEKLY,
    MONTHLY,
    SPECIAL
}

enum class ChallengeType {
    QUEST_COUNT,
    FOCUS_TIME,
    STREAK_DAYS,
    XP_GAIN,
    CATEGORY_SPECIFIC
}