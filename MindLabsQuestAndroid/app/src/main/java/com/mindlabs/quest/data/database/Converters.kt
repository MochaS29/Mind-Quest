package com.mindlabs.quest.data.database

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.mindlabs.quest.data.models.*

class Converters {
    private val gson = Gson()

    @TypeConverter
    fun fromCharacterClass(value: CharacterClass?): String? = value?.name

    @TypeConverter
    fun toCharacterClass(value: String?): CharacterClass? = 
        value?.let { CharacterClass.valueOf(it) }

    @TypeConverter
    fun fromQuestCategory(value: QuestCategory): String = value.name

    @TypeConverter
    fun toQuestCategory(value: String): QuestCategory = QuestCategory.valueOf(value)

    @TypeConverter
    fun fromDifficulty(value: Difficulty): String = value.name

    @TypeConverter
    fun toDifficulty(value: String): Difficulty = Difficulty.valueOf(value)

    @TypeConverter
    fun fromRecurringType(value: RecurringType): String = value.name

    @TypeConverter
    fun toRecurringType(value: String): RecurringType = RecurringType.valueOf(value)

    @TypeConverter
    fun fromAchievementCategory(value: AchievementCategory): String = value.name

    @TypeConverter
    fun toAchievementCategory(value: String): AchievementCategory = AchievementCategory.valueOf(value)

    @TypeConverter
    fun fromFriendStatus(value: FriendStatus): String = value.name

    @TypeConverter
    fun toFriendStatus(value: String): FriendStatus = FriendStatus.valueOf(value)

    @TypeConverter
    fun fromRequestStatus(value: RequestStatus): String = value.name

    @TypeConverter
    fun toRequestStatus(value: String): RequestStatus = RequestStatus.valueOf(value)

    @TypeConverter
    fun fromActivityType(value: ActivityType): String = value.name

    @TypeConverter
    fun toActivityType(value: String): ActivityType = ActivityType.valueOf(value)

    @TypeConverter
    fun fromChallengeCategory(value: ChallengeCategory): String = value.name

    @TypeConverter
    fun toChallengeCategory(value: String): ChallengeCategory = ChallengeCategory.valueOf(value)

    @TypeConverter
    fun fromChallengeType(value: ChallengeType): String = value.name

    @TypeConverter
    fun toChallengeType(value: String): ChallengeType = ChallengeType.valueOf(value)
    
    @TypeConverter
    fun fromRewardCategory(value: RewardCategory): String = value.name
    
    @TypeConverter
    fun toRewardCategory(value: String): RewardCategory = RewardCategory.valueOf(value)

    @TypeConverter
    fun fromStringList(value: List<String>): String = gson.toJson(value)

    @TypeConverter
    fun toStringList(value: String): List<String> {
        val listType = object : TypeToken<List<String>>() {}.type
        return gson.fromJson(value, listType)
    }

    @TypeConverter
    fun fromSubtaskList(value: List<Subtask>): String = gson.toJson(value)

    @TypeConverter
    fun toSubtaskList(value: String): List<Subtask> {
        val listType = object : TypeToken<List<Subtask>>() {}.type
        return gson.fromJson(value, listType)
    }

    @TypeConverter
    fun fromFriendUser(value: FriendUser): String = gson.toJson(value)

    @TypeConverter
    fun toFriendUser(value: String): FriendUser = gson.fromJson(value, FriendUser::class.java)

    @TypeConverter
    fun fromChallengeParticipantList(value: List<ChallengeParticipant>): String = gson.toJson(value)

    @TypeConverter
    fun toChallengeParticipantList(value: String): List<ChallengeParticipant> {
        val listType = object : TypeToken<List<ChallengeParticipant>>() {}.type
        return gson.fromJson(value, listType)
    }

    @TypeConverter
    fun fromChallengeReward(value: ChallengeReward): String = gson.toJson(value)

    @TypeConverter
    fun toChallengeReward(value: String): ChallengeReward = gson.fromJson(value, ChallengeReward::class.java)

    @TypeConverter
    fun fromStringMap(value: Map<String, String>): String = gson.toJson(value)

    @TypeConverter
    fun toStringMap(value: String): Map<String, String> {
        val mapType = object : TypeToken<Map<String, String>>() {}.type
        return gson.fromJson(value, mapType)
    }
}