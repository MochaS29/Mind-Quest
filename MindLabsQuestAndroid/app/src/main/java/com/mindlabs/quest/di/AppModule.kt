package com.mindlabs.quest.di

import android.content.Context
import com.mindlabs.quest.data.database.AchievementDao
import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.database.QuestDao
import com.mindlabs.quest.data.repository.AchievementRepository
import com.mindlabs.quest.data.repository.FocusRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    
    @Provides
    @Singleton
    fun provideApplicationContext(@ApplicationContext context: Context): Context = context
    
    @Provides
    @Singleton
    fun provideAchievementRepository(
        achievementDao: AchievementDao
    ): AchievementRepository {
        return AchievementRepository(achievementDao)
    }
}