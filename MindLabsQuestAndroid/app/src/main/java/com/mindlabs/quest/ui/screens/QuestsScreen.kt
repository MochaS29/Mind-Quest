package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.models.QuestCategory
import com.mindlabs.quest.ui.components.EmptyState
import com.mindlabs.quest.viewmodel.QuestViewModel
import com.mindlabs.quest.ui.components.QuestCompletionDialog
import com.mindlabs.quest.ui.components.LevelUpDialog
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuestsScreen(
    questViewModel: QuestViewModel = hiltViewModel()
) {
    val activeQuests by questViewModel.activeQuests.collectAsState(initial = emptyList())
    val selectedCategory by questViewModel.selectedCategory.collectAsState(initial = null)
    
    var showCreateDialog by remember { mutableStateOf(false) }
    
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
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Quests") },
                actions = {
                    IconButton(onClick = { /* TODO: Show filter options */ }) {
                        Icon(Icons.Default.FilterList, contentDescription = "Filter")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showCreateDialog = true }
            ) {
                Icon(Icons.Default.Add, contentDescription = "Create Quest")
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Category Filter Chips
            CategoryFilterRow(
                selectedCategory = selectedCategory,
                onCategorySelected = { questViewModel.setSelectedCategory(it) }
            )
            
            // Quest List
            if (activeQuests.isEmpty()) {
                EmptyState(
                    modifier = Modifier.fillMaxSize(),
                    icon = Icons.Default.Assignment,
                    title = "No Active Quests",
                    description = "Create your first quest to start your adventure!",
                    actionLabel = "Create Quest",
                    onAction = { showCreateDialog = true }
                )
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    val filteredQuests = if (selectedCategory == null) {
                        activeQuests
                    } else {
                        activeQuests.filter { it.category == selectedCategory }
                    }
                    
                    items(filteredQuests) { quest ->
                        QuestCard(
                            quest = quest,
                            onComplete = { questViewModel.completeQuest(quest) },
                            onClick = { /* TODO: Navigate to quest detail */ }
                        )
                    }
                }
            }
        }
    }
    
    // Create Quest Dialog
    if (showCreateDialog) {
        CreateQuestDialog(
            onDismiss = { showCreateDialog = false },
            onCreate = { quest ->
                questViewModel.createQuest(quest)
                showCreateDialog = false
            }
        )
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
fun CategoryFilterRow(
    selectedCategory: QuestCategory?,
    onCategorySelected: (QuestCategory?) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        FilterChip(
            selected = selectedCategory == null,
            onClick = { onCategorySelected(null) },
            label = { Text("All") }
        )
        
        QuestCategory.values().forEach { category ->
            FilterChip(
                selected = selectedCategory == category,
                onClick = { onCategorySelected(category) },
                label = { 
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(category.emoji)
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(category.displayName)
                    }
                }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuestCard(
    quest: Quest,
    onComplete: () -> Unit,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Category Icon
            Surface(
                shape = MaterialTheme.shapes.small,
                color = MaterialTheme.colorScheme.primaryContainer,
                modifier = Modifier.size(48.dp)
            ) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize()
                ) {
                    Text(quest.category.emoji, style = MaterialTheme.typography.titleLarge)
                }
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            // Quest Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = quest.title,
                    style = MaterialTheme.typography.titleMedium
                )
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    AssistChip(
                        onClick = { },
                        modifier = Modifier.height(24.dp),
                        colors = AssistChipDefaults.assistChipColors(
                            containerColor = Color(quest.difficulty.color).copy(alpha = 0.2f)
                        ),
                        label = {
                            Text(
                                quest.difficulty.displayName,
                                style = MaterialTheme.typography.labelSmall,
                                color = Color(quest.difficulty.color)
                            )
                        }
                    )
                    
                    Text(
                        "${quest.estimatedMinutes} min",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    
                    Text(
                        "${quest.xpReward} XP",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }
            
            // Complete Button
            IconButton(onClick = onComplete) {
                Icon(
                    Icons.Default.CheckCircleOutline,
                    contentDescription = "Complete",
                    tint = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}