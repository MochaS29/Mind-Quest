import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Modal,
  Platform,
  StatusBar,
  SafeAreaView,
  Dimensions,
  Alert
} from 'react-native';
import { Ionicons, MaterialIcons, FontAwesome5, MaterialCommunityIcons } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';

const { width, height } = Dimensions.get('window');

export default function App() {
  const [currentView, setCurrentView] = useState('character-creation');
  const [characterCreated, setCharacterCreated] = useState(false);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [currentTime, setCurrentTime] = useState(new Date());
  const [activeTimer, setActiveTimer] = useState(null);
  const [timerRunning, setTimerRunning] = useState(false);
  const [timerTime, setTimerTime] = useState(0);
  const [showNewTaskModal, setShowNewTaskModal] = useState(false);
  const [showSettingsModal, setShowSettingsModal] = useState(false);

  // D&D Classes with their bonuses
  const characterClasses = {
    scholar: {
      name: "Scholar",
      description: "Master of knowledge and learning",
      icon: "📚",
      primaryStat: "intelligence",
      bonuses: { intelligence: 3, wisdom: 2, charisma: 1 },
      abilities: ["Double XP from academic tasks", "Unlock advanced study techniques", "Research mastery"]
    },
    warrior: {
      name: "Warrior",
      description: "Champion of physical prowess",
      icon: "⚔️",
      primaryStat: "strength",
      bonuses: { strength: 3, constitution: 2, dexterity: 1 },
      abilities: ["Double XP from fitness tasks", "Endurance boost", "Athletic excellence"]
    },
    diplomat: {
      name: "Diplomat",
      description: "Expert in social connections",
      icon: "🤝",
      primaryStat: "charisma",
      bonuses: { charisma: 3, wisdom: 2, intelligence: 1 },
      abilities: ["Double XP from social tasks", "Leadership skills", "Communication mastery"]
    },
    ranger: {
      name: "Ranger",
      description: "Balanced adventurer and survivalist",
      icon: "🏹",
      primaryStat: "dexterity",
      bonuses: { dexterity: 2, strength: 2, wisdom: 2 },
      abilities: ["Balanced XP from all activities", "Adaptability", "Nature connection"]
    },
    artificer: {
      name: "Artificer",
      description: "Creative maker and innovator",
      icon: "🔧",
      primaryStat: "intelligence",
      bonuses: { intelligence: 2, dexterity: 2, constitution: 2 },
      abilities: ["Double XP from creative tasks", "Innovation bonus", "Problem-solving mastery"]
    },
    cleric: {
      name: "Cleric",
      description: "Healer and wellness guardian",
      icon: "✨",
      primaryStat: "wisdom",
      bonuses: { wisdom: 3, constitution: 2, charisma: 1 },
      abilities: ["Double XP from health tasks", "Mental wellness boost", "Healing abilities"]
    }
  };

  // Character stats (D&D style)
  const [character, setCharacter] = useState({
    name: "",
    class: "",
    level: 1,
    xp: 0,
    xpToNext: 100,
    stats: {
      strength: 10,
      dexterity: 10,
      constitution: 10,
      intelligence: 10,
      wisdom: 10,
      charisma: 10
    },
    health: 100,
    maxHealth: 100,
    gold: 100,
    streak: 0,
    avatar: "🧙‍♂️",
    background: "",
    equipment: {
      weapon: "Basic Focus Blade",
      armor: "Student Robes",
      accessory: "Clarity Amulet"
    },
    companions: [],
    currentCompanion: null
  });

  // Available backgrounds
  const backgrounds = {
    student: {
      name: "Student",
      description: "Academic life is your main quest",
      bonuses: { intelligence: 1, wisdom: 1 },
      skills: ["Study techniques", "Time management"]
    },
    athlete: {
      name: "Athlete",
      description: "Physical excellence drives you",
      bonuses: { strength: 1, constitution: 1 },
      skills: ["Physical training", "Competitive spirit"]
    },
    artist: {
      name: "Artist",
      description: "Creativity flows through everything you do",
      bonuses: { dexterity: 1, charisma: 1 },
      skills: ["Creative expression", "Artistic vision"]
    },
    leader: {
      name: "Leader",
      description: "You inspire and guide others",
      bonuses: { charisma: 1, wisdom: 1 },
      skills: ["Social influence", "Team coordination"]
    },
    explorer: {
      name: "Explorer",
      description: "Adventure and discovery call to you",
      bonuses: { dexterity: 1, constitution: 1 },
      skills: ["Adaptability", "Risk assessment"]
    }
  };

  // Task categories
  const taskCategories = {
    academic: {
      name: "Academic Quests",
      icon: "📚",
      primaryStat: "intelligence",
      secondaryStat: "wisdom",
      color: "#3B82F6",
      activities: [
        "Complete homework assignment",
        "Study for test/exam",
        "Read textbook chapter",
        "Write essay/report",
        "Solve math problems",
        "Research project topic",
        "Review class notes",
        "Online learning course",
        "Language practice",
        "Science experiment"
      ]
    },
    social: {
      name: "Social Quests",
      icon: "👥",
      primaryStat: "charisma",
      secondaryStat: "wisdom",
      color: "#EC4899",
      activities: [
        "Have meaningful conversation with friend",
        "Call/text family member",
        "Participate in group activity",
        "Help someone with a problem",
        "Join a club or team",
        "Attend social event",
        "Practice public speaking",
        "Collaborate on group project",
        "Volunteer in community",
        "Lead a team activity"
      ]
    },
    fitness: {
      name: "Fitness Quests",
      icon: "💪",
      primaryStat: "strength",
      secondaryStat: "constitution",
      color: "#10B981",
      activities: [
        "Go for a run/jog",
        "Strength training workout",
        "Play a sport",
        "Bike ride",
        "Swimming",
        "Yoga/stretching",
        "Dance session",
        "Martial arts practice",
        "Hiking/walking",
        "Team sports participation"
      ]
    },
    health: {
      name: "Health & Wellness Quests",
      icon: "🏥",
      primaryStat: "constitution",
      secondaryStat: "wisdom",
      color: "#EF4444",
      activities: [
        "Get 8+ hours of sleep",
        "Eat a nutritious meal",
        "Drink enough water",
        "Take vitamins/medication",
        "Practice meditation",
        "Deep breathing exercises",
        "Take a mental health break",
        "Practice good hygiene",
        "Get sunlight/fresh air",
        "Schedule medical checkup"
      ]
    },
    creative: {
      name: "Creative Quests",
      icon: "🎨",
      primaryStat: "dexterity",
      secondaryStat: "charisma",
      color: "#8B5CF6",
      activities: [
        "Draw/paint/sketch",
        "Write creative story/poem",
        "Play musical instrument",
        "Learn new song",
        "Photography session",
        "Craft/DIY project",
        "Digital art creation",
        "Video editing",
        "Creative writing",
        "Design project"
      ]
    },
    life_skills: {
      name: "Life Skills Quests",
      icon: "🏠",
      primaryStat: "wisdom",
      secondaryStat: "intelligence",
      color: "#F59E0B",
      activities: [
        "Clean/organize room",
        "Do laundry",
        "Prepare a meal",
        "Budget/manage money",
        "Plan schedule",
        "Learn practical skill",
        "Help with household chores",
        "Time management practice",
        "Goal setting session",
        "Problem-solving exercise"
      ]
    }
  };

  const [tasks, setTasks] = useState([]);
  const [newTask, setNewTask] = useState({
    title: '',
    description: '',
    type: 'quest',
    category: 'academic',
    difficulty: 'medium',
    estimatedTime: 25,
    importance: 'medium',
    tags: [],
    dueDate: new Date()
  });

  // Character creation state
  const [creationStep, setCreationStep] = useState('name');
  const [tempCharacter, setTempCharacter] = useState({
    name: "",
    class: "",
    background: "",
    stats: { strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10 },
    avatar: "🧙‍♂️"
  });
  const [statPoints, setStatPoints] = useState(27);

  // Load character data on app start
  useEffect(() => {
    loadCharacterData();
  }, []);

  // Save character data whenever it changes
  useEffect(() => {
    if (characterCreated) {
      saveCharacterData();
    }
  }, [character, characterCreated]);

  const loadCharacterData = async () => {
    try {
      const savedCharacter = await AsyncStorage.getItem('character');
      const savedCharacterCreated = await AsyncStorage.getItem('characterCreated');
      
      if (savedCharacter && savedCharacterCreated === 'true') {
        setCharacter(JSON.parse(savedCharacter));
        setCharacterCreated(true);
        setCurrentView('dashboard');
      }
    } catch (error) {
      console.error('Error loading character data:', error);
    }
  };

  const saveCharacterData = async () => {
    try {
      await AsyncStorage.setItem('character', JSON.stringify(character));
      await AsyncStorage.setItem('characterCreated', characterCreated.toString());
    } catch (error) {
      console.error('Error saving character data:', error);
    }
  };

  // Calculate stat modifiers (D&D style)
  const getStatModifier = (statValue) => {
    return Math.floor((statValue - 10) / 2);
  };

  // Calculate XP reward based on difficulty and character class
  const calculateXPReward = (category, difficulty, characterClass) => {
    const baseXP = {
      easy: 25,
      medium: 50,
      hard: 100,
      legendary: 200
    };

    let xp = baseXP[difficulty] || 50;

    // Class bonus
    const classInfo = characterClasses[characterClass];
    if (classInfo) {
      const categoryInfo = taskCategories[category];
      if (categoryInfo && (categoryInfo.primaryStat === classInfo.primaryStat)) {
        xp *= 2; // Double XP for class specialty
      }
    }

    return xp;
  };

  // Complete task and award XP/stat increases
  const completeTask = (taskId) => {
    const task = tasks.find(t => t.id === taskId);
    if (!task) return;

    // Update task status
    setTasks(prev => prev.map(t => 
      t.id === taskId 
        ? { ...t, status: 'completed', completedAt: new Date() }
        : t
    ));

    // Calculate rewards
    const xpReward = calculateXPReward(task.category, task.difficulty, character.class);
    const goldReward = Math.floor(xpReward / 2);
    
    // Determine which stats to increase
    const categoryInfo = taskCategories[task.category];
    const primaryStatIncrease = 1;
    const secondaryStatIncrease = 0.5;

    setCharacter(prev => {
      const newXP = prev.xp + xpReward;
      const shouldLevelUp = newXP >= prev.xpToNext;
      
      const newStats = { ...prev.stats };
      if (categoryInfo) {
        newStats[categoryInfo.primaryStat] += primaryStatIncrease;
        if (categoryInfo.secondaryStat) {
          newStats[categoryInfo.secondaryStat] += secondaryStatIncrease;
        }
      }

      const result = {
        ...prev,
        xp: shouldLevelUp ? newXP - prev.xpToNext : newXP,
        level: shouldLevelUp ? prev.level + 1 : prev.level,
        xpToNext: shouldLevelUp ? (prev.level + 1) * 100 : prev.xpToNext,
        gold: prev.gold + goldReward,
        stats: newStats,
        health: Math.min(prev.maxHealth, prev.health + 5)
      };

      return result;
    });

    // Show completion alert
    Alert.alert(
      "Quest Complete! 🎉",
      `You earned ${xpReward} XP and ${goldReward} gold!`,
      [{ text: "Awesome!", style: "default" }]
    );
  };

  // Character Creation Functions
  const rollStats = () => {
    const newStats = {};
    Object.keys(tempCharacter.stats).forEach(stat => {
      // Roll 4d6, drop lowest (D&D standard)
      const rolls = Array.from({length: 4}, () => Math.floor(Math.random() * 6) + 1);
      rolls.sort((a, b) => b - a);
      newStats[stat] = rolls.slice(0, 3).reduce((sum, roll) => sum + roll, 0);
    });
    
    setTempCharacter(prev => ({ ...prev, stats: newStats }));
  };

  const adjustStat = (stat, change) => {
    const newValue = tempCharacter.stats[stat] + change;
    const cost = change > 0 ? 1 : -1;
    
    if (newValue >= 8 && newValue <= 15 && statPoints >= cost && statPoints - cost >= 0) {
      setTempCharacter(prev => ({
        ...prev,
        stats: { ...prev.stats, [stat]: newValue }
      }));
      setStatPoints(prev => prev - cost);
    }
  };

  const finishCharacterCreation = () => {
    const selectedClass = characterClasses[tempCharacter.class];
    const selectedBackground = backgrounds[tempCharacter.background];
    
    // Apply class and background bonuses
    const finalStats = { ...tempCharacter.stats };
    if (selectedClass) {
      Object.entries(selectedClass.bonuses).forEach(([stat, bonus]) => {
        finalStats[stat] += bonus;
      });
    }
    if (selectedBackground) {
      Object.entries(selectedBackground.bonuses).forEach(([stat, bonus]) => {
        finalStats[stat] += bonus;
      });
    }

    setCharacter(prev => ({
      ...prev,
      name: tempCharacter.name,
      class: tempCharacter.class,
      background: tempCharacter.background,
      stats: finalStats,
      avatar: tempCharacter.avatar
    }));
    
    setCharacterCreated(true);
    setCurrentView('dashboard');
  };

  // Timer functionality
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTime(new Date());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    let interval;
    if (timerRunning && timerTime > 0) {
      interval = setInterval(() => {
        setTimerTime(prev => prev - 1);
      }, 1000);
    } else if (timerTime === 0 && activeTimer) {
      completeTimerTask();
    }
    return () => clearInterval(interval);
  }, [timerRunning, timerTime, activeTimer]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const startTimer = (task) => {
    setActiveTimer(task);
    setTimerTime(task.estimatedTime * 60);
    setTimerRunning(true);
  };

  const toggleTimer = () => {
    setTimerRunning(!timerRunning);
  };

  const completeTimerTask = () => {
    if (activeTimer) {
      completeTask(activeTimer.id);
      setActiveTimer(null);
      setTimerRunning(false);
    }
  };

  const addNewTask = () => {
    const task = {
      ...newTask,
      id: Date.now(),
      status: 'pending',
      tags: typeof newTask.tags === 'string' ? newTask.tags.split(',').map(t => t.trim()) : newTask.tags
    };
    
    setTasks(prev => [...prev, task]);
    setNewTask({
      title: '',
      description: '',
      type: 'quest',
      category: 'academic',
      difficulty: 'medium',
      estimatedTime: 25,
      importance: 'medium',
      tags: [],
      dueDate: new Date()
    });
    setShowNewTaskModal(false);
  };

  const getDifficultyColor = (difficulty) => {
    const colors = {
      easy: '#10B981',
      medium: '#F59E0B',
      hard: '#F97316',
      legendary: '#EF4444'
    };
    return colors[difficulty] || '#6B7280';
  };

  // Render character creation screens
  const renderCharacterCreation = () => {
    if (creationStep === 'name') {
      return (
        <View style={styles.creationContainer}>
          <Text style={styles.creationEmoji}>🎭</Text>
          <Text style={styles.creationTitle}>Create Your Character</Text>
          <Text style={styles.creationSubtitle}>Choose your identity for this adventure</Text>
          
          <View style={styles.creationForm}>
            <Text style={styles.inputLabel}>Character Name</Text>
            <TextInput
              style={styles.textInput}
              value={tempCharacter.name}
              onChangeText={(text) => setTempCharacter(prev => ({ ...prev, name: text }))}
              placeholder="Enter your hero's name"
              placeholderTextColor="#9CA3AF"
            />
            
            <Text style={[styles.inputLabel, { marginTop: 20 }]}>Choose Avatar</Text>
            <View style={styles.avatarGrid}>
              {['🧙‍♂️', '🧙‍♀️', '⚔️', '🏹', '🛡️', '✨', '🎨', '📚'].map(avatar => (
                <TouchableOpacity
                  key={avatar}
                  onPress={() => setTempCharacter(prev => ({ ...prev, avatar }))}
                  style={[
                    styles.avatarButton,
                    tempCharacter.avatar === avatar && styles.avatarButtonSelected
                  ]}
                >
                  <Text style={styles.avatarText}>{avatar}</Text>
                </TouchableOpacity>
              ))}
            </View>
            
            <TouchableOpacity
              onPress={() => setCreationStep('class')}
              disabled={!tempCharacter.name}
              style={[styles.primaryButton, !tempCharacter.name && styles.disabledButton]}
            >
              <Text style={styles.primaryButtonText}>Choose Class</Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }

    if (creationStep === 'class') {
      return (
        <View style={styles.creationContainer}>
          <View style={styles.creationHeader}>
            <Text style={styles.creationAvatar}>{tempCharacter.avatar}</Text>
            <Text style={styles.creationName}>{tempCharacter.name}</Text>
            <Text style={styles.creationSubtitle}>Choose your class</Text>
          </View>
          
          <ScrollView style={styles.optionsList}>
            {Object.entries(characterClasses).map(([key, classInfo]) => (
              <TouchableOpacity
                key={key}
                onPress={() => setTempCharacter(prev => ({ ...prev, class: key }))}
                style={[
                  styles.optionCard,
                  tempCharacter.class === key && styles.optionCardSelected
                ]}
              >
                <View style={styles.optionCardHeader}>
                  <Text style={styles.optionIcon}>{classInfo.icon}</Text>
                  <View style={styles.optionInfo}>
                    <Text style={styles.optionTitle}>{classInfo.name}</Text>
                    <Text style={styles.optionDescription}>{classInfo.description}</Text>
                    <Text style={styles.optionStat}>Primary: {classInfo.primaryStat}</Text>
                  </View>
                </View>
                <Text style={styles.optionAbilities}>{classInfo.abilities.join(' • ')}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
          
          <View style={styles.buttonRow}>
            <TouchableOpacity
              onPress={() => setCreationStep('name')}
              style={styles.secondaryButton}
            >
              <Text style={styles.secondaryButtonText}>Back</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => setCreationStep('background')}
              disabled={!tempCharacter.class}
              style={[styles.primaryButton, styles.flexButton, !tempCharacter.class && styles.disabledButton]}
            >
              <Text style={styles.primaryButtonText}>Choose Background</Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }

    if (creationStep === 'background') {
      return (
        <View style={styles.creationContainer}>
          <View style={styles.creationHeader}>
            <Text style={styles.creationAvatar}>{tempCharacter.avatar}</Text>
            <Text style={styles.creationName}>{tempCharacter.name}</Text>
            <Text style={styles.creationClass}>{characterClasses[tempCharacter.class]?.name}</Text>
            <Text style={styles.creationSubtitle}>Choose your background</Text>
          </View>
          
          <ScrollView style={styles.optionsList}>
            {Object.entries(backgrounds).map(([key, bg]) => (
              <TouchableOpacity
                key={key}
                onPress={() => setTempCharacter(prev => ({ ...prev, background: key }))}
                style={[
                  styles.optionCard,
                  tempCharacter.background === key && styles.optionCardSelected
                ]}
              >
                <Text style={styles.optionTitle}>{bg.name}</Text>
                <Text style={styles.optionDescription}>{bg.description}</Text>
                <Text style={styles.optionSkills}>Skills: {bg.skills.join(', ')}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
          
          <View style={styles.buttonRow}>
            <TouchableOpacity
              onPress={() => setCreationStep('class')}
              style={styles.secondaryButton}
            >
              <Text style={styles.secondaryButtonText}>Back</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => {
                rollStats();
                setCreationStep('stats');
              }}
              disabled={!tempCharacter.background}
              style={[styles.primaryButton, styles.flexButton, !tempCharacter.background && styles.disabledButton]}
            >
              <Text style={styles.primaryButtonText}>Roll Stats</Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }

    if (creationStep === 'stats') {
      return (
        <View style={styles.creationContainer}>
          <View style={styles.creationHeader}>
            <Text style={styles.creationAvatar}>{tempCharacter.avatar}</Text>
            <Text style={styles.creationName}>{tempCharacter.name}</Text>
            <Text style={styles.creationClass}>
              {characterClasses[tempCharacter.class]?.name} • {backgrounds[tempCharacter.background]?.name}
            </Text>
            <Text style={styles.creationSubtitle}>Adjust your stats</Text>
            <Text style={styles.statPoints}>Points remaining: {statPoints}</Text>
          </View>
          
          <ScrollView style={styles.statsList}>
            {Object.entries(tempCharacter.stats).map(([stat, value]) => (
              <View key={stat} style={styles.statRow}>
                <View style={styles.statInfo}>
                  <Text style={styles.statName}>{stat.charAt(0).toUpperCase() + stat.slice(1)}</Text>
                  <Text style={styles.statModifier}>
                    Modifier: {getStatModifier(value) >= 0 ? '+' : ''}{getStatModifier(value)}
                  </Text>
                </View>
                <View style={styles.statControls}>
                  <TouchableOpacity
                    onPress={() => adjustStat(stat, -1)}
                    disabled={value <= 8 || statPoints <= 0}
                    style={[styles.statButton, styles.decreaseButton, (value <= 8 || statPoints <= 0) && styles.disabledButton]}
                  >
                    <Text style={styles.statButtonText}>-</Text>
                  </TouchableOpacity>
                  <Text style={styles.statValue}>{value}</Text>
                  <TouchableOpacity
                    onPress={() => adjustStat(stat, 1)}
                    disabled={value >= 15 || statPoints <= 0}
                    style={[styles.statButton, styles.increaseButton, (value >= 15 || statPoints <= 0) && styles.disabledButton]}
                  >
                    <Text style={styles.statButtonText}>+</Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </ScrollView>
          
          <View style={styles.buttonRow}>
            <TouchableOpacity
              onPress={() => {
                rollStats();
                setStatPoints(27);
              }}
              style={[styles.secondaryButton, styles.rollButton]}
            >
              <MaterialCommunityIcons name="dice-6" size={16} color="#6B7280" />
              <Text style={styles.secondaryButtonText}>Reroll</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => setCreationStep('background')}
              style={styles.secondaryButton}
            >
              <Text style={styles.secondaryButtonText}>Back</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={finishCharacterCreation}
              style={[styles.primaryButton, styles.flexButton]}
            >
              <Text style={styles.primaryButtonText}>Begin Adventure!</Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }
  };

  // Main app screens
  const renderHeader = () => (
    <View style={styles.header}>
      <View style={styles.headerContent}>
        <View style={styles.characterInfo}>
          <Text style={styles.characterAvatar}>{character.avatar}</Text>
          <View>
            <Text style={styles.characterName}>{character.name}</Text>
            <Text style={styles.characterLevel}>
              Level {character.level} {characterClasses[character.class]?.name}
            </Text>
          </View>
        </View>
        <View style={styles.headerRight}>
          <View style={styles.resourceInfo}>
            <View style={styles.goldContainer}>
              <MaterialCommunityIcons name="gold" size={16} color="#FCD34D" />
              <Text style={styles.goldText}>{character.gold}</Text>
            </View>
            <Text style={styles.xpText}>{character.xp}/{character.xpToNext} XP</Text>
          </View>
          <TouchableOpacity
            onPress={() => setShowSettingsModal(true)}
            style={styles.settingsButton}
          >
            <Ionicons name="settings" size={20} color="white" />
          </TouchableOpacity>
        </View>
      </View>
      
      {/* Stats Display */}
      <View style={styles.statsGrid}>
        <View style={styles.statBox}>
          <Text style={styles.statLabel}>STR</Text>
          <Text style={styles.statValue}>{character.stats.strength}</Text>
          <Text style={styles.statModifierYellow}>
            {getStatModifier(character.stats.strength) >= 0 ? '+' : ''}{getStatModifier(character.stats.strength)}
          </Text>
        </View>
        <View style={styles.statBox}>
          <Text style={styles.statLabel}>INT</Text>
          <Text style={styles.statValue}>{character.stats.intelligence}</Text>
          <Text style={styles.statModifierBlue}>
            {getStatModifier(character.stats.intelligence) >= 0 ? '+' : ''}{getStatModifier(character.stats.intelligence)}
          </Text>
        </View>
        <View style={styles.statBox}>
          <Text style={styles.statLabel}>CHA</Text>
          <Text style={styles.statValue}>{character.stats.charisma}</Text>
          <Text style={styles.statModifierPink}>
            {getStatModifier(character.stats.charisma) >= 0 ? '+' : ''}{getStatModifier(character.stats.charisma)}
          </Text>
        </View>
      </View>
      
      {/* Health and XP bars */}
      <View style={styles.barsContainer}>
        <View style={styles.barRow}>
          <FontAwesome5 name="heart" size={14} color="#EF4444" />
          <View style={styles.barBackground}>
            <View 
              style={[styles.healthBar, { width: `${(character.health / character.maxHealth) * 100}%` }]}
            />
          </View>
          <Text style={styles.barText}>{character.health}/{character.maxHealth}</Text>
        </View>
        
        <View style={styles.barRow}>
          <FontAwesome5 name="star" size={14} color="#3B82F6" />
          <View style={styles.barBackground}>
            <View 
              style={[styles.xpBar, { width: `${(character.xp / character.xpToNext) * 100}%` }]}
            />
          </View>
          <Text style={styles.barText}>Level {character.level}</Text>
        </View>
      </View>
    </View>
  );

  const renderDashboard = () => {
    const todayTasks = tasks.filter(t => 
      t.dueDate && new Date(t.dueDate).toDateString() === new Date().toDateString()
    );
    const completedToday = todayTasks.filter(t => t.status === 'completed').length;
    const pendingTasks = todayTasks.filter(t => t.status === 'pending');

    return (
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Daily Progress */}
        <View style={styles.dailyProgress}>
          <View style={styles.dailyProgressHeader}>
            <Text style={styles.dailyProgressTitle}>Today's Adventures</Text>
            <Text style={styles.dailyProgressCount}>{completedToday}/{todayTasks.length} completed</Text>
          </View>
          <View style={styles.progressBarBackground}>
            <View 
              style={[styles.progressBar, { width: `${todayTasks.length > 0 ? (completedToday / todayTasks.length) * 100 : 0}%` }]}
            />
          </View>
          <Text style={styles.dailyProgressText}>
            {completedToday === todayTasks.length && todayTasks.length > 0 
              ? "🎉 All adventures completed! Epic!" 
              : `${pendingTasks.length} adventures remaining`}
          </Text>
        </View>

        {/* Quick Adventure Categories */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Quick Adventures</Text>
            <TouchableOpacity
              onPress={() => setShowNewTaskModal(true)}
              style={styles.addButton}
            >
              <Ionicons name="add" size={16} color="#7C3AED" />
            </TouchableOpacity>
          </View>
          
          <View style={styles.categoryGrid}>
            {Object.entries(taskCategories).slice(0, 6).map(([key, category]) => (
              <TouchableOpacity
                key={key}
                onPress={() => {
                  setNewTask(prev => ({ ...prev, category: key }));
                  setShowNewTaskModal(true);
                }}
                style={[styles.categoryCard, { backgroundColor: category.color }]}
              >
                <Text style={styles.categoryIcon}>{category.icon}</Text>
                <Text style={styles.categoryName}>{category.name}</Text>
                <Text style={styles.categoryStat}>+{category.primaryStat.toUpperCase()}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Character Status */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Character Status</Text>
          <View style={styles.characterStatusRow}>
            <View style={styles.characterStatusLeft}>
              <Text style={styles.statusAvatar}>{character.avatar}</Text>
              <View>
                <Text style={styles.statusName}>{character.name}</Text>
                <Text style={styles.statusClass}>
                  Level {character.level} {characterClasses[character.class]?.name}
                </Text>
                <Text style={styles.statusEquipment}>{character.equipment.weapon}</Text>
              </View>
            </View>
            <View style={styles.characterStatusRight}>
              <Text style={styles.nextLevelLabel}>Next Level</Text>
              <Text style={styles.nextLevelXP}>{character.xpToNext - character.xp} XP</Text>
            </View>
          </View>
        </View>
      </ScrollView>
    );
  };

  const renderCharacterView = () => (
    <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
      {/* Character Info */}
      <View style={styles.characterCard}>
        <Text style={styles.characterCardAvatar}>{character.avatar}</Text>
        <Text style={styles.characterCardName}>{character.name}</Text>
        <Text style={styles.characterCardClass}>
          Level {character.level} {characterClasses[character.class]?.name}
        </Text>
        <Text style={styles.characterCardBackground}>
          {backgrounds[character.background]?.name} Background
        </Text>
      </View>

      {/* Detailed Stats */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Ability Scores</Text>
        <View style={styles.abilityGrid}>
          {Object.entries(character.stats).map(([stat, value]) => (
            <View key={stat} style={styles.abilityBox}>
              <View style={styles.abilityHeader}>
                <Text style={styles.abilityName}>{stat.charAt(0).toUpperCase() + stat.slice(1)}</Text>
                <View style={styles.abilityScores}>
                  <Text style={styles.abilityValue}>{value}</Text>
                  <Text style={styles.abilityModifier}>
                    {getStatModifier(value) >= 0 ? '+' : ''}{getStatModifier(value)}
                  </Text>
                </View>
              </View>
            </View>
          ))}
        </View>
      </View>

      {/* Equipment */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Equipment</Text>
        <View style={styles.equipmentList}>
          <View style={styles.equipmentItem}>
            <Text style={styles.equipmentLabel}>Weapon</Text>
            <Text style={styles.equipmentValue}>{character.equipment.weapon}</Text>
          </View>
          <View style={styles.equipmentItem}>
            <Text style={styles.equipmentLabel}>Armor</Text>
            <Text style={styles.equipmentValue}>{character.equipment.armor}</Text>
          </View>
          <View style={styles.equipmentItem}>
            <Text style={styles.equipmentLabel}>Accessory</Text>
            <Text style={styles.equipmentValue}>{character.equipment.accessory}</Text>
          </View>
        </View>
      </View>

      {/* Class Abilities */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Class Abilities</Text>
        <View style={styles.abilitiesList}>
          {characterClasses[character.class]?.abilities.map((ability, index) => (
            <View key={index} style={styles.abilityItem}>
              <FontAwesome5 name="star" size={12} color="#F59E0B" />
              <Text style={styles.abilityText}>{ability}</Text>
            </View>
          ))}
        </View>
      </View>
    </ScrollView>
  );

  const renderNewTaskModal = () => (
    <Modal
      visible={showNewTaskModal}
      animationType="slide"
      transparent={true}
      onRequestClose={() => setShowNewTaskModal(false)}
    >
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <View style={styles.modalHeader}>
            <Text style={styles.modalTitle}>Create New Adventure</Text>
            <TouchableOpacity onPress={() => setShowNewTaskModal(false)}>
              <Ionicons name="close" size={24} color="#374151" />
            </TouchableOpacity>
          </View>
          
          <ScrollView style={styles.modalBody}>
            <Text style={styles.inputLabel}>Adventure Title</Text>
            <TextInput
              style={styles.textInput}
              value={newTask.title}
              onChangeText={(text) => setNewTask({...newTask, title: text})}
              placeholder="What adventure awaits?"
              placeholderTextColor="#9CA3AF"
            />
            
            <Text style={[styles.inputLabel, { marginTop: 16 }]}>Category</Text>
            <View style={styles.categoryPicker}>
              {Object.entries(taskCategories).map(([key, category]) => (
                <TouchableOpacity
                  key={key}
                  onPress={() => setNewTask({...newTask, category: key})}
                  style={[
                    styles.categoryOption,
                    newTask.category === key && styles.categoryOptionSelected
                  ]}
                >
                  <Text style={styles.categoryOptionText}>
                    {category.icon} {category.name}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
            
            <View style={styles.statBonusBox}>
              <Text style={styles.statBonusTitle}>
                Primary Stat Bonus: +{taskCategories[newTask.category]?.primaryStat.toUpperCase()}
              </Text>
              <Text style={styles.statBonusText}>
                This adventure will increase your {taskCategories[newTask.category]?.primaryStat} skill!
              </Text>
            </View>
            
            <View style={styles.formRow}>
              <View style={styles.formColumn}>
                <Text style={styles.inputLabel}>Difficulty</Text>
                <View style={styles.difficultyPicker}>
                  {[
                    { value: 'easy', label: 'Easy (+25 XP)' },
                    { value: 'medium', label: 'Medium (+50 XP)' },
                    { value: 'hard', label: 'Hard (+100 XP)' },
                    { value: 'legendary', label: 'Legendary (+200 XP)' }
                  ].map(option => (
                    <TouchableOpacity
                      key={option.value}
                      onPress={() => setNewTask({...newTask, difficulty: option.value})}
                      style={[
                        styles.difficultyOption,
                        newTask.difficulty === option.value && styles.difficultyOptionSelected
                      ]}
                    >
                      <Text style={[
                        styles.difficultyOptionText,
                        newTask.difficulty === option.value && styles.difficultyOptionTextSelected
                      ]}>
                        {option.label}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>
              
              <View style={styles.formColumn}>
                <Text style={styles.inputLabel}>Time (min)</Text>
                <TextInput
                  style={styles.textInput}
                  value={newTask.estimatedTime.toString()}
                  onChangeText={(text) => setNewTask({...newTask, estimatedTime: parseInt(text) || 25})}
                  keyboardType="numeric"
                  placeholder="25"
                />
              </View>
            </View>
            
            <View style={styles.rewardsBox}>
              <Text style={styles.rewardsTitle}>Adventure Rewards</Text>
              <View style={styles.rewardsRow}>
                <View style={styles.rewardItem}>
                  <FontAwesome5 name="star" size={12} color="#3B82F6" />
                  <Text style={styles.rewardText}>
                    {calculateXPReward(newTask.category, newTask.difficulty, character.class)} XP
                  </Text>
                </View>
                <View style={styles.rewardItem}>
                  <MaterialCommunityIcons name="gold" size={12} color="#F59E0B" />
                  <Text style={styles.rewardText}>
                    {Math.floor(calculateXPReward(newTask.category, newTask.difficulty, character.class) / 2)} Gold
                  </Text>
                </View>
              </View>
              {characterClasses[character.class] && 
               taskCategories[newTask.category]?.primaryStat === characterClasses[character.class].primaryStat && (
                <Text style={styles.bonusText}>🎉 Class bonus: Double XP!</Text>
              )}
            </View>
            
            <View style={styles.modalButtons}>
              <TouchableOpacity
                onPress={() => setShowNewTaskModal(false)}
                style={styles.secondaryButton}
              >
                <Text style={styles.secondaryButtonText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={addNewTask}
                disabled={!newTask.title}
                style={[styles.primaryButton, styles.flexButton, !newTask.title && styles.disabledButton]}
              >
                <Text style={styles.primaryButtonText}>Create Adventure</Text>
              </TouchableOpacity>
            </View>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );

  const renderBottomNavigation = () => (
    <View style={styles.bottomNav}>
      <TouchableOpacity
        onPress={() => setCurrentView('dashboard')}
        style={styles.navItem}
      >
        <Ionicons 
          name="home" 
          size={20} 
          color={currentView === 'dashboard' ? '#7C3AED' : '#9CA3AF'} 
        />
        <Text style={[styles.navText, currentView === 'dashboard' && styles.navTextActive]}>
          Quest
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => setCurrentView('tasks')}
        style={styles.navItem}
      >
        <MaterialCommunityIcons 
          name="target" 
          size={20} 
          color={currentView === 'tasks' ? '#7C3AED' : '#9CA3AF'} 
        />
        <Text style={[styles.navText, currentView === 'tasks' && styles.navTextActive]}>
          Adventures
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => setCurrentView('timer')}
        style={styles.navItem}
      >
        <MaterialCommunityIcons 
          name="timer" 
          size={20} 
          color={currentView === 'timer' ? '#7C3AED' : '#9CA3AF'} 
        />
        <Text style={[styles.navText, currentView === 'timer' && styles.navTextActive]}>
          Focus
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => setCurrentView('character')}
        style={styles.navItem}
      >
        <FontAwesome5 
          name="user" 
          size={20} 
          color={currentView === 'character' ? '#7C3AED' : '#9CA3AF'} 
        />
        <Text style={[styles.navText, currentView === 'character' && styles.navTextActive]}>
          Character
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        onPress={() => setCurrentView('progress')}
        style={styles.navItem}
      >
        <FontAwesome5 
          name="trophy" 
          size={20} 
          color={currentView === 'progress' ? '#7C3AED' : '#9CA3AF'} 
        />
        <Text style={[styles.navText, currentView === 'progress' && styles.navTextActive]}>
          Progress
        </Text>
      </TouchableOpacity>
    </View>
  );

  // Main render
  if (!characterCreated) {
    return (
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor="#4C1D95" />
        <View style={styles.creationHeader}>
          <Text style={styles.headerTitle}>Welcome to Mind Labs Quest</Text>
          <Text style={styles.headerSubtitle}>Your ADHD productivity adventure begins</Text>
        </View>
        {renderCharacterCreation()}
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#4C1D95" />
      {renderHeader()}
      <View style={styles.mainContent}>
        {currentView === 'dashboard' && renderDashboard()}
        {currentView === 'character' && renderCharacterView()}
        {currentView === 'tasks' && (
          <View style={styles.content}>
            <Text style={styles.comingSoon}>Tasks view - Coming soon!</Text>
          </View>
        )}
        {currentView === 'timer' && (
          <View style={styles.content}>
            <Text style={styles.comingSoon}>Timer view - Coming soon!</Text>
          </View>
        )}
        {currentView === 'progress' && (
          <View style={styles.content}>
            <Text style={styles.comingSoon}>Progress view - Coming soon!</Text>
          </View>
        )}
      </View>
      {renderBottomNavigation()}
      {renderNewTaskModal()}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F3F4F6',
  },
  // Character Creation Styles
  creationHeader: {
    backgroundColor: '#4C1D95',
    padding: 20,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  headerSubtitle: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
    marginTop: 4,
  },
  creationContainer: {
    flex: 1,
    backgroundColor: 'white',
    padding: 20,
  },
  creationEmoji: {
    fontSize: 60,
    textAlign: 'center',
    marginBottom: 16,
  },
  creationTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  creationSubtitle: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
    marginBottom: 24,
  },
  creationForm: {
    flex: 1,
  },
  inputLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
    marginBottom: 8,
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#111827',
  },
  avatarGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 24,
  },
  avatarButton: {
    width: 60,
    height: 60,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#E5E7EB',
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarButtonSelected: {
    borderColor: '#7C3AED',
    backgroundColor: '#EDE9FE',
  },
  avatarText: {
    fontSize: 30,
  },
  primaryButton: {
    backgroundColor: '#7C3AED',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '500',
  },
  secondaryButton: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    flexDirection: 'row',
    gap: 4,
  },
  secondaryButtonText: {
    color: '#374151',
    fontSize: 16,
    fontWeight: '500',
  },
  disabledButton: {
    opacity: 0.5,
  },
  creationHeader: {
    alignItems: 'center',
    marginBottom: 24,
  },
  creationAvatar: {
    fontSize: 48,
    marginBottom: 8,
  },
  creationName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#111827',
  },
  creationClass: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 4,
  },
  optionsList: {
    flex: 1,
    marginBottom: 16,
  },
  optionCard: {
    padding: 16,
    borderWidth: 2,
    borderColor: '#E5E7EB',
    borderRadius: 8,
    marginBottom: 12,
  },
  optionCardSelected: {
    borderColor: '#7C3AED',
    backgroundColor: '#EDE9FE',
  },
  optionCardHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
  },
  optionIcon: {
    fontSize: 24,
  },
  optionInfo: {
    flex: 1,
  },
  optionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#111827',
  },
  optionDescription: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 2,
  },
  optionStat: {
    fontSize: 12,
    color: '#7C3AED',
    marginTop: 4,
  },
  optionAbilities: {
    fontSize: 12,
    color: '#6B7280',
    marginTop: 8,
  },
  optionSkills: {
    fontSize: 12,
    color: '#7C3AED',
    marginTop: 4,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
  },
  flexButton: {
    flex: 1,
  },
  statPoints: {
    fontSize: 14,
    color: '#7C3AED',
    marginTop: 8,
  },
  statsList: {
    flex: 1,
    marginBottom: 16,
  },
  statRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    backgroundColor: '#F9FAFB',
    borderRadius: 8,
    marginBottom: 8,
  },
  statInfo: {
    flex: 1,
  },
  statName: {
    fontSize: 16,
    fontWeight: '500',
    color: '#111827',
    textTransform: 'capitalize',
  },
  statModifier: {
    fontSize: 14,
    color: '#6B7280',
  },
  statControls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  statButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  decreaseButton: {
    backgroundColor: '#FEE2E2',
  },
  increaseButton: {
    backgroundColor: '#D1FAE5',
  },
  statButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#374151',
  },
  statValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    minWidth: 24,
    textAlign: 'center',
  },
  rollButton: {
    gap: 4,
  },
  // Main App Styles
  header: {
    backgroundColor: '#4C1D95',
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0,
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  characterInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  characterAvatar: {
    fontSize: 30,
  },
  characterName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  characterLevel: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  resourceInfo: {
    alignItems: 'flex-end',
  },
  goldContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  goldText: {
    fontSize: 14,
    color: 'white',
    fontWeight: '500',
  },
  xpText: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.8)',
  },
  settingsButton: {
    padding: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 20,
  },
  statsGrid: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 12,
  },
  statBox: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderRadius: 8,
    padding: 8,
    alignItems: 'center',
  },
  statLabel: {
    fontSize: 12,
    fontWeight: 'bold',
    color: 'white',
  },
  statValue: {
    fontSize: 16,
    color: 'white',
  },
  statModifierYellow: {
    fontSize: 12,
    color: '#FCD34D',
  },
  statModifierBlue: {
    fontSize: 12,
    color: '#60A5FA',
  },
  statModifierPink: {
    fontSize: 12,
    color: '#F472B6',
  },
  barsContainer: {
    gap: 8,
  },
  barRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  barBackground: {
    flex: 1,
    height: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderRadius: 4,
  },
  healthBar: {
    height: 8,
    backgroundColor: '#EF4444',
    borderRadius: 4,
  },
  xpBar: {
    height: 8,
    backgroundColor: '#3B82F6',
    borderRadius: 4,
  },
  barText: {
    fontSize: 12,
    color: 'white',
    minWidth: 50,
  },
  mainContent: {
    flex: 1,
    backgroundColor: '#F3F4F6',
  },
  content: {
    flex: 1,
    padding: 16,
    paddingBottom: 80,
  },
  // Dashboard Styles
  dailyProgress: {
    backgroundColor: '#7C3AED',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  dailyProgressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  dailyProgressTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  dailyProgressCount: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
  },
  progressBarBackground: {
    height: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    borderRadius: 6,
    marginBottom: 8,
  },
  progressBar: {
    height: 12,
    backgroundColor: 'white',
    borderRadius: 6,
  },
  dailyProgressText: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
  },
  card: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#111827',
  },
  addButton: {
    padding: 8,
    backgroundColor: '#EDE9FE',
    borderRadius: 20,
  },
  categoryGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  categoryCard: {
    width: (width - 32 - 12) / 2 - 6,
    padding: 12,
    borderRadius: 8,
  },
  categoryIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  categoryName: {
    fontSize: 14,
    fontWeight: '500',
    color: 'white',
    marginBottom: 2,
  },
  categoryStat: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.9)',
  },
  characterStatusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  characterStatusLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  statusAvatar: {
    fontSize: 40,
  },
  statusName: {
    fontSize: 16,
    fontWeight: '500',
    color: '#111827',
  },
  statusClass: {
    fontSize: 14,
    color: '#6B7280',
  },
  statusEquipment: {
    fontSize: 12,
    color: '#9CA3AF',
  },
  characterStatusRight: {
    alignItems: 'flex-end',
  },
  nextLevelLabel: {
    fontSize: 14,
    color: '#6B7280',
  },
  nextLevelXP: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#7C3AED',
  },
  // Character View Styles
  characterCard: {
    backgroundColor: '#4C1D95',
    borderRadius: 12,
    padding: 24,
    alignItems: 'center',
    marginBottom: 16,
  },
  characterCardAvatar: {
    fontSize: 60,
    marginBottom: 8,
  },
  characterCardName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
  },
  characterCardClass: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
    marginTop: 4,
  },
  characterCardBackground: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.75)',
    marginTop: 4,
  },
  abilityGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  abilityBox: {
    width: (width - 32 - 12) / 2 - 6,
    padding: 12,
    backgroundColor: '#F9FAFB',
    borderRadius: 8,
  },
  abilityHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  abilityName: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
  },
  abilityScores: {
    alignItems: 'flex-end',
  },
  abilityValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
  },
  abilityModifier: {
    fontSize: 12,
    color: '#6B7280',
  },
  equipmentList: {
    gap: 8,
  },
  equipmentItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 8,
    backgroundColor: '#F9FAFB',
    borderRadius: 6,
  },
  equipmentLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#374151',
  },
  equipmentValue: {
    fontSize: 14,
    color: '#6B7280',
  },
  abilitiesList: {
    gap: 8,
  },
  abilityItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    padding: 8,
    backgroundColor: '#F9FAFB',
    borderRadius: 6,
  },
  abilityText: {
    fontSize: 14,
    color: '#374151',
    flex: 1,
  },
  // Modal Styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  modalContent: {
    backgroundColor: 'white',
    borderRadius: 12,
    width: '100%',
    maxWidth: 400,
    maxHeight: '90%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#111827',
  },
  modalBody: {
    padding: 16,
  },
  categoryPicker: {
    gap: 8,
  },
  categoryOption: {
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  categoryOptionSelected: {
    borderColor: '#7C3AED',
    backgroundColor: '#EDE9FE',
  },
  categoryOptionText: {
    fontSize: 14,
    color: '#374151',
  },
  statBonusBox: {
    backgroundColor: '#EDE9FE',
    padding: 12,
    borderRadius: 8,
    marginTop: 16,
  },
  statBonusTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#5B21B6',
    marginBottom: 4,
  },
  statBonusText: {
    fontSize: 12,
    color: '#7C3AED',
  },
  formRow: {
    flexDirection: 'row',
    gap: 16,
    marginTop: 16,
  },
  formColumn: {
    flex: 1,
  },
  difficultyPicker: {
    gap: 8,
  },
  difficultyOption: {
    padding: 10,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    alignItems: 'center',
  },
  difficultyOptionSelected: {
    borderColor: '#7C3AED',
    backgroundColor: '#EDE9FE',
  },
  difficultyOptionText: {
    fontSize: 12,
    color: '#374151',
  },
  difficultyOptionTextSelected: {
    color: '#7C3AED',
    fontWeight: '500',
  },
  rewardsBox: {
    backgroundColor: '#FEF3C7',
    padding: 12,
    borderRadius: 8,
    marginTop: 16,
  },
  rewardsTitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#92400E',
    marginBottom: 8,
  },
  rewardsRow: {
    flexDirection: 'row',
    gap: 16,
  },
  rewardItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  rewardText: {
    fontSize: 14,
    color: '#92400E',
  },
  bonusText: {
    fontSize: 12,
    color: '#059669',
    marginTop: 4,
  },
  modalButtons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 24,
  },
  // Bottom Navigation
  bottomNav: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'white',
    flexDirection: 'row',
    paddingTop: 8,
    paddingBottom: Platform.OS === 'ios' ? 20 : 8,
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
  },
  navItem: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 8,
  },
  navText: {
    fontSize: 12,
    color: '#9CA3AF',
    marginTop: 4,
  },
  navTextActive: {
    color: '#7C3AED',
  },
  // Misc
  comingSoon: {
    fontSize: 18,
    color: '#6B7280',
    textAlign: 'center',
    marginTop: 40,
  },
});