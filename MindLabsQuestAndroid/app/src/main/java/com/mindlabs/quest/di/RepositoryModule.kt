package com.mindlabs.quest.di

import com.mindlabs.quest.data.database.CharacterDao
import com.mindlabs.quest.data.database.QuestDao
import com.mindlabs.quest.data.repository.CharacterRepository
import com.mindlabs.quest.data.repository.FocusRepository
import com.mindlabs.quest.data.repository.QuestRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {
    
    @Provides
    @Singleton
    fun provideCharacterRepository(
        characterDao: CharacterDao
    ): CharacterRepository {
        return CharacterRepository(characterDao)
    }
    
    @Provides
    @Singleton
    fun provideQuestRepository(
        questDao: QuestDao
    ): QuestRepository {
        return QuestRepository(questDao)
    }
    
    @Provides
    @Singleton
    fun provideFocusRepository(
        questDao: QuestDao,
        characterDao: CharacterDao
    ): FocusRepository {
        return FocusRepository(questDao, characterDao)
    }
}