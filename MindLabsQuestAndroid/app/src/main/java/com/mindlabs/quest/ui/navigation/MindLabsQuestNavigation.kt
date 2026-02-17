package com.mindlabs.quest.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.mindlabs.quest.ui.screens.CharacterCreationScreen
import com.mindlabs.quest.ui.screens.MainScreen
import com.mindlabs.quest.ui.screens.SplashScreen
import com.mindlabs.quest.viewmodel.CharacterViewModel

@Composable
fun MindLabsQuestNavigation(
    navController: NavHostController = rememberNavController()
) {
    val characterViewModel: CharacterViewModel = hiltViewModel()
    val character by characterViewModel.character.collectAsState()
    
    NavHost(
        navController = navController,
        startDestination = Screen.Splash.route
    ) {
        composable(Screen.Splash.route) {
            SplashScreen(
                onNavigate = {
                    if (character == null || character?.name?.isEmpty() == true) {
                        navController.navigate(Screen.CharacterCreation.route) {
                            popUpTo(Screen.Splash.route) { inclusive = true }
                        }
                    } else {
                        navController.navigate(Screen.Main.route) {
                            popUpTo(Screen.Splash.route) { inclusive = true }
                        }
                    }
                }
            )
        }
        
        composable(Screen.CharacterCreation.route) {
            CharacterCreationScreen(
                onCharacterCreated = {
                    navController.navigate(Screen.Main.route) {
                        popUpTo(Screen.CharacterCreation.route) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Screen.Main.route) {
            MainScreen()
        }
    }
}

sealed class Screen(val route: String) {
    object Splash : Screen("splash")
    object CharacterCreation : Screen("character_creation")
    object Main : Screen("main")
    object QuestDetail : Screen("quest_detail/{questId}") {
        fun createRoute(questId: String) = "quest_detail/$questId"
    }
    object Timer : Screen("timer/{questId}") {
        fun createRoute(questId: String) = "timer/$questId"
    }
}