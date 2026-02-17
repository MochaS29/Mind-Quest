package com.mindlabs.quest.ui.screens

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    val navController = rememberNavController()
    
    Scaffold(
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination
                
                bottomNavItems.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label) },
                        selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = BottomNavScreen.Dashboard.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(BottomNavScreen.Dashboard.route) {
                DashboardScreen(
                    onNavigateToQuests = {
                        navController.navigate(BottomNavScreen.Quests.route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                    onNavigateToTimer = {
                        navController.navigate(BottomNavScreen.Timer.route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                    onNavigateToCreateQuest = {
                        navController.navigate(BottomNavScreen.Quests.route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
            composable(BottomNavScreen.Quests.route) {
                QuestsScreen()
            }
            composable(BottomNavScreen.Timer.route) {
                TimerScreen()
            }
            composable(BottomNavScreen.Character.route) {
                CharacterScreen(
                    onNavigateToSettings = {
                        navController.navigate(BottomNavScreen.Settings.route)
                    }
                )
            }
            composable(BottomNavScreen.Social.route) {
                SocialScreen()
            }
            composable(BottomNavScreen.Settings.route) {
                SettingsScreen(
                    onNavigateToCalendar = {
                        // For now, just show a toast or log
                        // TODO: Implement calendar integration screen
                    },
                    onNavigateToNotifications = {
                        // TODO: Implement notifications screen
                    },
                    onNavigateToCustomization = {
                        // TODO: Implement customization screen
                    },
                    onNavigateToExport = {
                        // TODO: Implement export screen
                    },
                    onNavigateToSupport = {
                        // TODO: Implement support screen
                    },
                    onNavigateToAbout = {
                        // TODO: Implement about screen
                    }
                )
            }
        }
    }
}

sealed class BottomNavScreen(
    val route: String,
    val label: String,
    val icon: ImageVector
) {
    object Dashboard : BottomNavScreen("dashboard", "Home", Icons.Default.Home)
    object Quests : BottomNavScreen("quests", "Quests", Icons.Default.Task)
    object Timer : BottomNavScreen("timer", "Focus", Icons.Default.Timer)
    object Character : BottomNavScreen("character", "Profile", Icons.Default.Person)
    object Social : BottomNavScreen("social", "Social", Icons.Default.Groups)
    object Settings : BottomNavScreen("settings", "Settings", Icons.Default.Settings)
}

val bottomNavItems = listOf(
    BottomNavScreen.Dashboard,
    BottomNavScreen.Quests,
    BottomNavScreen.Timer,
    BottomNavScreen.Character,
    BottomNavScreen.Social
)