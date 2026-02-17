package com.mindlabs.quest.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindlabs.quest.data.models.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SocialViewModel @Inject constructor() : ViewModel() {
    
    private val _friends = MutableStateFlow<List<Friend>>(emptyList())
    val friends: StateFlow<List<Friend>> = _friends.asStateFlow()
    
    private val _friendRequests = MutableStateFlow<List<FriendRequest>>(emptyList())
    val friendRequests: StateFlow<List<FriendRequest>> = _friendRequests.asStateFlow()
    
    private val _recentActivities = MutableStateFlow<List<SharedActivity>>(emptyList())
    val recentActivities: StateFlow<List<SharedActivity>> = _recentActivities.asStateFlow()
    
    private val _activeChallenges = MutableStateFlow<List<CommunityChallenge>>(emptyList())
    val activeChallenges: StateFlow<List<CommunityChallenge>> = _activeChallenges.asStateFlow()
    
    init {
        loadDemoData()
    }
    
    private fun loadDemoData() {
        // Demo friends
        _friends.value = listOf(
            Friend(
                username = "questmaster",
                displayName = "Quest Master",
                avatar = "🧙",
                level = 25,
                currentStreak = 15,
                totalQuestsCompleted = 342,
                characterClass = CharacterClass.SCHOLAR,
                status = FriendStatus.ONLINE
            ),
            Friend(
                username = "productivityninja",
                displayName = "Productivity Ninja",
                avatar = "🥷",
                level = 18,
                currentStreak = 7,
                totalQuestsCompleted = 256,
                characterClass = CharacterClass.RANGER,
                status = FriendStatus.IN_QUEST
            ),
            Friend(
                username = "focuswarrior",
                displayName = "Focus Warrior",
                avatar = "⚔️",
                level = 22,
                currentStreak = 30,
                totalQuestsCompleted = 412,
                characterClass = CharacterClass.WARRIOR,
                status = FriendStatus.OFFLINE
            )
        )
        
        // Demo friend request
        _friendRequests.value = listOf(
            FriendRequest(
                fromUserId = "newuser123",
                toUserId = "current_user",
                fromUser = FriendUser(
                    username = "newbie",
                    displayName = "Eager Learner",
                    avatar = "🌟",
                    level = 5
                ),
                message = "Hey! I love your productivity streak. Let's be quest buddies!"
            )
        )
        
        // Demo activities
        _recentActivities.value = listOf(
            SharedActivity(
                userId = "questmaster",
                activityType = ActivityType.QUEST_COMPLETED,
                title = "Quest Master completed a quest",
                description = "Finished 'Complete Project Report' (Hard)"
            ),
            SharedActivity(
                userId = "productivityninja",
                activityType = ActivityType.LEVEL_UP,
                title = "Productivity Ninja reached Level 18!",
                description = "Gained 500 XP from completed quests"
            ),
            SharedActivity(
                userId = "focuswarrior",
                activityType = ActivityType.STREAK_MILESTONE,
                title = "Focus Warrior achieved a 30-day streak!",
                description = "Consistency pays off! 🔥"
            )
        )
        
        // Demo challenges
        _activeChallenges.value = listOf(
            CommunityChallenge(
                title = "Weekly Focus Champion",
                description = "Complete 20 quests this week",
                category = ChallengeCategory.WEEKLY,
                difficulty = Difficulty.MEDIUM,
                type = ChallengeType.QUEST_COUNT,
                startDate = System.currentTimeMillis() - 86400000 * 3, // 3 days ago
                endDate = System.currentTimeMillis() + 86400000 * 4, // 4 days from now
                goal = 20,
                unit = "quests",
                reward = ChallengeReward(
                    xp = 500,
                    badge = "weekly_champion",
                    title = "Weekly Champion"
                ),
                participants = listOf(
                    ChallengeParticipant("current_user", "You", "🎮", 12),
                    ChallengeParticipant("questmaster", "Quest Master", "🧙", 18),
                    ChallengeParticipant("productivityninja", "Productivity Ninja", "🥷", 15)
                )
            ),
            CommunityChallenge(
                title = "Daily Productivity Sprint",
                description = "Complete 5 quests today",
                category = ChallengeCategory.DAILY,
                difficulty = Difficulty.EASY,
                type = ChallengeType.QUEST_COUNT,
                startDate = System.currentTimeMillis() - 3600000 * 8, // 8 hours ago
                endDate = System.currentTimeMillis() + 3600000 * 16, // 16 hours from now
                goal = 5,
                unit = "quests",
                reward = ChallengeReward(xp = 100),
                participants = listOf(
                    ChallengeParticipant("current_user", "You", "🎮", 2)
                )
            )
        )
    }
    
    fun acceptFriendRequest(request: FriendRequest) {
        viewModelScope.launch {
            // Remove from requests
            _friendRequests.value = _friendRequests.value.filter { it.id != request.id }
            
            // Add as friend
            val newFriend = Friend(
                username = request.fromUser.username,
                displayName = request.fromUser.displayName,
                avatar = request.fromUser.avatar,
                level = request.fromUser.level,
                currentStreak = 0,
                totalQuestsCompleted = 0,
                status = FriendStatus.ONLINE
            )
            _friends.value = _friends.value + newFriend
            
            // Add activity
            val activity = SharedActivity(
                userId = "current_user",
                friendId = newFriend.id,
                activityType = ActivityType.ACHIEVEMENT_UNLOCKED,
                title = "You and ${newFriend.displayName} are now friends!",
                description = "Start your productivity journey together"
            )
            _recentActivities.value = listOf(activity) + _recentActivities.value
        }
    }
    
    fun declineFriendRequest(request: FriendRequest) {
        viewModelScope.launch {
            _friendRequests.value = _friendRequests.value.filter { it.id != request.id }
        }
    }
    
    fun sendFriendRequest(username: String, message: String) {
        // TODO: Implement friend request sending
    }
    
    fun removeFriend(friend: Friend) {
        viewModelScope.launch {
            _friends.value = _friends.value.filter { it.id != friend.id }
        }
    }
    
    fun joinChallenge(challenge: CommunityChallenge) {
        viewModelScope.launch {
            val updatedChallenge = challenge.copy(
                participants = challenge.participants + ChallengeParticipant(
                    userId = "current_user",
                    username = "You",
                    avatar = "🎮",
                    progress = 0
                )
            )
            
            _activeChallenges.value = _activeChallenges.value.map {
                if (it.id == challenge.id) updatedChallenge else it
            }
            
            // Add activity
            val activity = SharedActivity(
                userId = "current_user",
                activityType = ActivityType.CHALLENGE_JOINED,
                title = "You joined '${challenge.title}'",
                description = "Good luck! ${challenge.participants.size + 1} participants"
            )
            _recentActivities.value = listOf(activity) + _recentActivities.value
        }
    }
}