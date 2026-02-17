package com.mindlabs.quest.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = MindLabsPurple,
    onPrimary = Color.White,
    primaryContainer = MindLabsPurpleDark,
    onPrimaryContainer = Color.White,
    
    secondary = MindLabsTeal,
    onSecondary = Color.White,
    secondaryContainer = MindLabsTealDark,
    onSecondaryContainer = Color.White,
    
    tertiary = MindLabsBlue,
    onTertiary = Color.White,
    
    background = MindLabsBackgroundDark,
    onBackground = MindLabsTextDark,
    
    surface = MindLabsSurfaceDark,
    onSurface = MindLabsTextDark,
    surfaceVariant = MindLabsCardDark,
    onSurfaceVariant = MindLabsTextSecondaryDark,
    
    error = MindLabsError,
    onError = Color.White,
    
    outline = MindLabsBorderDark
)

private val LightColorScheme = lightColorScheme(
    primary = MindLabsPurple,
    onPrimary = Color.White,
    primaryContainer = MindLabsPurpleLight,
    onPrimaryContainer = MindLabsPurpleDark,
    
    secondary = MindLabsTeal,
    onSecondary = Color.White,
    secondaryContainer = MindLabsTealLight,
    onSecondaryContainer = MindLabsTealDark,
    
    tertiary = MindLabsBlue,
    onTertiary = Color.White,
    
    background = MindLabsBackground,
    onBackground = MindLabsText,
    
    surface = MindLabsSurface,
    onSurface = MindLabsText,
    surfaceVariant = MindLabsCard,
    onSurfaceVariant = MindLabsTextSecondary,
    
    error = MindLabsError,
    onError = Color.White,
    errorContainer = Color(0xFFFFEDED),
    onErrorContainer = MindLabsError,
    
    outline = MindLabsBorder
)

@Composable
fun MindLabsQuestTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Dynamic color is available on Android 12+
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}