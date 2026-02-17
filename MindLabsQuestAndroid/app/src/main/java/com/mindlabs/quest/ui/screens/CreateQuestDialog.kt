package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.mindlabs.quest.data.models.Difficulty
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.models.QuestCategory

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateQuestDialog(
    onDismiss: () -> Unit,
    onCreate: (Quest) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(QuestCategory.WORK) }
    var selectedDifficulty by remember { mutableStateOf(Difficulty.MEDIUM) }
    var estimatedMinutes by remember { mutableStateOf("30") }
    
    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .fillMaxHeight(0.8f)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp)
            ) {
                Text(
                    "Create New Quest",
                    style = MaterialTheme.typography.headlineSmall
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Title
                    OutlinedTextField(
                        value = title,
                        onValueChange = { title = it },
                        label = { Text("Quest Title") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    // Description
                    OutlinedTextField(
                        value = description,
                        onValueChange = { description = it },
                        label = { Text("Description") },
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 3
                    )
                    
                    // Category
                    Text("Category", style = MaterialTheme.typography.labelLarge)
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        QuestCategory.values().forEach { category ->
                            FilterChip(
                                selected = selectedCategory == category,
                                onClick = { selectedCategory = category },
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
                    
                    // Difficulty
                    Text("Difficulty", style = MaterialTheme.typography.labelLarge)
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Difficulty.values().forEach { difficulty ->
                            FilterChip(
                                selected = selectedDifficulty == difficulty,
                                onClick = { selectedDifficulty = difficulty },
                                label = { Text(difficulty.displayName) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = Color(difficulty.color).copy(alpha = 0.2f)
                                )
                            )
                        }
                    }
                    
                    // Estimated Time
                    OutlinedTextField(
                        value = estimatedMinutes,
                        onValueChange = { estimatedMinutes = it.filter { char -> char.isDigit() } },
                        label = { Text("Estimated Minutes") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                
                // Actions
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) {
                        Text("Cancel")
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Button(
                        onClick = {
                            if (title.isNotBlank() && estimatedMinutes.isNotBlank()) {
                                val quest = Quest(
                                    title = title,
                                    description = description,
                                    category = selectedCategory,
                                    difficulty = selectedDifficulty,
                                    estimatedMinutes = estimatedMinutes.toIntOrNull() ?: 30,
                                    xpReward = calculateXP(selectedDifficulty, estimatedMinutes.toIntOrNull() ?: 30)
                                )
                                onCreate(quest)
                            }
                        },
                        enabled = title.isNotBlank() && estimatedMinutes.isNotBlank()
                    ) {
                        Text("Create")
                    }
                }
            }
        }
    }
}

private fun calculateXP(difficulty: Difficulty, minutes: Int): Int {
    val baseXP = (minutes / 5) * 10 // 10 XP per 5 minutes
    return (baseXP * difficulty.xpMultiplier).toInt()
}

// Temporary FlowRow implementation until Compose Foundation 1.4.0
@Composable
fun FlowRow(
    modifier: Modifier = Modifier,
    horizontalArrangement: Arrangement.Horizontal = Arrangement.Start,
    content: @Composable () -> Unit
) {
    Row(
        modifier = modifier,
        horizontalArrangement = horizontalArrangement
    ) {
        content()
    }
}