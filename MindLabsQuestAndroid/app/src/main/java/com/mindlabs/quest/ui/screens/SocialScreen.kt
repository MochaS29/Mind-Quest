package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.data.models.Friend
import com.mindlabs.quest.data.models.FriendStatus
import com.mindlabs.quest.ui.components.EmptyState
import com.mindlabs.quest.ui.components.MindLabsCard
import com.mindlabs.quest.ui.theme.*
import com.mindlabs.quest.viewmodel.SocialViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SocialScreen(
    socialViewModel: SocialViewModel = hiltViewModel()
) {
    val friends by socialViewModel.friends.collectAsState(initial = emptyList())
    val friendRequests by socialViewModel.friendRequests.collectAsState(initial = emptyList())
    val recentActivities by socialViewModel.recentActivities.collectAsState(initial = emptyList())
    val challenges by socialViewModel.activeChallenges.collectAsState(initial = emptyList())
    
    var selectedTab by remember { mutableStateOf(SocialTab.FRIENDS) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Social Hub") },
                actions = {
                    IconButton(onClick = { /* TODO: Add friend */ }) {
                        Icon(Icons.Default.PersonAdd, contentDescription = "Add Friend")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Tab Row
            TabRow(
                selectedTabIndex = selectedTab.ordinal,
                modifier = Modifier.fillMaxWidth()
            ) {
                SocialTab.values().forEach { tab ->
                    Tab(
                        selected = selectedTab == tab,
                        onClick = { selectedTab = tab },
                        text = { Text(tab.title) },
                        icon = {
                            Icon(
                                imageVector = tab.icon,
                                contentDescription = null
                            )
                        }
                    )
                }
            }
            
            // Tab Content
            when (selectedTab) {
                SocialTab.FRIENDS -> FriendsTab(
                    friends = friends,
                    friendRequests = friendRequests,
                    onAcceptRequest = { socialViewModel.acceptFriendRequest(it) },
                    onDeclineRequest = { socialViewModel.declineFriendRequest(it) }
                )
                SocialTab.ACTIVITY -> ActivityTab(activities = recentActivities)
                SocialTab.CHALLENGES -> ChallengesTab(challenges = challenges)
                SocialTab.LEADERBOARD -> LeaderboardTab(friends = friends)
            }
        }
    }
}

@Composable
fun FriendsTab(
    friends: List<Friend>,
    friendRequests: List<com.mindlabs.quest.data.models.FriendRequest>,
    onAcceptRequest: (com.mindlabs.quest.data.models.FriendRequest) -> Unit,
    onDeclineRequest: (com.mindlabs.quest.data.models.FriendRequest) -> Unit
) {
    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Friend Requests Section
        if (friendRequests.isNotEmpty()) {
            item {
                Text(
                    "Friend Requests",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }
            
            items(friendRequests) { request ->
                FriendRequestCard(
                    request = request,
                    onAccept = { onAcceptRequest(request) },
                    onDecline = { onDeclineRequest(request) }
                )
            }
            
            item { Spacer(modifier = Modifier.height(16.dp)) }
        }
        
        // Online Friends
        val onlineFriends = friends.filter { it.status != FriendStatus.OFFLINE }
        if (onlineFriends.isNotEmpty()) {
            item {
                Text(
                    "Online Now (${onlineFriends.size})",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }
            
            items(onlineFriends) { friend ->
                FriendCard(friend = friend)
            }
            
            item { Spacer(modifier = Modifier.height(16.dp)) }
        }
        
        // All Friends
        item {
            Text(
                "All Friends (${friends.size})",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
        }
        
        if (friends.isEmpty()) {
            item {
                EmptyState(
                    icon = Icons.Default.PersonOff,
                    title = "No Friends Yet",
                    description = "Add friends to share your productivity journey!",
                    actionLabel = "Add Friend",
                    onAction = { /* TODO: Show add friend dialog */ }
                )
            }
        } else {
            items(friends.sortedBy { it.displayName }) { friend ->
                FriendCard(friend = friend)
            }
        }
    }
}

@Composable
fun ActivityTab(
    activities: List<com.mindlabs.quest.data.models.SharedActivity>
) {
    if (activities.isEmpty()) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            EmptyState(
                icon = Icons.Default.RssFeed,
                title = "No Recent Activity",
                description = "Activities from you and your friends will appear here"
            )
        }
    } else {
        LazyColumn(
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(activities) { activity ->
                ActivityCard(activity = activity)
            }
        }
    }
}

@Composable
fun ChallengesTab(
    challenges: List<com.mindlabs.quest.data.models.CommunityChallenge>
) {
    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            MindLabsCard {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            "Active Challenges",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                        Text(
                            "Compete with friends and earn rewards",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    
                    Button(
                        onClick = { /* TODO: Create challenge */ },
                        modifier = Modifier.height(36.dp)
                    ) {
                        Text("Create", style = MaterialTheme.typography.labelMedium)
                    }
                }
            }
        }
        
        if (challenges.isEmpty()) {
            item {
                EmptyState(
                    icon = Icons.Default.EmojiEvents,
                    title = "No Active Challenges",
                    description = "Create or join challenges to compete with friends!",
                    actionLabel = "Browse Challenges",
                    onAction = { /* TODO: Show challenge browser */ }
                )
            }
        } else {
            items(challenges) { challenge ->
                ChallengeCard(challenge = challenge)
            }
        }
    }
}

@Composable
fun LeaderboardTab(
    friends: List<Friend>
) {
    var selectedLeaderboard by remember { mutableStateOf(LeaderboardType.LEVEL) }
    
    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        // Leaderboard Type Selector
        LazyRow(
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(LeaderboardType.values().toList()) { type ->
                FilterChip(
                    selected = selectedLeaderboard == type,
                    onClick = { selectedLeaderboard = type },
                    label = { Text(type.title) }
                )
            }
        }
        
        // Leaderboard List
        LazyColumn(
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            val sortedFriends = when (selectedLeaderboard) {
                LeaderboardType.LEVEL -> friends.sortedByDescending { it.level }
                LeaderboardType.STREAK -> friends.sortedByDescending { it.currentStreak }
                LeaderboardType.QUESTS -> friends.sortedByDescending { it.totalQuestsCompleted }
                LeaderboardType.XP -> friends.sortedByDescending { it.level * 100 } // Approximate XP
            }
            
            itemsIndexed(sortedFriends) { index, friend ->
                LeaderboardCard(
                    rank = index + 1,
                    friend = friend,
                    type = selectedLeaderboard
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FriendCard(
    friend: Friend
) {
    Card(
        onClick = { /* TODO: Show friend profile */ },
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Avatar
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer)
            ) {
                Text(
                    text = friend.avatar,
                    fontSize = 24.sp
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // Friend Info
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = friend.displayName,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Medium
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    // Status Indicator
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(
                                when (friend.status) {
                                    FriendStatus.ONLINE -> MindLabsSuccess
                                    FriendStatus.IN_QUEST -> MindLabsWarning
                                    FriendStatus.OFFLINE -> Color.Gray
                                }
                            )
                    )
                }
                
                Row(
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "Lvl ${friend.level}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "${friend.currentStreak}🔥",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    friend.characterClass?.let { charClass ->
                        Text(
                            text = charClass.emoji,
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                }
            }
            
            // Action Button
            IconButton(onClick = { /* TODO: Challenge friend */ }) {
                Icon(
                    Icons.Default.SportsEsports,
                    contentDescription = "Challenge",
                    tint = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}

@Composable
fun FriendRequestCard(
    request: com.mindlabs.quest.data.models.FriendRequest,
    onAccept: () -> Unit,
    onDecline: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.5f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Avatar
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primaryContainer)
                ) {
                    Text(
                        text = request.fromUser.avatar,
                        fontSize = 24.sp
                    )
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                // User Info
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = request.fromUser.displayName,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Medium
                    )
                    Text(
                        text = "Level ${request.fromUser.level}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            if (request.message.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = request.message,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Action Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                TextButton(onClick = onDecline) {
                    Text("Decline")
                }
                Spacer(modifier = Modifier.width(8.dp))
                Button(onClick = onAccept) {
                    Text("Accept")
                }
            }
        }
    }
}

@Composable
fun ActivityCard(
    activity: com.mindlabs.quest.data.models.SharedActivity
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Activity Icon
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(
                        when (activity.activityType) {
                            com.mindlabs.quest.data.models.ActivityType.QUEST_COMPLETED -> MindLabsSuccess
                            com.mindlabs.quest.data.models.ActivityType.LEVEL_UP -> MindLabsPurple
                            com.mindlabs.quest.data.models.ActivityType.ACHIEVEMENT_UNLOCKED -> MindLabsWarning
                            com.mindlabs.quest.data.models.ActivityType.CHALLENGE_JOINED -> MindLabsBlue
                            com.mindlabs.quest.data.models.ActivityType.STREAK_MILESTONE -> MindLabsError
                        }.copy(alpha = 0.2f)
                    )
            ) {
                Icon(
                    imageVector = when (activity.activityType) {
                        com.mindlabs.quest.data.models.ActivityType.QUEST_COMPLETED -> Icons.Default.CheckCircle
                        com.mindlabs.quest.data.models.ActivityType.LEVEL_UP -> Icons.Default.TrendingUp
                        com.mindlabs.quest.data.models.ActivityType.ACHIEVEMENT_UNLOCKED -> Icons.Default.EmojiEvents
                        com.mindlabs.quest.data.models.ActivityType.CHALLENGE_JOINED -> Icons.Default.Flag
                        com.mindlabs.quest.data.models.ActivityType.STREAK_MILESTONE -> Icons.Default.LocalFireDepartment
                    },
                    contentDescription = null,
                    tint = when (activity.activityType) {
                        com.mindlabs.quest.data.models.ActivityType.QUEST_COMPLETED -> MindLabsSuccess
                        com.mindlabs.quest.data.models.ActivityType.LEVEL_UP -> MindLabsPurple
                        com.mindlabs.quest.data.models.ActivityType.ACHIEVEMENT_UNLOCKED -> MindLabsWarning
                        com.mindlabs.quest.data.models.ActivityType.CHALLENGE_JOINED -> MindLabsBlue
                        com.mindlabs.quest.data.models.ActivityType.STREAK_MILESTONE -> MindLabsError
                    },
                    modifier = Modifier.size(20.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Activity Details
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = activity.title,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium
                )
                if (activity.description.isNotEmpty()) {
                    Text(
                        text = activity.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Text(
                    text = formatTimeAgo(activity.timestamp),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChallengeCard(
    challenge: com.mindlabs.quest.data.models.CommunityChallenge
) {
    Card(
        onClick = { /* TODO: Show challenge details */ },
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = challenge.title,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = challenge.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                
                // Difficulty Badge
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = Color(challenge.difficulty.color).copy(alpha = 0.2f)
                ) {
                    Text(
                        text = challenge.difficulty.displayName,
                        style = MaterialTheme.typography.labelSmall,
                        color = Color(challenge.difficulty.color),
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Progress Bar
            val userProgress = challenge.participants.find { it.userId == "current_user" }
            val progress = userProgress?.let {
                it.progress.toFloat() / challenge.goal.toFloat()
            } ?: 0f
            
            LinearProgressIndicator(
                progress = progress,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp))
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Challenge Info
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Default.Group,
                            contentDescription = null,
                            modifier = Modifier.size(16.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "${challenge.participants.size}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Default.Timer,
                            contentDescription = null,
                            modifier = Modifier.size(16.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = challenge.timeRemaining,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                
                if (userProgress == null) {
                    Button(
                        onClick = { /* TODO: Join challenge */ },
                        modifier = Modifier.height(32.dp)
                    ) {
                        Text("Join", style = MaterialTheme.typography.labelMedium)
                    }
                } else {
                    Text(
                        text = "${userProgress.progress}/${challenge.goal}",
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }
    }
}

@Composable
fun LeaderboardCard(
    rank: Int,
    friend: Friend,
    type: LeaderboardType
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = when (rank) {
                1 -> MindLabsWarning.copy(alpha = 0.1f)
                2 -> Color.Gray.copy(alpha = 0.1f)
                3 -> Color(0xFFCD7F32).copy(alpha = 0.1f) // Bronze
                else -> MaterialTheme.colorScheme.surface
            }
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Rank
            Text(
                text = "#$rank",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = when (rank) {
                    1 -> MindLabsWarning
                    2 -> Color.Gray
                    3 -> Color(0xFFCD7F32)
                    else -> MaterialTheme.colorScheme.onSurface
                },
                modifier = Modifier.width(40.dp)
            )
            
            // Avatar
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer)
            ) {
                Text(
                    text = friend.avatar,
                    fontSize = 20.sp
                )
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Name
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = friend.displayName,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium
                )
                friend.characterClass?.let { charClass ->
                    Text(
                        text = "${charClass.emoji} ${charClass.displayName}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            // Value
            Text(
                text = when (type) {
                    LeaderboardType.LEVEL -> "Lvl ${friend.level}"
                    LeaderboardType.STREAK -> "${friend.currentStreak}🔥"
                    LeaderboardType.QUESTS -> "${friend.totalQuestsCompleted}"
                    LeaderboardType.XP -> "${friend.level * 100} XP"
                },
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}

enum class SocialTab(val title: String, val icon: ImageVector) {
    FRIENDS("Friends", Icons.Default.Group),
    ACTIVITY("Activity", Icons.Default.RssFeed),
    CHALLENGES("Challenges", Icons.Default.EmojiEvents),
    LEADERBOARD("Leaderboard", Icons.Default.Leaderboard)
}

enum class LeaderboardType(val title: String) {
    LEVEL("Level"),
    STREAK("Streak"),
    QUESTS("Quests"),
    XP("Total XP")
}

private fun formatTimeAgo(timestamp: Long): String {
    val now = System.currentTimeMillis()
    val diff = now - timestamp
    
    return when {
        diff < 60_000 -> "Just now"
        diff < 3_600_000 -> "${diff / 60_000}m ago"
        diff < 86_400_000 -> "${diff / 3_600_000}h ago"
        diff < 604_800_000 -> "${diff / 86_400_000}d ago"
        else -> "${diff / 604_800_000}w ago"
    }
}