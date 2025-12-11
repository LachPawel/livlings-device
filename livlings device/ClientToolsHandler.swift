//
//  ClientToolsHandler.swift
//  livlings device
//
//  Created by AI Assistant on 11/12/2025.
//

import Foundation

/// Handles client-side tool calls from the ElevenLabs agent
@MainActor
class ClientToolsHandler {
    private weak var brain: DeviceBrain?
    
    init(brain: DeviceBrain) {
        self.brain = brain
    }
    
    /// Main entry point for handling tool calls from the agent
    func handleToolCall(name: String, parameters: [String: Any]) async -> [String: Any] {
        guard let brain = brain else {
            return ["success": false, "error": "Brain not available"]
        }
        
        brain.log("🔧 Tool called: \(name)")
        
        switch name {
        case "remember":
            return await handleRemember(parameters: parameters)
            
        case "notify_parent":
            return await handleNotifyParent(parameters: parameters)
            
        case "play_sound":
            return await handlePlaySound(parameters: parameters)
            
        case "play_lullaby":
            return await handlePlayLullaby(parameters: parameters)
            
        default:
            brain.log("⚠️ Unknown tool: \(name)")
            return ["success": false, "error": "Unknown tool: \(name)"]
        }
    }
    
    // MARK: - Tool Implementations
    
    /// Tool: remember(key, value)
    /// Stores information in conversation memory
    private func handleRemember(parameters: [String: Any]) async -> [String: Any] {
        guard let brain = brain else {
            return ["success": false, "error": "Brain not available"]
        }
        
        guard let key = parameters["key"] as? String,
              let value = parameters["value"] as? String else {
            return ["success": false, "error": "Missing key or value"]
        }
        
        // Store in memory
        var memory = brain.conversationMemory
        memory[key] = value
        brain.conversationMemory = memory
        
        brain.log("💾 Remembered: \(key) = \(value)")
        
        // Special handling for child_name
        if key == "child_name" {
            brain.childName = value
            brain.sendToParent(ToyMessage(type: .childInfo, data: ["name": value]))
            brain.log("👶 Child name set: \(value)")
        }
        
        return [
            "success": true,
            "message": "Remembered \(key): \(value)"
        ]
    }
    
    /// Tool: notify_parent(message, priority)
    /// Sends a notification to the parent app
    private func handleNotifyParent(parameters: [String: Any]) async -> [String: Any] {
        guard let brain = brain else {
            return ["success": false, "error": "Brain not available"]
        }
        
        guard let message = parameters["message"] as? String else {
            return ["success": false, "error": "Missing message"]
        }
        
        let priority = parameters["priority"] as? String ?? "normal"
        
        brain.log("📬 Notifying parent: \(message) [priority: \(priority)]")
        
        // Send to parent app
        brain.sendToParent(ToyMessage(
            type: .notification,
            data: [
                "message": message,
                "priority": priority,
                "child_name": brain.childName ?? "Child"
            ]
        ))
        
        return [
            "success": true,
            "message": "Parent notified: \(message)"
        ]
    }
    
    /// Tool: play_sound(type)
    /// Plays ambient sounds (heartbeat, rain, ocean, etc.)
    private func handlePlaySound(parameters: [String: Any]) async -> [String: Any] {
        guard let brain = brain else {
            return ["success": false, "error": "Brain not available"]
        }
        
        guard let soundType = parameters["type"] as? String else {
            return ["success": false, "error": "Missing sound type"]
        }
        
        brain.log("🔊 Playing sound: \(soundType)")
        
        // Play the sound asynchronously
        Task {
            await brain.playSound(type: soundType)
        }
        
        return [
            "success": true,
            "message": "Playing \(soundType) sound",
            "sound_type": soundType
        ]
    }
    
    /// Tool: play_lullaby(style)
    /// Generates and plays a lullaby with specific style
    private func handlePlayLullaby(parameters: [String: Any]) async -> [String: Any] {
        guard let brain = brain else {
            return ["success": false, "error": "Brain not available"]
        }
        
        let style = parameters["style"] as? String ?? "default"
        
        brain.log("🎵 Playing lullaby: \(style)")
        
        // Play the lullaby asynchronously
        Task {
            await brain.playLullaby(style: style)
        }
        
        return [
            "success": true,
            "message": "Generating \(style) lullaby",
            "style": style
        ]
    }
}
