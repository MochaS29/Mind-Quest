package com.mindlabs.quest.di

import android.content.Context
import androidx.room.Room
import com.mindlabs.quest.data.database.AchievementDao
import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.database.MindLabsQuestDatabase
import com.mindlabs.quest.data.database.QuestDao
import com.mindlabs.quest.data.database.ParentDao
import com.mindlabs.quest.data.database.RewardDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    
    @Provides
    @Singleton
    fun provideMindLabsQuestDatabase(
        @ApplicationContext context: Context
    ): MindLabsQuestDatabase {
        return Room.databaseBuilder(
            context,
            MindLabsQuestDatabase::class.java,
            "mindlabs_quest_database"
        ).fallbackToDestructiveMigration() // For development only
            .build()
    }
    
    @Provides
    fun provideCharacterDao(database: MindLabsQuestDatabase): CharacterDao {
        return database.characterDao()
    }
    
    @Provides
    fun provideQuestDao(database: MindLabsQuestDatabase): QuestDao {
        return database.questDao()
    }
    
    @Provides
    fun provideAchievementDao(database: MindLabsQuestDatabase): AchievementDao {
        return database.achievementDao()
    }
    
    @Provides
    fun provideParentDao(database: MindLabsQuestDatabase): ParentDao {
        return database.parentDao()
    }
    
    @Provides
    fun provideRewardDao(database: MindLabsQuestDatabase): RewardDao {
        return database.rewardDao()
    }
}