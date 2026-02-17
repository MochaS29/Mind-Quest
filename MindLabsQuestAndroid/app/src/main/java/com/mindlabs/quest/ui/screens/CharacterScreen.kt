package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.data.models.CharacterClass
import com.mindlabs.quest.ui.components.MindLabsCard
import com.mindlabs.quest.ui.components.StatCard
import com.mindlabs.quest.ui.theme.*
import com.mindlabs.quest.viewmodel.CharacterViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CharacterScreen(
    characterViewModel: CharacterViewModel = hiltViewModel(),
    onNavigateToSettings: () -> Unit = {}
) {
    val character by characterViewModel.character.collectAsState(initial = null)
    
    character?.let { char ->
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Character Profile") },
                    actions = {
                        IconButton(onClick = onNavigateToSettings) {
                            Icon(Icons.Default.Settings, contentDescription = "Settings")
                        }
                    }
                )
            }
        ) { paddingValues ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Character Info Card
                MindLabsCard {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        // Character Avatar
                        Box(
                            contentAlignment = Alignment.Center,
                            modifier = Modifier
                                .size(120.dp)
                                .clip(CircleShape)
                                .background(
                                    when (char.characterClass) {
                                        CharacterClass.WARRIOR -> WarriorColor
                                        CharacterClass.SCHOLAR -> ScholarColor
                                        CharacterClass.RANGER -> RangerColor
                                        CharacterClass.HEALER -> HealerColor
                                        null -> MaterialTheme.colorScheme.primary
                                    }.copy(alpha = 0.2f)
                                )
                        ) {
                            Text(
                                text = char.characterClass?.emoji ?: "🎮",
                                fontSize = 60.sp
                            )
                        }
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        // Character Name with Title
                        Text(
                            text = char.displayName,
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold
                        )
                        
                        // Character Class
                        char.characterClass?.let { charClass ->
                            Text(
                                text = charClass.displayName,
                                style = MaterialTheme.typography.titleMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        
                        Spacer(modifier = Modifier.height(24.dp))
                        
                        // Level Progress
                        Column(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.Bottom
                            ) {
                                Text(
                                    text = "Level ${char.level}",
                                    style = MaterialTheme.typography.titleLarge,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(
                                    text = "Level ${char.level + 1}",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                            
                            Spacer(modifier = Modifier.height(8.dp))
                            
                            // XP Progress Bar
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(24.dp)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(MaterialTheme.colorScheme.surfaceVariant)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth(char.xpProgress)
                                        .fillMaxHeight()
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(MindLabsPurple)
                                )
                                
                                Text(
                                    text = "${char.xp} / ${char.xpForNextLevel} XP",
                                    style = MaterialTheme.typography.labelMedium,
                                    color = Color.White,
                                    modifier = Modifier.align(Alignment.Center)
                                )
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(24.dp))
                        
                        // Health and Energy Bars
                        HealthEnergyBars(
                            hp = char.hp,
                            maxHp = char.maxHp,
                            energy = char.energy,
                            maxEnergy = char.maxEnergy
                        )
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                // Stats Grid
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    StatCard(
                        modifier = Modifier.weight(1f),
                        title = "Streak",
                        value = "${char.streak} days",
                        icon = Icons.Default.LocalFireDepartment,
                        color = MindLabsError
                    )
                    StatCard(
                        modifier = Modifier.weight(1f),
                        title = "Best Streak",
                        value = "${char.longestStreak} days",
                        icon = Icons.Default.EmojiEvents,
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
                        value = "${char.totalQuestsCompleted}",
                        icon = Icons.Default.CheckCircle,
                        color = MindLabsSuccess
                    )
                    StatCard(
                        modifier = Modifier.weight(1f),
                        title = "Focus Time",
                        value = "${char.totalFocusMinutes / 60}h",
                        icon = Icons.Default.Timer,
                        color = MindLabsBlue
                    )
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                // Achievements Preview
                MindLabsCard {
                    Column {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Recent Achievements",
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.SemiBold
                            )
                            TextButton(onClick = { /* TODO: Navigate to achievements */ }) {
                                Text("See All")
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        // Achievement badges placeholder
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            AchievementBadge("🏆", "First Quest")
                            AchievementBadge("🔥", "7 Day Streak")
                            AchievementBadge("⭐", "Level 5")
                            AchievementBadge("🎯", "Focus Master")
                        }
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                // Character Stats
                MindLabsCard {
                    Column {
                        Text(
                            text = "Character Stats",
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.SemiBold
                        )
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        CharacterStatRow("Member Since", formatDate(char.joinedDate))
                        CharacterStatRow("Total XP Earned", "${char.xp + (char.level - 1) * 100}")
                        CharacterStatRow("Average Daily Quests", "3.5")
                        CharacterStatRow("Favorite Category", "Work")
                        CharacterStatRow("Completion Rate", "78%")
                    }
                }
            }
        }
    } ?: run {
        // Loading or no character state
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
    }
}

@Composable
fun HealthEnergyBars(
    hp: Int,
    maxHp: Int,
    energy: Int,
    maxEnergy: Int
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // HP Bar
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.Favorite,
                        contentDescription = null,
                        tint = Color.Red,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "HP",
                        style = MaterialTheme.typography.labelMedium
                    )
                }
                Text(
                    text = "$hp / $maxHp",
                    style = MaterialTheme.typography.labelMedium
                )
            }
            
            LinearProgressIndicator(
                progress = hp.toFloat() / maxHp.toFloat(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = Color.Red,
                trackColor = Color.Red.copy(alpha = 0.2f)
            )
        }
        
        // Energy Bar
        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.Bolt,
                        contentDescription = null,
                        tint = MindLabsWarning,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "Energy",
                        style = MaterialTheme.typography.labelMedium
                    )
                }
                Text(
                    text = "$energy / $maxEnergy",
                    style = MaterialTheme.typography.labelMedium
                )
            }
            
            LinearProgressIndicator(
                progress = energy.toFloat() / maxEnergy.toFloat(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = MindLabsWarning,
                trackColor = MindLabsWarning.copy(alpha = 0.2f)
            )
        }
    }
}

@Composable
fun AchievementBadge(
    emoji: String,
    title: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Surface(
            shape = CircleShape,
            color = MaterialTheme.colorScheme.surfaceVariant,
            modifier = Modifier.size(60.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.fillMaxSize()
            ) {
                Text(
                    text = emoji,
                    fontSize = 28.sp
                )
            }
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = title,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun CharacterStatRow(
    label: String,
    value: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
    }
}

private fun formatDate(timestamp: Long): String {
    val formatter = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
    return formatter.format(Date(timestamp))
}