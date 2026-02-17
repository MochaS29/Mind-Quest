package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindlabs.quest.ui.components.MindLabsCard
import com.mindlabs.quest.viewmodel.SettingsViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    settingsViewModel: SettingsViewModel = hiltViewModel(),
    onNavigateToCalendar: () -> Unit = {},
    onNavigateToNotifications: () -> Unit = {},
    onNavigateToCustomization: () -> Unit = {},
    onNavigateToExport: () -> Unit = {},
    onNavigateToSupport: () -> Unit = {},
    onNavigateToAbout: () -> Unit = {}
) {
    val settings by settingsViewModel.settings.collectAsState(initial = null)
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    
    var showResetDialog by remember { mutableStateOf(false) }
    var showLogoutDialog by remember { mutableStateOf(false) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") }
            )
        }
    ) { paddingValues ->
        settings?.let { currentSettings ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .verticalScroll(rememberScrollState())
            ) {
            // General Settings
            SettingsSection(title = "General") {
                SettingsItem(
                    icon = Icons.Default.DarkMode,
                    title = "Dark Mode",
                    subtitle = "Use dark theme",
                    trailing = {
                        Switch(
                            checked = currentSettings.isDarkMode,
                            onCheckedChange = { settingsViewModel.toggleDarkMode() }
                        )
                    }
                )
                
                SettingsItem(
                    icon = Icons.Default.Animation,
                    title = "Animations",
                    subtitle = "Enable UI animations",
                    trailing = {
                        Switch(
                            checked = currentSettings.animationsEnabled,
                            onCheckedChange = { settingsViewModel.toggleAnimations() }
                        )
                    }
                )
                
                SettingsItem(
                    icon = Icons.Default.Vibration,
                    title = "Haptic Feedback",
                    subtitle = "Vibrate on interactions",
                    trailing = {
                        Switch(
                            checked = currentSettings.hapticFeedback,
                            onCheckedChange = { settingsViewModel.toggleHapticFeedback() }
                        )
                    }
                )
            }
            
            // Productivity Settings
            SettingsSection(title = "Productivity") {
                SettingsItem(
                    icon = Icons.Default.Timer,
                    title = "Default Timer Duration",
                    subtitle = "${currentSettings.defaultTimerMinutes} minutes",
                    onClick = { /* TODO: Show timer duration picker */ }
                )
                
                SettingsItem(
                    icon = Icons.Default.NotificationsActive,
                    title = "Break Reminders",
                    subtitle = if (currentSettings.breakRemindersEnabled) "Every ${currentSettings.breakIntervalMinutes} minutes" else "Disabled",
                    trailing = {
                        Switch(
                            checked = currentSettings.breakRemindersEnabled,
                            onCheckedChange = { settingsViewModel.toggleBreakReminders() }
                        )
                    }
                )
                
                SettingsItem(
                    icon = Icons.Default.DoNotDisturb,
                    title = "Focus Mode",
                    subtitle = "Block notifications during focus sessions",
                    trailing = {
                        Switch(
                            checked = currentSettings.focusModeEnabled,
                            onCheckedChange = { settingsViewModel.toggleFocusMode() }
                        )
                    }
                )
            }
            
            // App Features
            SettingsSection(title = "Features") {
                SettingsItem(
                    icon = Icons.Default.CalendarMonth,
                    title = "Calendar Integration",
                    subtitle = "Sync with device calendar",
                    onClick = onNavigateToCalendar
                )
                
                SettingsItem(
                    icon = Icons.Default.Notifications,
                    title = "Notifications",
                    subtitle = "Manage notification preferences",
                    onClick = onNavigateToNotifications
                )
                
                SettingsItem(
                    icon = Icons.Default.Palette,
                    title = "Customization",
                    subtitle = "Themes and appearance",
                    onClick = onNavigateToCustomization
                )
            }
            
            // Data & Privacy
            SettingsSection(title = "Data & Privacy") {
                SettingsItem(
                    icon = Icons.Default.Download,
                    title = "Export Data",
                    subtitle = "Download your data",
                    onClick = onNavigateToExport
                )
                
                SettingsItem(
                    icon = Icons.Default.CloudSync,
                    title = "Backup & Sync",
                    subtitle = if (currentSettings.cloudSyncEnabled) "Enabled" else "Disabled",
                    trailing = {
                        Switch(
                            checked = currentSettings.cloudSyncEnabled,
                            onCheckedChange = { settingsViewModel.toggleCloudSync() }
                        )
                    }
                )
                
                SettingsItem(
                    icon = Icons.Default.Analytics,
                    title = "Usage Analytics",
                    subtitle = "Help improve the app",
                    trailing = {
                        Switch(
                            checked = currentSettings.analyticsEnabled,
                            onCheckedChange = { settingsViewModel.toggleAnalytics() }
                        )
                    }
                )
            }
            
            // Support
            SettingsSection(title = "Support") {
                SettingsItem(
                    icon = Icons.Default.Help,
                    title = "Help & FAQ",
                    subtitle = "Get answers to common questions",
                    onClick = onNavigateToSupport
                )
                
                SettingsItem(
                    icon = Icons.Default.Feedback,
                    title = "Send Feedback",
                    subtitle = "Share your thoughts",
                    onClick = { /* TODO: Open feedback form */ }
                )
                
                SettingsItem(
                    icon = Icons.Default.BugReport,
                    title = "Report a Bug",
                    subtitle = "Help us fix issues",
                    onClick = { /* TODO: Open bug report */ }
                )
            }
            
            // About
            SettingsSection(title = "About") {
                SettingsItem(
                    icon = Icons.Default.Info,
                    title = "About MindLabs Quest",
                    subtitle = "Version 1.0.0",
                    onClick = onNavigateToAbout
                )
                
                SettingsItem(
                    icon = Icons.Default.Policy,
                    title = "Privacy Policy",
                    subtitle = "How we handle your data",
                    onClick = { /* TODO: Open privacy policy */ }
                )
                
                SettingsItem(
                    icon = Icons.Default.Article,
                    title = "Terms of Service",
                    subtitle = "Terms and conditions",
                    onClick = { /* TODO: Open terms */ }
                )
            }
            
            // Danger Zone
            SettingsSection(title = "Account") {
                SettingsItem(
                    icon = Icons.Default.RestartAlt,
                    title = "Reset Progress",
                    subtitle = "Clear all data and start over",
                    titleColor = MaterialTheme.colorScheme.error,
                    onClick = { showResetDialog = true }
                )
                
                SettingsItem(
                    icon = Icons.Default.Logout,
                    title = "Log Out",
                    subtitle = "Sign out of your account",
                    onClick = { showLogoutDialog = true }
                )
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
    
    // Reset Progress Dialog
    if (showResetDialog) {
        AlertDialog(
            onDismissRequest = { showResetDialog = false },
            icon = { Icon(Icons.Default.Warning, contentDescription = null) },
            title = { Text("Reset All Progress?") },
            text = {
                Text("This will permanently delete all your quests, achievements, and character data. This action cannot be undone.")
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        coroutineScope.launch {
                            settingsViewModel.resetAllData()
                            showResetDialog = false
                            // After reset, the app should automatically navigate to character creation
                            // This will happen because the character will be null
                        }
                    },
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Reset Everything")
                }
            },
            dismissButton = {
                TextButton(onClick = { showResetDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
    
    // Logout Dialog
    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            title = { Text("Log Out?") },
            text = { Text("Are you sure you want to log out?") },
            confirmButton = {
                TextButton(
                    onClick = {
                        // TODO: Implement logout
                        showLogoutDialog = false
                    }
                ) {
                    Text("Log Out")
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
fun SettingsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
        )
        
        MindLabsCard(
            modifier = Modifier.padding(horizontal = 16.dp)
        ) {
            Column(content = content)
        }
        
        Spacer(modifier = Modifier.height(16.dp))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsItem(
    icon: ImageVector,
    title: String,
    subtitle: String? = null,
    titleColor: androidx.compose.ui.graphics.Color = MaterialTheme.colorScheme.onSurface,
    trailing: @Composable (() -> Unit)? = null,
    onClick: (() -> Unit)? = null
) {
    val modifier = if (onClick != null) {
        Modifier
            .fillMaxWidth()
            .clickable { onClick() }
    } else {
        Modifier.fillMaxWidth()
    }
    
    Row(
        modifier = modifier.padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(24.dp)
        )
        
        Spacer(modifier = Modifier.width(16.dp))
        
        Column(
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge,
                color = titleColor
            )
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
        
        if (trailing != null) {
            trailing()
        } else if (onClick != null) {
            Icon(
                imageVector = Icons.Default.ChevronRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}