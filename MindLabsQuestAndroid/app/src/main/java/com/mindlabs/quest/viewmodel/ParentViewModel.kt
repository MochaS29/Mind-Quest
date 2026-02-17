package com.mindlabs.quest.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindlabs.quest.data.models.ChildProgress
import com.mindlabs.quest.data.models.Parent
import com.mindlabs.quest.data.models.Reward
import com.mindlabs.quest.data.repository.ParentRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ParentViewModel @Inject constructor(
    private val parentRepository: ParentRepository
) : ViewModel() {
    
    private val _parent = MutableStateFlow<Parent?>(null)
    val parent: StateFlow<Parent?> = _parent.asStateFlow()
    
    private val _childrenProgress = MutableStateFlow<List<ChildProgress>>(emptyList())
    val childrenProgress: StateFlow<List<ChildProgress>> = _childrenProgress.asStateFlow()
    
    val activeRewards = parentRepository.getActiveRewards()
    
    init {
        loadParentData()
        loadChildrenProgress()
    }
    
    private fun loadParentData() {
        viewModelScope.launch {
            // In a real app, this would get the logged-in parent
            _parent.value = parentRepository.getCurrentParent()
        }
    }
    
    private fun loadChildrenProgress() {
        viewModelScope.launch {
            parent.value?.let { p ->
                val progress = parentRepository.getChildrenProgress(p.childIds)
                _childrenProgress.value = progress
            }
        }
    }
    
    fun createReward(reward: Reward) {
        viewModelScope.launch {
            parentRepository.createReward(reward)
        }
    }
    
    fun updateReward(reward: Reward) {
        viewModelScope.launch {
            parentRepository.updateReward(reward)
        }
    }
    
    fun deleteReward(reward: Reward) {
        viewModelScope.launch {
            parentRepository.deleteReward(reward)
        }
    }
    
    fun linkChild(childCode: String) {
        viewModelScope.launch {
            parent.value?.let { p ->
                val success = parentRepository.linkChildByCode(p.id, childCode)
                if (success) {
                    loadParentData()
                    loadChildrenProgress()
                }
            }
        }
    }
    
    fun refreshData() {
        loadParentData()
        loadChildrenProgress()
    }
}