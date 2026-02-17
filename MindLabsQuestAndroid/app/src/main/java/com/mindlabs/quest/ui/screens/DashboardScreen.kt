package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import kotlinx.coroutines.launch
import androidx.compose.ui.Modifier
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.ui.components.MindLabsCard
import com.mindlabs.quest.ui.components.StatCard
import com.mindlabs.quest.ui.theme.*
import com.mindlabs.quest.viewmodel.CharacterViewModel
import com.mindlabs.quest.viewmodel.QuestViewModel
import com.mindlabs.quest.ui.components.QuestCompletionDialog
import com.mindlabs.quest.ui.components.LevelUpDialog

@Composable
fun DashboardScreen(
    characterViewModel: CharacterViewModel = hiltViewModel(),
    questViewModel: QuestViewModel = hiltViewModel(),
    onNavigateToQuests: () -> Unit = {},
    onNavigateToTimer: () -> Unit = {},
    onNavigateToCreateQuest: () -> Unit = {}
) {
    val character by characterViewModel.character.collectAsState(initial = null)
    val activeQuests by questViewModel.activeQuests.collectAsState(initial = emptyList())
    val todaysQuests = activeQuests.filter { quest ->
        quest.dueDate?.let { dueDate ->
            val today = System.currentTimeMillis()
            val tomorrow = today + 86400000 // 24 hours in milliseconds
            dueDate in today..tomorrow
        } ?: false
    }
    
    // Celebration states
    var showQuestCompletionDialog by remember { mutableStateOf(false) }
    var questCompletionEvent by remember { mutableStateOf<com.mindlabs.quest.viewmodel.QuestCompletionEvent?>(null) }
    var showLevelUpDialog by remember { mutableStateOf(false) }
    var levelUpEvent by remember { mutableStateOf<com.mindlabs.quest.viewmodel.LevelUpEvent?>(null) }
    
    // Observe celebration events
    LaunchedEffect(questViewModel) {
        launch {
            questViewModel.questCompletedEvent.collect { event ->
                questCompletionEvent = event
                showQuestCompletionDialog = true
            }
        }
        launch {
            questViewModel.levelUpEvent.collect { event ->
                levelUpEvent = event
                // Delay level up dialog to show after quest completion
                kotlinx.coroutines.delay(500)
                showLevelUpDialog = true
            }
        }
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Header
        character?.let { char ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Welcome back,",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = char.displayName,
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                }
                
                // Character Level Badge
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = MindLabsPurple.copy(alpha = 0.1f)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = char.characterClass?.emoji ?: "🎮",
                            fontSize = 20.sp
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Lvl ${char.level}",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold,
                            color = MindLabsPurple
                        )
                    }
                }
            }
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        // Stats Overview
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            StatCard(
                modifier = Modifier.weight(1f),
                title = "Streak",
                value = "${character?.streak ?: 0}",
                icon = Icons.Default.LocalFireDepartment,
                color = MindLabsError
            )
            StatCard(
                modifier = Modifier.weight(1f),
                title = "XP Today",
                value = "250",
                icon = Icons.Default.Star,
                color = MindLabsWarning
            )
        }
        
        Spacer(modifier = Modifier.height(12.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            StatCard(
                modifier = Modifier.weight(1f),
                title = "Quests",
                value = "${character?.totalQuestsCompleted ?: 0}",
                icon = Icons.Default.CheckCircle,
                color = MindLabsSuccess
            )
            StatCard(
                modifier = Modifier.weight(1f),
                title = "Focus Time",
                value = "${(character?.totalFocusMinutes ?: 0) / 60}h",
                icon = Icons.Default.Timer,
                color = MindLabsBlue
            )
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        // Today's Quests
        MindLabsCard {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Today's Quests",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.SemiBold
                    )
                    TextButton(onClick = onNavigateToQuests) {
                        Text("See All")
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                if (todaysQuests.isEmpty()) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = Icons.Default.Assignment,
                                contentDescription = null,
                                modifier = Modifier.size(48.dp),
                                tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "No quests for today",
                                style = MaterialTheme.typography.bodyLarge,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Create your first quest!",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                            )
                        }
                    }
                } else {
                    todaysQuests.take(3).forEach { quest ->
                        QuestListItem(
                            quest = quest,
                            onComplete = {
                                questViewModel.completeQuest(quest)
                            }
                        )
                        if (quest != todaysQuests.last()) {
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                    }
                }
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Quick Actions
        MindLabsCard {
            Column {
                Text(
                    text = "Quick Actions",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.SemiBold
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    QuickActionButton(
                        modifier = Modifier.weight(1f),
                        text = "New Quest",
                        icon = Icons.Default.Add,
                        onClick = onNavigateToCreateQuest
                    )
                    QuickActionButton(
                        modifier = Modifier.weight(1f),
                        text = "Focus Mode",
                        icon = Icons.Default.Timer,
                        onClick = onNavigateToTimer
                    )
                }
            }
        }
    }
    
    // Show celebration dialogs
    if (showQuestCompletionDialog && questCompletionEvent != null) {
        QuestCompletionDialog(
            questTitle = questCompletionEvent!!.questTitle,
            xpEarned = questCompletionEvent!!.xpEarned,
            onDismiss = { showQuestCompletionDialog = false }
        )
    }
    
    if (showLevelUpDialog && levelUpEvent != null) {
        LevelUpDialog(
            newLevel = levelUpEvent!!.newLevel,
            newTitle = levelUpEvent!!.newTitle,
            characterName = levelUpEvent!!.characterName,
            onDismiss = { showLevelUpDialog = false }
        )
    }
}

@Composable
fun QuestListItem(
    quest: com.mindlabs.quest.data.models.Quest,
    onComplete: () -> Unit = {}
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Category Icon
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                modifier = Modifier.size(40.dp)
            ) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize()
                ) {
                    Text(
                        text = quest.category.emoji,
                        fontSize = 20.sp
                    )
                }
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Quest Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = quest.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Medium
                )
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = quest.difficulty.displayName,
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(quest.difficulty.color)
                    )
                    Text(
                        text = "•",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "${quest.estimatedMinutes} min",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "•",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "${quest.xpReward} XP",
                        style = MaterialTheme.typography.bodySmall,
                        color = MindLabsPurple
                    )
                }
            }
            
            // Complete Button
            IconButton(
                onClick = onComplete,
                modifier = Modifier.size(40.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.CheckCircleOutline,
                    contentDescription = "Complete",
                    tint = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}

@Composable
fun QuickActionButton(
    modifier: Modifier = Modifier,
    text: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(56.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(text)
    }
}