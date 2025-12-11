//
//  DeviceMainView.swift
//  livlings device
//
//  Created by Pawel Kowalewski on 11/12/2025.
//

import SwiftUI
import ElevenLabs
import AVFoundation
import CoreMotion
import MultipeerConnectivity
import Combine
import SoundAnalysis


struct DeviceApp: App {
    var body: some Scene {
        WindowGroup {
            DeviceMainView()
                .preferredColorScheme(.dark)
        }
    }
}

struct DeviceMainView: View {
    @StateObject private var deviceBrain = DeviceBrain()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Status Header
                HStack {
                    Circle()
                        .fill(deviceBrain.parentConnected ? Color.green : Color.orange)
                        .frame(width: 12, height: 12)
                    Text(deviceBrain.parentConnected ? "Parent Connected" : "Waiting for Parent...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    
                    // ElevenLabs connection status
                    Circle()
                        .fill(deviceBrain.isAgentConnected ? Color.cyan : Color.gray)
                        .frame(width: 12, height: 12)
                    Text(deviceBrain.isAgentConnected ? "AI Active" : "AI Idle")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Main Status Display
                VStack(spacing: 30) {
                    // Animated Character
                    ZStack {
                        // Outer pulse when listening
                        Circle()
                            .fill(deviceBrain.state.color.opacity(0.15))
                            .frame(width: 220, height: 220)
                            .scaleEffect(deviceBrain.agentState == .listening ? 1.1 : 1.0)
                            .animation(deviceBrain.agentState == .listening ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: deviceBrain.agentState)
                        
                        // Middle ring
                        Circle()
                            .fill(deviceBrain.state.color.opacity(0.3))
                            .frame(width: 180, height: 180)
                            .scaleEffect(deviceBrain.agentState == .speaking ? 1.15 : 1.0)
                            .animation(deviceBrain.agentState == .speaking ? .easeInOut(duration: 0.3).repeatForever(autoreverses: true) : .default, value: deviceBrain.agentState)
                        
                        // Inner circle
                        Circle()
                            .fill(deviceBrain.state.color.opacity(0.5))
                            .frame(width: 140, height: 140)
                        
                        Text(deviceBrain.state.emoji)
                            .font(.system(size: 70))
                    }
                    
                    Text(deviceBrain.state.displayName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Agent state indicator
                    if deviceBrain.isAgentConnected {
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(deviceBrain.agentState == .speaking ? 1.5 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.4)
                                        .repeatForever()
                                        .delay(Double(i) * 0.15),
                                        value: deviceBrain.agentState
                                    )
                            }
                            Text(deviceBrain.agentState == .speaking ? "Speaking..." : "Listening...")
                                .font(.caption)
                                .foregroundColor(.cyan)
                        }
                    }
                    
                    Text(deviceBrain.statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Child Info Card
                if let childName = deviceBrain.childName {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        Text("Playing with: \(childName)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                }
                
                // Last message display
                if let lastMessage = deviceBrain.lastAgentMessage {
                    Text("\"\(lastMessage)\"")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .lineLimit(2)
                }
                
                // Debug Controls (hide in production by setting showDebug = false)
                if deviceBrain.showDebug {
                    VStack(spacing: 10) {
                        Text("Demo Controls").font(.caption).foregroundColor(.gray)
                        
                        HStack(spacing: 15) {
                            Button("🤝 Wake") {
                                deviceBrain.simulateShake()
                            }
                            .buttonStyle(ToyButtonStyle(color: .blue))
                            
                            Button("😢 Cry") {
                                deviceBrain.simulateCrying()
                            }
                            .buttonStyle(ToyButtonStyle(color: .orange))
                            
                            Button("🛑 Sleep") {
                                Task { await deviceBrain.goToSleep() }
                            }
                            .buttonStyle(ToyButtonStyle(color: .gray))
                        }
                        
                        // Mute toggle
                        Button(deviceBrain.isMuted ? "🔇 Unmute" : "🔊 Mute") {
                            Task { await deviceBrain.toggleMute() }
                        }
                        .buttonStyle(ToyButtonStyle(color: deviceBrain.isMuted ? .red : .green))
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    .padding()
                }
                
                // Activity Log
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(deviceBrain.activityLog.suffix(8), id: \.self) { log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.green.opacity(0.8))
                        }
                    }
                }
                .frame(height: 80)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            deviceBrain.startSensors()
        }
    }
}

// MARK: - Toy State
enum ToyState: String, Codable {
    case sleeping = "sleeping"
    case waking = "waking"
    case listening = "listening"
    case thinking = "thinking"
    case speaking = "speaking"
    case comforting = "comforting"
    case playingMelody = "melody"
    
    var emoji: String {
        switch self {
        case .sleeping: return "😴"
        case .waking: return "🥱"
        case .listening: return "👂"
        case .thinking: return "🤔"
        case .speaking: return "🗣️"
        case .comforting: return "🤗"
        case .playingMelody: return "🎵"
        }
    }
    
    var displayName: String {
        switch self {
        case .sleeping: return "Sleeping..."
        case .waking: return "Waking up..."
        case .listening: return "Listening"
        case .thinking: return "Thinking..."
        case .speaking: return "Speaking"
        case .comforting: return "Comforting"
        case .playingMelody: return "Playing Melody"
        }
    }
    
    var color: Color {
        switch self {
        case .sleeping: return .gray
        case .waking: return .yellow
        case .listening: return .blue
        case .thinking: return .purple
        case .speaking: return .green
        case .comforting: return .pink
        case .playingMelody: return .yellow
        }
    }
}

// MARK: - Toy Brain (Main Logic)
@MainActor
class DeviceBrain: NSObject, ObservableObject {
    // UI State
    @Published var state: ToyState = .sleeping
    @Published var statusMessage = "Shake me to wake up!"
    @Published var childName: String?
    @Published var parentConnected = false
    @Published var activityLog: [String] = []
    @Published var showDebug = true // Set to false for production
    
    // ElevenLabs State
    @Published var isAgentConnected = false
    @Published var agentState: ElevenLabs.AgentState = .listening
    @Published var isMuted = false
    @Published var lastAgentMessage: String?
    
    // ElevenLabs conversation
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()
    
    // Core components
    private let motionManager = CMMotionManager()
    private var cryDetectionEngine: AVAudioEngine?
    
    // Peer connectivity
    private var peerSession: MCSession?
    private var peerID: MCPeerID!
    private var advertiser: MCNearbyServiceAdvertiser?
    
    // ⚠️ CONFIGURE THIS:
    let ELEVENLABS_AGENT_ID = "" // Create at elevenlabs.io/conversational-ai
    
    // Conversation memory (persisted to UserDefaults)
    var conversationMemory: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: "szumis_memory") as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: "szumis_memory") }
    }
    
    override init() {
        super.init()
        setupPeerConnectivity()
        setupAudioSession()
        
        // Load saved child name
        childName = conversationMemory["childName"]
    }
    
    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        activityLog.append("[\(timestamp)] \(message)")
        print("🧸 \(message)")
    }
    
    // MARK: - ElevenLabs Conversation
    
    func startElevenLabsConversation() async {
        guard ELEVENLABS_AGENT_ID != "" else {
            log("⚠️ Set your ElevenLabs Agent ID!")
            statusMessage = "Configure Agent ID"
            return
        }
        
        // IMPORTANT: Stop cry detection - ElevenLabs needs the microphone
        stopCryDetection()
        
        do {
            log("🤖 Starting AI conversation...")
            state = .waking
            statusMessage = "Connecting to AI..."
            
            // Build dynamic prompt based on memory
            var systemPrompt = """
            You are hummy, a friendly AI teddy bear companion for children. 
            You speak in a warm, gentle, playful voice appropriate for young children.
            Keep responses short (1-2 sentences) and engaging.
            You can tell stories, sing lullabies, play games, and comfort children.
            """
            
            if let name = childName {
                systemPrompt += "\nYou are talking to a child named \(name). Use their name occasionally to make it personal."
            } else {
                systemPrompt += "\nYou don't know the child's name yet. Ask them their name early in the conversation in a friendly way."
            }
            
            // Configure conversation with custom prompt
            // Note: Check ElevenLabs SDK docs for exact API - this uses basic config
            let config = ConversationConfig()
            
            conversation = try await ElevenLabs.startConversation(
                agentId: ELEVENLABS_AGENT_ID,
                config: config
            )
            
            // Send system prompt as first message if needed
            // try? await conversation?.sendMessage(systemPrompt)
            
            setupConversationObservers()
            
            log("✅ AI conversation started!")
            isAgentConnected = true
            state = .listening
            statusMessage = "Listening..."
            
            sendToParent(ToyMessage(type: .wakeUp, data: ["trigger": "shake"]))
            
        } catch {
            log("❌ Failed to start AI: \(error.localizedDescription)")
            statusMessage = "AI connection failed"
            state = .sleeping
        }
    }
    
    private func setupConversationObservers() {
        guard let conversation else { return }
        
        // Connection state
        conversation.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .idle:
                    self.isAgentConnected = false
                case .connecting:
                    self.log("🔄 Connecting...")
                case .active(let info):
                    self.isAgentConnected = true
                    self.log("✅ Connected to agent: \(info.agentId)")
                case .ended(let reason):
                    self.isAgentConnected = false
                    self.log("🔚 Conversation ended: \(reason)")
                case .error(let error):
                    self.isAgentConnected = false
                    self.log("❌ Error: \(error)")
                }
            }
            .store(in: &cancellables)
        
        // Agent state (speaking/listening)
        conversation.$agentState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] agentState in
                guard let self else { return }
                self.agentState = agentState
                
                switch agentState {
                case .listening:
                    self.state = .listening
                    self.statusMessage = "Listening..."
                case .speaking:
                    self.state = .speaking
                    self.statusMessage = "Speaking..."
                case .thinking:
                    self.state = .thinking
                    self.statusMessage = "Thinking..."
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Messages
        conversation.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self, let lastMessage = messages.last else { return }
                
                if lastMessage.role == .agent {
                    self.lastAgentMessage = lastMessage.content
                    self.log("🤖 Agent: \(lastMessage.content.prefix(50))...")
                    
                    // Try to extract child's name from conversation
                    self.extractChildNameIfNeeded(from: messages)
                } else {
                    self.log("👶 Child: \(lastMessage.content.prefix(50))...")
                }
            }
            .store(in: &cancellables)
        
        // Mute state
        conversation.$isMuted
            .receive(on: DispatchQueue.main)
            .assign(to: &$isMuted)
    }
    
    private func extractChildNameIfNeeded(from messages: [Message]) {
        guard childName == nil else { return }
        
        // Look for name patterns in user messages
        for message in messages where message.role == .user {
            let content = message.content.lowercased()
            
            // Common patterns: "my name is X", "I'm X", "call me X"
            let patterns = [
                "my name is ",
                "i'm ",
                "i am ",
                "call me ",
                "jestem ",  // Polish: "I am"
                "mam na imię " // Polish: "my name is"
            ]
            
            for pattern in patterns {
                if let range = content.range(of: pattern) {
                    let afterPattern = content[range.upperBound...]
                    let words = afterPattern.split(separator: " ")
                    if let firstName = words.first {
                        let name = String(firstName).capitalized
                            .trimmingCharacters(in: .punctuationCharacters)
                        if name.count > 1 && name.count < 20 {
                            childName = name
                            conversationMemory["childName"] = name
                            log("👶 Learned child name: \(name)")
                            sendToParent(ToyMessage(type: .childInfo, data: ["name": name]))
                            return
                        }
                    }
                }
            }
        }
    }
    
    func toggleMute() async {
        try? await conversation?.toggleMute()
    }
    
    func sendTextMessage(_ text: String) async {
        try? await conversation?.sendMessage(text)
    }
    
    func endElevenLabsConversation() async {
        await conversation?.endConversation()
        conversation = nil
        cancellables.removeAll()
        isAgentConnected = false
        lastAgentMessage = nil
    }
    
    // MARK: - Peer Connectivity (Phone-to-Phone)
    
    private func setupPeerConnectivity() {
        peerID = MCPeerID(displayName: "SzumisToy")
        peerSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        peerSession?.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "szumis-ai")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        log("📡 Advertising to parent app...")
    }
    
    func sendToParent(_ message: ToyMessage) {
        guard let session = peerSession, !session.connectedPeers.isEmpty else { return }
        
        if let data = try? JSONEncoder().encode(message) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    // MARK: - Audio Session
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            log("🔊 Audio session ready")
        } catch {
            log("❌ Audio setup failed: \(error)")
        }
    }
    
    // MARK: - Motion Detection (Shake to Wake)
    
    func startSensors() {
        guard motionManager.isAccelerometerAvailable else {
            log("❌ Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            let magnitude = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            
            // Detect shake (threshold ~2.5g)
            if magnitude > 2.5 && self.state == .sleeping {
                self.onShakeDetected()
            }
        }
        
        log("📱 Motion sensors active")
        startCryDetection()
    }
    
    func simulateShake() {
        if state == .sleeping {
            onShakeDetected()
        }
    }
    
    private func onShakeDetected() {
        log("🤝 Shake detected - waking up!")
        
        Task {
            await startElevenLabsConversation()
        }
    }
    
    // MARK: - Cry Detection with Apple Sound Analysis ML
    
    private var soundClassifier: SNClassifySoundRequest?
    private var audioAnalyzer: SNAudioStreamAnalyzer?
    
    private func startCryDetection() {
        // Don't start if ElevenLabs is active (it needs the mic)
        guard !isAgentConnected else {
            log("⏸️ Cry detection paused - AI active")
            return
        }
        
        // Stop existing engine first
        stopCryDetection()
        
        // Setup audio engine for sound analysis
        cryDetectionEngine = AVAudioEngine()
        guard let engine = cryDetectionEngine else { return }
        
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Create Sound Analysis analyzer
        audioAnalyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        
        // Create classification request for built-in sound classifier
        do {
            soundClassifier = try SNClassifySoundRequest(classifierIdentifier: .version1)
            soundClassifier?.windowDuration = CMTimeMakeWithSeconds(1.5, preferredTimescale: 48000)
            
            try audioAnalyzer?.add(soundClassifier!, withObserver: self)
            log("🧠 ML cry detection ready")
        } catch {
            log("⚠️ ML classifier failed: \(error), using fallback")
            // Will use fallback detection
        }
        
        // Install audio tap
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: recordingFormat) { [weak self] buffer, time in
            // Feed audio to ML analyzer
            self?.audioAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
        
        do {
            try engine.start()
            log("👂 Cry detection active (ML-powered)")
        } catch {
            log("❌ Cry detection failed: \(error)")
        }
    }
    
    private func stopCryDetection() {
        if cryDetectionEngine != nil {
            cryDetectionEngine?.inputNode.removeTap(onBus: 0)
            cryDetectionEngine?.stop()
            cryDetectionEngine = nil
            audioAnalyzer = nil
            soundClassifier = nil
            log("⏹️ Cry detection stopped")
        }
    }
    
    private var cryDetectionCooldown = false
    
    func simulateCrying() {
        onCryingDetected(confidence: 0.95)
    }
    
    private func onCryingDetected(confidence: Double = 0.8) {
        guard !cryDetectionCooldown else { return }
        cryDetectionCooldown = true
        
        log("😢 Crying detected! (confidence: \(Int(confidence * 100))%)")
        
        // Notify parent immediately with confidence
        sendToParent(ToyMessage(type: .cryingDetected, data: [
            "intensity": confidence > 0.8 ? "high" : "medium",
            "confidence": String(format: "%.0f", confidence * 100)
        ]))
        
        // If conversation is active, send comfort message
        if isAgentConnected {
            Task {
                // Send a prompt to make the agent comfort the child
                try? await conversation?.sendMessage(
                    "[The child seems to be crying or upset. Please comfort them with soothing words and maybe offer to sing a lullaby or tell a calming story.]"
                )
            }
        } else {
            // Wake up and comfort
            Task {
                await startElevenLabsConversation()
            }
        }
        
        state = .comforting
        statusMessage = "Comforting..."
        
        // Cooldown
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.cryDetectionCooldown = false
        }
    }
    
    // MARK: - Sleep
    
    func goToSleep() async {
        log("😴 Going to sleep")
        
        await endElevenLabsConversation()
        
        state = .sleeping
        statusMessage = "Shake me to wake up!"
        
        // Restart cry detection now that ElevenLabs released the mic
        startCryDetection()
        
        sendToParent(ToyMessage(type: .sleeping, data: [:]))
    }
    
    // MARK: - Handle Parent Commands
    
    func handleParentCommand(_ command: ParentCommand) {
        log("📥 Parent command: \(command.type)")
        
        Task {
            switch command.type {
            case .wake:
                if state == .sleeping {
                    await startElevenLabsConversation()
                }
                
            case .sleep:
                await goToSleep()
                
            case .tellStory:
                if isAgentConnected {
                    let topic = command.data["topic"] ?? "adventure"
                    try? await conversation?.sendMessage(
                        "Please tell me a short \(topic) story!"
                    )
                }
                
            case .playMelody:
                if isAgentConnected {
                    try? await conversation?.sendMessage(
                        "Can you sing me a lullaby?"
                    )
                }
                
            case .speak:
                if let text = command.data["text"], isAgentConnected {
                    try? await conversation?.sendMessage(text)
                }
                
            case .setMotherVoice:
                log("👩 Mother voice requested")
                // In production: implement voice ID switching
                
            case .comfort:
                if isAgentConnected {
                    try? await conversation?.sendMessage(
                        "[Please comfort the child with soothing words]"
                    )
                } else {
                    await startElevenLabsConversation()
                }
            }
        }
    }
}

// MARK: - MCSession Delegate
extension DeviceBrain: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            self.parentConnected = state == .connected
            self.log("📱 Parent \(state == .connected ? "connected" : "disconnected")")
        }
    }
    
    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let command = try? JSONDecoder().decode(ParentCommand.self, from: data) {
            Task { @MainActor in
                self.handleParentCommand(command)
            }
        }
    }
    
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiser Delegate
extension DeviceBrain: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor in
            log("📨 Invitation from \(peerID.displayName)")
            invitationHandler(true, self.peerSession)
        }
    }
}

// MARK: - Sound Analysis Delegate (ML Cry Detection)
extension DeviceBrain: SNResultsObserving {
    nonisolated func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        
        // Look for crying-related classifications
        // Apple's classifier includes: "crying_baby", "child_crying", "whimpering"
        let cryingLabels = ["crying_baby", "baby_crying", "child_crying", "crying", "whimpering", "sobbing"]
        
        for classification in classificationResult.classifications {
            let identifier = classification.identifier.lowercased()
            let confidence = classification.confidence
            
            // Check if it's a crying sound with high confidence
            if cryingLabels.contains(where: { identifier.contains($0) }) && confidence > 0.5 {
                Task { @MainActor in
                    self.log("🔊 Detected: \(identifier) (\(Int(confidence * 100))%)")
                    self.onCryingDetected(confidence: confidence)
                }
                return
            }
        }
    }
    
    nonisolated func request(_ request: SNRequest, didFailWithError error: Error) {
        Task { @MainActor in
            self.log("⚠️ Sound analysis error: \(error.localizedDescription)")
        }
    }
}

struct ToyMessage: Codable {
    let type: ToyMessageType
    let data: [String: String]
    var timestamp = Date()
}

enum ToyMessageType: String, Codable {
    case wakeUp
    case sleeping
    case cryingDetected
    case childInfo
    case speaking
    case storyStarted
}

struct ParentCommand: Codable {
    let type: ParentCommandType
    let data: [String: String]
}

enum ParentCommandType: String, Codable {
    case wake
    case sleep
    case tellStory
    case playMelody
    case speak
    case setMotherVoice
    case comfort
}

// MARK: - Button Style
struct ToyButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(color.opacity(configuration.isPressed ? 0.5 : 0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
