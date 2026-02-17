package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.data.models.ChildProgress
import com.mindlabs.quest.data.models.Reward
import com.mindlabs.quest.data.models.RewardCategory
import com.mindlabs.quest.ui.components.MindLabsCard
import com.mindlabs.quest.ui.components.StatCard
import com.mindlabs.quest.ui.theme.*
import com.mindlabs.quest.viewmodel.ParentViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ParentDashboardScreen(
    parentViewModel: ParentViewModel = hiltViewModel(),
    onNavigateToChildDetail: (String) -> Unit = {},
    onNavigateToRewards: () -> Unit = {},
    onNavigateToSettings: () -> Unit = {}
) {
    val parent by parentViewModel.parent.collectAsState(initial = null)
    val childrenProgress by parentViewModel.childrenProgress.collectAsState(initial = emptyList())
    val activeRewards by parentViewModel.activeRewards.collectAsState(initial = emptyList())
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Parent Dashboard") },
                actions = {
                    IconButton(onClick = onNavigateToSettings) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onNavigateToRewards,
                containerColor = MindLabsPurple
            ) {
                Icon(Icons.Default.CardGiftcard, contentDescription = "Manage Rewards")
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            // Welcome Header
            parent?.let { p ->
                Text(
                    text = "Welcome, ${p.name}",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )
                
                Spacer(modifier = Modifier.height(24.dp))
            }
            
            // Children Overview
            Text(
                text = "Your Children",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            if (childrenProgress.isEmpty()) {
                MindLabsCard {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            imageVector = Icons.Default.PersonAdd,
                            contentDescription = null,
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "No children added yet",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(
                            onClick = { /* TODO: Add child */ },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = MindLabsPurple
                            )
                        ) {
                            Text("Add Child")
                        }
                    }
                }
            } else {
                childrenProgress.forEach { child ->
                    ChildProgressCard(
                        childProgress = child,
                        onClick = { onNavigateToChildDetail(child.characterId) }
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Active Rewards Section
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Active Rewards",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.SemiBold
                )
                TextButton(onClick = onNavigateToRewards) {
                    Text("Manage")
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            if (activeRewards.isEmpty()) {
                MindLabsCard {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            imageVector = Icons.Default.CardGiftcard,
                            contentDescription = null,
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "No rewards set up yet",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = "Create rewards to motivate your children",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.height(200.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(activeRewards.take(5)) { reward ->
                        RewardListItem(reward = reward)
                    }
                }
            }
        }
    }
}

@Composable
fun ChildProgressCard(
    childProgress: ChildProgress,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = childProgress.characterName,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    
                    // Activity Status
                    val lastActiveText = getLastActiveText(childProgress.lastActiveTime)
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Schedule,
                            contentDescription = null,
                            modifier = Modifier.size(16.dp),
                            tint = if (isRecentlyActive(childProgress.lastActiveTime)) 
                                MindLabsSuccess else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = lastActiveText,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                
                // Streak Badge
                if (childProgress.currentStreak > 0) {
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = MindLabsError.copy(alpha = 0.1f)
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.LocalFireDepartment,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp),
                                tint = MindLabsError
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "${childProgress.currentStreak} day streak",
                                style = MaterialTheme.typography.labelMedium,
                                color = MindLabsError
                            )
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Today's Progress
            Column {
                Text(
                    text = "Today's Progress",
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
                
                LinearProgressIndicator(
                    progress = if (childProgress.todayQuestsTotal > 0) 
                        childProgress.todayQuestsCompleted.toFloat() / childProgress.todayQuestsTotal.toFloat()
                    else 0f,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp),
                    color = MindLabsPurple,
                    trackColor = MindLabsPurple.copy(alpha = 0.2f)
                )
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Text(
                    text = "${childProgress.todayQuestsCompleted} of ${childProgress.todayQuestsTotal} quests completed",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Stats Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                MiniStatCard(
                    icon = Icons.Default.Timer,
                    value = "${childProgress.focusMinutesToday}",
                    label = "min today",
                    color = MindLabsBlue
                )
                MiniStatCard(
                    icon = Icons.Default.CheckCircle,
                    value = "${childProgress.weeklyQuestsCompleted}",
                    label = "this week",
                    color = MindLabsSuccess
                )
                MiniStatCard(
                    icon = Icons.Default.Star,
                    value = "${childProgress.totalXpEarned}",
                    label = "XP today",
                    color = MindLabsWarning
                )
            }
        }
    }
}

@Composable
fun MiniStatCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(20.dp),
            tint = color
        )
        Text(
            text = value,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun RewardListItem(reward: Reward) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Category Icon
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = getCategoryColor(reward.category).copy(alpha = 0.1f),
                modifier = Modifier.size(40.dp)
            ) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize()
                ) {
                    Text(
                        text = getCategoryEmoji(reward.category),
                        fontSize = 20.sp
                    )
                }
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Reward Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = reward.title,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    text = reward.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            // XP Cost
            Surface(
                shape = RoundedCornerShape(20.dp),
                color = MindLabsWarning.copy(alpha = 0.1f)
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Star,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                        tint = MindLabsWarning
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${reward.xpCost}",
                        style = MaterialTheme.typography.labelLarge,
                        color = MindLabsWarning,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

private fun getLastActiveText(lastActiveTime: Long): String {
    val now = System.currentTimeMillis()
    val diff = now - lastActiveTime
    
    return when {
        diff < 3600000 -> "Active now" // Less than 1 hour
        diff < 86400000 -> "Active today" // Less than 24 hours
        diff < 172800000 -> "Active yesterday" // Less than 48 hours
        else -> "Last active ${SimpleDateFormat("MMM d", Locale.getDefault()).format(Date(lastActiveTime))}"
    }
}

private fun isRecentlyActive(lastActiveTime: Long): Boolean {
    return System.currentTimeMillis() - lastActiveTime < 3600000 // Active within last hour
}

private fun getCategoryColor(category: RewardCategory): Color {
    return when (category) {
        RewardCategory.SCREEN_TIME -> MindLabsBlue
        RewardCategory.TREATS -> MindLabsWarning
        RewardCategory.ACTIVITIES -> MindLabsSuccess
        RewardCategory.PRIVILEGES -> MindLabsPurple
        RewardCategory.MONEY -> MindLabsError
        RewardCategory.GENERAL -> MindLabsTeal
    }
}

private fun getCategoryEmoji(category: RewardCategory): String {
    return when (category) {
        RewardCategory.SCREEN_TIME -> "📱"
        RewardCategory.TREATS -> "🍪"
        RewardCategory.ACTIVITIES -> "🎮"
        RewardCategory.PRIVILEGES -> "⭐"
        RewardCategory.MONEY -> "💰"
        RewardCategory.GENERAL -> "🎁"
    }
}