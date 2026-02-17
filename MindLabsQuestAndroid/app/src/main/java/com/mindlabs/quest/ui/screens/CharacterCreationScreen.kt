package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckBox
import androidx.compose.material.icons.filled.CheckBoxOutlineBlank
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.data.models.CharacterClass
import com.mindlabs.quest.data.models.Quest
import com.mindlabs.quest.data.models.QuestCategory
import com.mindlabs.quest.data.models.Difficulty
import com.mindlabs.quest.ui.theme.*
import com.mindlabs.quest.viewmodel.CharacterViewModel

enum class CreationStep {
    NAME_AND_CLASS,
    QUEST_SELECTION
}

data class QuestTemplate(
    val title: String,
    val description: String,
    val category: QuestCategory,
    val difficulty: Difficulty,
    val estimatedMinutes: Int,
    val xpReward: Int,
    val isDaily: Boolean = false
)

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun CharacterCreationScreen(
    onCharacterCreated: () -> Unit,
    characterViewModel: CharacterViewModel = hiltViewModel()
) {
    var currentStep by remember { mutableStateOf(CreationStep.NAME_AND_CLASS) }
    var characterName by remember { mutableStateOf("") }
    var selectedClass by remember { mutableStateOf<CharacterClass?>(null) }
    var selectedQuests by remember { mutableStateOf(setOf<QuestTemplate>()) }
    var showError by remember { mutableStateOf(false) }
    
    val questTemplates = remember { getQuestTemplates() }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Column(
            modifier = Modifier.fillMaxSize()
        ) {
            // Progress Indicator
            LinearProgressIndicator(
                progress = when (currentStep) {
                    CreationStep.NAME_AND_CLASS -> 0.5f
                    CreationStep.QUEST_SELECTION -> 1f
                },
                modifier = Modifier.fillMaxWidth(),
                color = MindLabsPurple
            )
            
            // Content
            AnimatedContent(
                targetState = currentStep,
                transitionSpec = {
                    if (targetState.ordinal > initialState.ordinal) {
                        slideInHorizontally { width -> width } + fadeIn() with
                        slideOutHorizontally { width -> -width } + fadeOut()
                    } else {
                        slideInHorizontally { width -> -width } + fadeIn() with
                        slideOutHorizontally { width -> width } + fadeOut()
                    }.using(SizeTransform(clip = false))
                },
                label = "step"
            ) { step ->
                when (step) {
                    CreationStep.NAME_AND_CLASS -> {
                        NameAndClassStep(
                            characterName = characterName,
                            selectedClass = selectedClass,
                            showError = showError,
                            onNameChange = { 
                                characterName = it
                                showError = false
                            },
                            onClassSelect = { 
                                selectedClass = it
                                showError = false
                            },
                            onNext = {
                                if (characterName.isNotEmpty() && selectedClass != null) {
                                    currentStep = CreationStep.QUEST_SELECTION
                                } else {
                                    showError = true
                                }
                            }
                        )
                    }
                    CreationStep.QUEST_SELECTION -> {
                        QuestSelectionStep(
                            questTemplates = questTemplates,
                            selectedQuests = selectedQuests,
                            onQuestToggle = { quest ->
                                selectedQuests = if (selectedQuests.contains(quest)) {
                                    selectedQuests - quest
                                } else {
                                    selectedQuests + quest
                                }
                            },
                            onBack = {
                                currentStep = CreationStep.NAME_AND_CLASS
                            },
                            onComplete = {
                                characterViewModel.createCharacterWithQuests(
                                    name = characterName,
                                    characterClass = selectedClass!!,
                                    selectedQuests = selectedQuests
                                )
                                onCharacterCreated()
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun NameAndClassStep(
    characterName: String,
    selectedClass: CharacterClass?,
    showError: Boolean,
    onNameChange: (String) -> Unit,
    onClassSelect: (CharacterClass) -> Unit,
    onNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header
        Text(
            text = "Create Your Hero",
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        
        Spacer(modifier = Modifier.height(8.dp))
        
        Text(
            text = "Begin your productivity adventure",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        // Character Name Input
        OutlinedTextField(
            value = characterName,
            onValueChange = onNameChange,
            label = { Text("Hero Name") },
            placeholder = { Text("Enter your hero's name") },
            isError = showError && characterName.isEmpty(),
            supportingText = if (showError && characterName.isEmpty()) {
                { Text("Please enter a name") }
            } else null,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp)
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        // Class Selection
        Text(
            text = "Choose Your Class",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.fillMaxWidth()
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        CharacterClass.values().forEach { characterClass ->
            ClassCard(
                characterClass = characterClass,
                isSelected = selectedClass == characterClass,
                onClick = { onClassSelect(characterClass) }
            )
            Spacer(modifier = Modifier.height(12.dp))
        }
        
        if (showError && selectedClass == null) {
            Text(
                text = "Please select a class",
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(top = 8.dp)
            )
        }
        
        Spacer(modifier = Modifier.height(32.dp))
        
        // Next Button
        Button(
            onClick = onNext,
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = MindLabsPurple
            )
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Choose Your Quests",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    imageVector = Icons.Default.ArrowForward,
                    contentDescription = null
                )
            }
        }
    }
}

@Composable
fun QuestSelectionStep(
    questTemplates: List<QuestTemplate>,
    selectedQuests: Set<QuestTemplate>,
    onQuestToggle: (QuestTemplate) -> Unit,
    onBack: () -> Unit,
    onComplete: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        // Header
        Column(
            modifier = Modifier.padding(24.dp)
        ) {
            Text(
                text = "Select Your Daily Quests",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Choose the quests that match your daily routine",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Selection counter
            Surface(
                shape = RoundedCornerShape(20.dp),
                color = MindLabsPurple.copy(alpha = 0.1f)
            ) {
                Text(
                    text = "${selectedQuests.size} quests selected",
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.labelLarge,
                    color = MindLabsPurple
                )
            }
        }
        
        // Quest List
        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Group quests by category
            val groupedQuests = questTemplates.groupBy { it.category }
            
            groupedQuests.forEach { (category, quests) ->
                item {
                    Text(
                        text = category.displayName,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )
                }
                
                items(quests) { quest ->
                    QuestSelectionCard(
                        quest = quest,
                        isSelected = selectedQuests.contains(quest),
                        onToggle = { onQuestToggle(quest) }
                    )
                }
                
                item {
                    Spacer(modifier = Modifier.height(16.dp))
                }
            }
        }
        
        // Action Buttons
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier.weight(1f).height(56.dp),
                shape = RoundedCornerShape(12.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = null
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Back")
            }
            
            Button(
                onClick = onComplete,
                modifier = Modifier.weight(1f).height(56.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MindLabsPurple
                ),
                enabled = selectedQuests.isNotEmpty()
            ) {
                Text(
                    text = "Begin Your Quest",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
fun QuestSelectionCard(
    quest: QuestTemplate,
    isSelected: Boolean,
    onToggle: () -> Unit
) {
    Card(
        onClick = onToggle,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) {
                MindLabsPurple.copy(alpha = 0.1f)
            } else {
                MaterialTheme.colorScheme.surface
            }
        ),
        border = if (isSelected) {
            BorderStroke(2.dp, MindLabsPurple)
        } else {
            BorderStroke(1.dp, MaterialTheme.colorScheme.outline)
        }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Checkbox
            Icon(
                imageVector = if (isSelected) Icons.Default.CheckBox else Icons.Default.CheckBoxOutlineBlank,
                contentDescription = null,
                tint = if (isSelected) MindLabsPurple else MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(24.dp)
            )
            
            Spacer(modifier = Modifier.width(12.dp))
            
            // Quest Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = quest.title,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Medium
                )
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Text(
                    text = quest.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Row(
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Difficulty
                    Surface(
                        shape = RoundedCornerShape(4.dp),
                        color = getDifficultyColor(quest.difficulty).copy(alpha = 0.1f)
                    ) {
                        Text(
                            text = quest.difficulty.displayName,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
                            style = MaterialTheme.typography.labelSmall,
                            color = getDifficultyColor(quest.difficulty)
                        )
                    }
                    
                    // Time
                    Text(
                        text = "${quest.estimatedMinutes} min",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    
                    // XP
                    Text(
                        text = "${quest.xpReward} XP",
                        style = MaterialTheme.typography.labelSmall,
                        color = MindLabsPurple,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }
    }
}

@Composable
fun ClassCard(
    characterClass: CharacterClass,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val borderColor = when (characterClass) {
        CharacterClass.WARRIOR -> WarriorColor
        CharacterClass.SCHOLAR -> ScholarColor
        CharacterClass.RANGER -> RangerColor
        CharacterClass.HEALER -> HealerColor
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .border(
                width = if (isSelected) 3.dp else 1.dp,
                color = if (isSelected) borderColor else MaterialTheme.colorScheme.outline,
                shape = RoundedCornerShape(16.dp)
            )
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) {
                borderColor.copy(alpha = 0.1f)
            } else {
                MaterialTheme.colorScheme.surface
            }
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Class Emoji
            Text(
                text = characterClass.emoji,
                fontSize = 48.sp,
                modifier = Modifier.padding(end = 16.dp)
            )
            
            // Class Info
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = characterClass.displayName,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = characterClass.description,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            // Selection Indicator
            if (isSelected) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = "Selected",
                    tint = borderColor,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

private fun getDifficultyColor(difficulty: Difficulty): androidx.compose.ui.graphics.Color {
    return when (difficulty) {
        Difficulty.EASY -> MindLabsSuccess
        Difficulty.MEDIUM -> MindLabsWarning
        Difficulty.HARD -> MindLabsError
        Difficulty.LEGENDARY -> MindLabsPurple
    }
}

private fun getQuestTemplates(): List<QuestTemplate> {
    return listOf(
        // Morning Hygiene & Preparation
        QuestTemplate(
            title = "The Cleansing Ritual of Dawn",
            description = "Morning Shower - Start your day with refreshing cleanliness",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 10,
            xpReward = 50,
            isDaily = true
        ),
        QuestTemplate(
            title = "Defend the Ivory Gates",
            description = "Brush Teeth (Morning) - Protect your smile from cavity invaders",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 3,
            xpReward = 30,
            isDaily = true
        ),
        QuestTemplate(
            title = "Thread the Needle of Dental Excellence",
            description = "Floss Teeth - Master the art of deep dental defense",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 2,
            xpReward = 25,
            isDaily = true
        ),
        QuestTemplate(
            title = "Tame the Wild Mane",
            description = "Brush/Style Hair - Transform chaos into order atop your crown",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 5,
            xpReward = 30,
            isDaily = true
        ),
        QuestTemplate(
            title = "The Nighttime Dental Defense",
            description = "Brush Teeth (Night) - End the day with protective oral magic",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 3,
            xpReward = 30,
            isDaily = true
        ),
        
        // School Preparation
        QuestTemplate(
            title = "Prepare the Adventurer's Feast",
            description = "Pack Lunch - Gather sustenance for your daily quest",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 10,
            xpReward = 40,
            isDaily = true
        ),
        QuestTemplate(
            title = "Secure the Sacred Scrolls",
            description = "Pack Homework - Ensure all completed quests are ready for submission",
            category = QuestCategory.WORK,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 5,
            xpReward = 35,
            isDaily = true
        ),
        QuestTemplate(
            title = "Ready the Explorer's Arsenal",
            description = "Pack Backpack - Prepare your inventory for the day's adventures",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 5,
            xpReward = 35,
            isDaily = true
        ),
        
        // Academic Quests
        QuestTemplate(
            title = "Conquer the Academic Challenges",
            description = "Complete Homework - Face your assigned trials with courage",
            category = QuestCategory.WORK,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 45,
            xpReward = 150,
            isDaily = true
        ),
        QuestTemplate(
            title = "Delve into the Tomes of Knowledge",
            description = "Study Session - Absorb wisdom from ancient texts",
            category = QuestCategory.WORK,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 30,
            xpReward = 120,
            isDaily = true
        ),
        QuestTemplate(
            title = "Journey Through Literary Realms",
            description = "Read for 20 Minutes - Explore new worlds through written word",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 20,
            xpReward = 80,
            isDaily = true
        ),
        QuestTemplate(
            title = "Forge Knowledge in the Crucible of Study",
            description = "Study for Test/Quiz - Prepare for upcoming knowledge trials",
            category = QuestCategory.WORK,
            difficulty = Difficulty.HARD,
            estimatedMinutes = 60,
            xpReward = 200,
            isDaily = false
        ),
        QuestTemplate(
            title = "Face the Trial of Knowledge",
            description = "Complete Quiz/Test - Demonstrate your accumulated wisdom",
            category = QuestCategory.WORK,
            difficulty = Difficulty.HARD,
            estimatedMinutes = 60,
            xpReward = 250,
            isDaily = false
        ),
        QuestTemplate(
            title = "Decipher the Ancient Scrolls",
            description = "Review Class Notes - Study the wisdom recorded in your chronicles",
            category = QuestCategory.WORK,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 15,
            xpReward = 60,
            isDaily = true
        ),
        
        // Physical Activity
        QuestTemplate(
            title = "Train at the Dawn Dojo",
            description = "Morning Exercise - Strengthen your warrior's body",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 20,
            xpReward = 100,
            isDaily = true
        ),
        QuestTemplate(
            title = "Master the Art of Flexibility",
            description = "Stretching Routine - Enhance your agility and grace",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 10,
            xpReward = 50,
            isDaily = true
        ),
        QuestTemplate(
            title = "Venture into the Wild",
            description = "30 Min Outdoor Activity - Explore the realm beyond your walls",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 30,
            xpReward = 120,
            isDaily = true
        ),
        QuestTemplate(
            title = "Dance with the Energy Dragons",
            description = "5-Minute Movement Break - Release restless energy through motion",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 5,
            xpReward = 30,
            isDaily = true
        ),
        
        // Life Skills & Chores
        QuestTemplate(
            title = "Restore Order to Your Sanctuary",
            description = "Tidy Room - Transform chaos into a peaceful haven",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 20,
            xpReward = 80,
            isDaily = true
        ),
        QuestTemplate(
            title = "Craft the Perfect Resting Chamber",
            description = "Make Bed - Create an inviting sanctuary for future rest",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 5,
            xpReward = 30,
            isDaily = true
        ),
        QuestTemplate(
            title = "Master Your Command Center",
            description = "Organize Desk/Workspace - Create order in your productivity realm",
            category = QuestCategory.WORK,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 15,
            xpReward = 70,
            isDaily = false
        ),
        
        // Evening Routines
        QuestTemplate(
            title = "Plan Tomorrow's Campaign",
            description = "Prepare for Tomorrow - Map out your future adventures",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 10,
            xpReward = 50,
            isDaily = true
        ),
        QuestTemplate(
            title = "Meditate on Today's Adventures",
            description = "Evening Reflection/Journal - Record your daily victories and lessons",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 10,
            xpReward = 60,
            isDaily = true
        ),
        
        // Social & Creative
        QuestTemplate(
            title = "Aid Your Fellow Adventurers",
            description = "Help Family Member - Strengthen bonds through acts of service",
            category = QuestCategory.SOCIAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 15,
            xpReward = 70,
            isDaily = false
        ),
        QuestTemplate(
            title = "Channel Your Creative Energy",
            description = "Creative Activity (Draw/Music/Write) - Express your inner artist",
            category = QuestCategory.CREATIVE,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 30,
            xpReward = 100,
            isDaily = false
        ),
        QuestTemplate(
            title = "Hone Your Chosen Craft",
            description = "Practice Instrument/Skill - Level up your special abilities",
            category = QuestCategory.CREATIVE,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 30,
            xpReward = 120,
            isDaily = false
        ),
        QuestTemplate(
            title = "Venture Into the Unknown",
            description = "Try a New Activity - Expand your realm of experience",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 30,
            xpReward = 150,
            isDaily = false
        ),
        QuestTemplate(
            title = "Gather with the Alliance",
            description = "Attend Club/Group Meeting - Join your fellow adventurers",
            category = QuestCategory.SOCIAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 60,
            xpReward = 100,
            isDaily = false
        ),
        QuestTemplate(
            title = "Forge New Alliances",
            description = "Talk to Someone New - Expand your network of allies",
            category = QuestCategory.SOCIAL,
            difficulty = Difficulty.HARD,
            estimatedMinutes = 10,
            xpReward = 100,
            isDaily = false
        ),
        
        // Focus & Organization
        QuestTemplate(
            title = "Chart the Path of Destiny",
            description = "Update Planner/Calendar - Map your future conquests",
            category = QuestCategory.WORK,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 10,
            xpReward = 50,
            isDaily = true
        ),
        QuestTemplate(
            title = "Divide and Conquer the Mountain",
            description = "Break Big Task into Steps - Transform overwhelming quests into manageable victories",
            category = QuestCategory.WORK,
            difficulty = Difficulty.MEDIUM,
            estimatedMinutes = 15,
            xpReward = 80,
            isDaily = false
        ),
        
        // Emotional Regulation
        QuestTemplate(
            title = "Commune with the Inner Spirit",
            description = "5-Minute Mindfulness - Find peace in the present moment",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 5,
            xpReward = 40,
            isDaily = true
        ),
        QuestTemplate(
            title = "Chronicle the Emotional Journey",
            description = "Journal Thoughts/Feelings - Record your inner adventures",
            category = QuestCategory.PERSONAL,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 15,
            xpReward = 70,
            isDaily = true
        ),
        QuestTemplate(
            title = "Summon the Wisdom of Allies",
            description = "Ask for Help When Needed - Recognize when to call upon your support network",
            category = QuestCategory.SOCIAL,
            difficulty = Difficulty.HARD,
            estimatedMinutes = 10,
            xpReward = 100,
            isDaily = false
        ),
        QuestTemplate(
            title = "Channel the Restless Energy",
            description = "Use Fidget Tool During Task - Transform nervous energy into focused power",
            category = QuestCategory.HEALTH,
            difficulty = Difficulty.EASY,
            estimatedMinutes = 30,
            xpReward = 60,
            isDaily = false
        )
    )
}