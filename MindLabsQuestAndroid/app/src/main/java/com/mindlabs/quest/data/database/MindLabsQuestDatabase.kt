package com.mindlabs.quest.data.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.mindlabs.quest.data.models.*

@Database(
    entities = [
        Character::class,
        Quest::class,
        Achievement::class,
        Friend::class,
        FriendRequest::class,
        SharedActivity::class,
        CommunityChallenge::class,
        Parent::class,
        Reward::class
    ],
    version = 2,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class MindLabsQuestDatabase : RoomDatabase() {
    abstract fun characterDao(): CharacterDao
    abstract fun questDao(): QuestDao
    abstract fun achievementDao(): AchievementDao
    abstract fun parentDao(): ParentDao
    abstract fun rewardDao(): RewardDao
}