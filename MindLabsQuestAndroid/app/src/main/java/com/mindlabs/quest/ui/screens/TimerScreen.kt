package com.mindlabs.quest.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.ui.components.MindLabsCard
import com.mindlabs.quest.ui.theme.*
import com.mindlabs.quest.viewmodel.FocusViewModel
import com.mindlabs.quest.viewmodel.QuestViewModel
import kotlinx.coroutines.delay
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TimerScreen(
    focusViewModel: FocusViewModel = hiltViewModel(),
    questViewModel: QuestViewModel = hiltViewModel()
) {
    val focusState by focusViewModel.focusState.collectAsState(initial = null)
    val activeQuests by questViewModel.activeQuests.collectAsState(initial = emptyList())
    
    var showQuestSelector by remember { mutableStateOf(false) }
    var showPresetSelector by remember { mutableStateOf(false) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Focus Timer") },
                actions = {
                    IconButton(onClick = { /* TODO: Show focus history */ }) {
                        Icon(Icons.Default.History, contentDescription = "History")
                    }
                    IconButton(onClick = { /* TODO: Show settings */ }) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                }
            )
        }
    ) { paddingValues ->
        focusState?.let { state ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
            Spacer(modifier = Modifier.height(32.dp))
            
            // Timer Circle
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(280.dp)
            ) {
                CircularTimer(
                    progress = state.progress,
                    timeRemaining = state.timeRemaining,
                    isRunning = state.isRunning
                )
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Current Quest Info
            state.currentQuest?.let { quest ->
                MindLabsCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(quest.category.emoji, fontSize = 24.sp)
                        Spacer(modifier = Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = quest.title,
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                text = "${quest.estimatedMinutes} min • ${quest.xpReward} XP",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            } ?: run {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp),
                    onClick = { showQuestSelector = true },
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            "Select a Quest",
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Timer Controls
            Row(
                modifier = Modifier.padding(horizontal = 24.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Play/Pause Button
                FilledIconButton(
                    onClick = {
                        if (state.isRunning) {
                            focusViewModel.pauseTimer()
                        } else {
                            focusViewModel.startTimer()
                        }
                    },
                    modifier = Modifier.size(64.dp)
                ) {
                    Icon(
                        imageVector = if (state.isRunning) Icons.Default.Pause else Icons.Default.PlayArrow,
                        contentDescription = if (state.isRunning) "Pause" else "Start",
                        modifier = Modifier.size(32.dp)
                    )
                }
                
                // Stop Button
                OutlinedIconButton(
                    onClick = { focusViewModel.stopTimer() },
                    modifier = Modifier.size(64.dp),
                    enabled = state.timeRemaining < state.totalTime
                ) {
                    Icon(
                        Icons.Default.Stop,
                        contentDescription = "Stop",
                        modifier = Modifier.size(32.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Quick Timer Presets
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp)
            ) {
                Text(
                    "Quick Timers",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                
                Spacer(modifier = Modifier.height(12.dp))
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    TimerPresetChip(
                        modifier = Modifier.weight(1f),
                        label = "Pomodoro",
                        minutes = 25,
                        onClick = { focusViewModel.setTimer(25) }
                    )
                    TimerPresetChip(
                        modifier = Modifier.weight(1f),
                        label = "Short",
                        minutes = 15,
                        onClick = { focusViewModel.setTimer(15) }
                    )
                    TimerPresetChip(
                        modifier = Modifier.weight(1f),
                        label = "Long",
                        minutes = 45,
                        onClick = { focusViewModel.setTimer(45) }
                    )
                    IconButton(
                        onClick = { showPresetSelector = true }
                    ) {
                        Icon(Icons.Default.MoreVert, contentDescription = "More")
                    }
                }
                
                Spacer(modifier = Modifier.height(12.dp))
                
                // Break Timer
                OutlinedButton(
                    onClick = { focusViewModel.startBreak(5) },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.Coffee, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Take a Break")
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Session Stats
            if (state.completedSessions > 0) {
                MindLabsCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                "${state.completedSessions}",
                                style = MaterialTheme.typography.headlineMedium,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                "Sessions",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                "${state.totalFocusMinutes}",
                                style = MaterialTheme.typography.headlineMedium,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                "Minutes",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                "${state.currentStreak}",
                                style = MaterialTheme.typography.headlineMedium,
                                fontWeight = FontWeight.Bold,
                                color = MindLabsError
                            )
                            Text(
                                "Streak",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            }
        } ?: run {
            // Loading state
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
    }
    
    // Quest Selector Dialog
    if (showQuestSelector) {
        QuestSelectorDialog(
            quests = activeQuests,
            onDismiss = { showQuestSelector = false },
            onQuestSelected = { quest ->
                focusViewModel.selectQuest(quest)
                showQuestSelector = false
            }
        )
    }
    
    // Preset Selector Dialog
    if (showPresetSelector) {
        PresetSelectorDialog(
            onDismiss = { showPresetSelector = false },
            onPresetSelected = { minutes ->
                focusViewModel.setTimer(minutes)
                showPresetSelector = false
            }
        )
    }
}

@Composable
fun CircularTimer(
    progress: Float,
    timeRemaining: Int,
    isRunning: Boolean
) {
    val infiniteTransition = rememberInfiniteTransition(label = "timer")
    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(60000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )
    
    Box(contentAlignment = Alignment.Center) {
        Canvas(
            modifier = Modifier.fillMaxSize()
        ) {
            val strokeWidth = 12.dp.toPx()
            val radius = (size.minDimension - strokeWidth) / 2
            val center = Offset(size.width / 2, size.height / 2)
            
            // Background circle
            drawCircle(
                color = Color.Gray.copy(alpha = 0.2f),
                radius = radius,
                center = center,
                style = Stroke(strokeWidth, cap = StrokeCap.Round)
            )
            
            // Progress arc
            drawArc(
                color = MindLabsPurple,
                startAngle = -90f,
                sweepAngle = 360f * progress,
                useCenter = false,
                topLeft = Offset(center.x - radius, center.y - radius),
                size = Size(radius * 2, radius * 2),
                style = Stroke(strokeWidth, cap = StrokeCap.Round)
            )
            
            // Animated dots when running
            if (isRunning) {
                val dotCount = 8
                val dotRadius = 4.dp.toPx()
                
                for (i in 0 until dotCount) {
                    val angle = (rotation + i * (360f / dotCount)) * (PI / 180f).toFloat()
                    val dotX = center.x + (radius + 20.dp.toPx()) * cos(angle)
                    val dotY = center.y + (radius + 20.dp.toPx()) * sin(angle)
                    
                    drawCircle(
                        color = MindLabsPurple.copy(alpha = 0.3f),
                        radius = dotRadius,
                        center = Offset(dotX, dotY)
                    )
                }
            }
        }
        
        // Time Display
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            val minutes = timeRemaining / 60
            val seconds = timeRemaining % 60
            
            Text(
                text = String.format("%02d:%02d", minutes, seconds),
                style = MaterialTheme.typography.displayLarge,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
            
            if (isRunning) {
                Text(
                    "Focus Mode",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}

@Composable
fun TimerPresetChip(
    modifier: Modifier = Modifier,
    label: String,
    minutes: Int,
    onClick: () -> Unit
) {
    OutlinedCard(
        onClick = onClick,
        modifier = modifier,
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                label,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                "$minutes min",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuestSelectorDialog(
    quests: List<Quest>,
    onDismiss: () -> Unit,
    onQuestSelected: (Quest) -> Unit
) {
    Dialog(
        onDismissRequest = onDismiss
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.7f)
        ) {
            Column(
                modifier = Modifier.fillMaxSize()
            ) {
                Text(
                    "Select Quest",
                    style = MaterialTheme.typography.headlineSmall,
                    modifier = Modifier.padding(16.dp)
                )
                
                LazyColumn(
                    modifier = Modifier.weight(1f),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(quests) { quest ->
                        Card(
                            onClick = { 
                                onQuestSelected(quest)
                                onDismiss()
                            },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(quest.category.emoji, fontSize = 24.sp)
                                Spacer(modifier = Modifier.width(12.dp))
                                Column {
                                    Text(
                                        quest.title,
                                        style = MaterialTheme.typography.titleSmall
                                    )
                                    Text(
                                        "${quest.estimatedMinutes} min",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                        }
                    }
                }
                
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PresetSelectorDialog(
    onDismiss: () -> Unit,
    onPresetSelected: (Int) -> Unit
) {
    val presets = listOf(
        "Quick Focus" to 10,
        "Short Session" to 15,
        "Pomodoro" to 25,
        "Medium Session" to 30,
        "Long Focus" to 45,
        "Deep Work" to 60,
        "Extended Session" to 90
    )
    
    Dialog(
        onDismissRequest = onDismiss
    ) {
        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    "Timer Presets",
                    style = MaterialTheme.typography.headlineSmall,
                    modifier = Modifier.padding(16.dp)
                )
                
                Column(
                    modifier = Modifier.padding(horizontal = 16.dp)
                ) {
                    presets.forEach { (name, minutes) ->
                        Card(
                            onClick = { 
                                onPresetSelected(minutes)
                                onDismiss()
                            },
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(name, style = MaterialTheme.typography.titleSmall)
                                Text(
                                    "$minutes min",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.primary
                                )
                            }
                        }
                    }
                }
                
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}