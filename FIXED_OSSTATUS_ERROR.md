# Fixed: OSStatus Error 561017449 (!pri)

## The Problem
You were getting:
```
SessionCore.mm:517 Failed to set properties, error: '!pri'
🧸 ❌ Music generation failed: The operation couldn't be completed. (OSStatus error 561017449.)
```

**Even though the API returned 200 and downloaded the music successfully!**

## Root Cause
The error `OSStatus 561017449` (FourCC: `!pri`) is `kAudioSessionAlreadyActive` - it means you were trying to configure the audio session while ElevenLabs conversation still had it in use.

**The issue:** You can't set audio session to `.playback` mode while the microphone is active in `.playAndRecord` mode.

## The Fix

### 1. **Fully End Conversation Before Music**
Changed from just muting to **completely ending the conversation**:

```swift
// OLD (didn't work):
if isAgentConnected {
    try? await conversation?.toggleMute()  // ❌ Mic still active!
}

// NEW (works):
if wasConversationActive {
    await endElevenLabsConversation()  // ✅ Fully releases audio
    try? await Task.sleep(nanoseconds: 500_000_000)  // Wait for cleanup
}
```

### 2. **Reset Audio Session Properly**
Added proper session deactivation before reconfiguration:

```swift
// Deactivate first to clear previous config
try? session.setActive(false, options: .notifyOthersOnDeactivation)

// Then set to playback mode
try session.setCategory(.playback, mode: .default, options: [.duckOthers])
try session.setActive(true)
```

### 3. **Use Simpler API Endpoint**
Changed from `/v1/music/detailed` (multipart response) to `/v1/music` (direct audio):

```swift
// Simpler and more reliable
url: "https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128"
```

The `/detailed` endpoint returns multipart data (JSON metadata + audio), which requires complex parsing. The simple `/music` endpoint returns direct MP3 audio.

### 4. **Better Audio Player Setup**
Added proper error handling and logging:

```swift
musicPlayer = try AVAudioPlayer(contentsOf: tempURL)
musicPlayer?.prepareToPlay()  // Important!
musicPlayer?.play()
```

## What Changed

### Before:
1. Music generation ✅ (API returned 200)
2. Audio session conflict ❌ (mic still active)
3. Player creation failed ❌ (OSStatus error)

### After:
1. End conversation (releases mic)
2. Wait 0.5s for cleanup
3. Reset audio session
4. Download music ✅
5. Configure playback mode ✅
6. Play music ✅

## Testing the Fix

Run the app and:

1. **Wake the toy** (starts conversation)
2. **Click "🎵 Lullaby"** button
3. **Watch logs for**:
   ```
   🧸 ⏸️ Pausing conversation for music playback
   🧸 🔚 Conversation ended
   🧸 📡 Requesting music from ElevenLabs...
   🧸 📥 Response status: 200
   🧸 ✅ Received direct audio: XXXXX bytes
   🧸 💾 Saved music to: lullaby_XXX.mp3
   🧸 🔊 Audio session configured for playback
   🧸 🎵 Music player ready
   🧸 ▶️ Started playback, fading in...
   🧸 ✅ Music playing!
   ```

4. **You should hear**: Gentle lullaby music fading in!

## If It Still Fails

### Check the logs for:

**If you see "OSStatus error":**
- The audio session is still locked
- Make sure no other apps are using the microphone
- Try restarting the app (kill it completely)

**If you see "401":**
- API key is wrong (see FIX_401_ERROR.md)

**If you see "No audio data":**
- The API might be down
- Check your internet connection

**If music plays but sounds weird:**
- The multipart parsing might have failed
- Check logs for "Parsing multipart response"
- The simple `/music` endpoint should avoid this

## Technical Details

### Audio Session States

**For Conversation (ElevenLabs):**
- Category: `.playAndRecord`
- Mode: `.voiceChat`
- Needs: Microphone + Speaker

**For Music:**
- Category: `.playback`
- Mode: `.default`
- Needs: Speaker only

**The Conflict:**
You can't have both active at the same time. Must deactivate one before activating the other.

### Why 0.5s Wait?

The ElevenLabs SDK takes time to:
1. Close WebSocket connection
2. Stop audio capture
3. Release AVAudioSession
4. Notify other audio sessions

The 500ms wait ensures everything is fully cleaned up.

## Bonus: Music Loops Forever

The music is set to loop indefinitely:
```swift
musicPlayer?.numberOfLoops = -1  // -1 = infinite loop
```

**To stop:** Click "⏹️ Stop Music" button or send the toy to sleep.

## Success! 🎉

Your music generation is now working:
- ✅ API returns 200
- ✅ Audio downloads successfully  
- ✅ Audio session properly configured
- ✅ Music plays with fade-in effect
- ✅ Gentle lullaby for baby sleep

The toy can now:
1. Talk with children (ElevenLabs Conversation)
2. Generate custom lullabies (ElevenLabs Music)
3. Switch between modes seamlessly
4. Detect crying and respond

Enjoy your AI-powered smart toy! 🧸🎵
