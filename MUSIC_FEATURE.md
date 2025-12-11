# Sleep Music Feature 🎵

## Overview
The app now includes AI-generated sleep music for babies using ElevenLabs Music API. The toy can generate soothing lullabies on demand to help calm and comfort children.

## Setup

1. **Get your ElevenLabs API Key**
   - Go to [elevenlabs.io/app/settings/api-keys](https://elevenlabs.io/app/settings/api-keys)
   - Create a new API key
   - Copy the key

2. **Configure the app**
   Open `DeviceMainView.swift` and set:
   ```swift
   let ELEVENLABS_API_KEY = "your_api_key_here"
   ```

## Features

### On-Demand Lullaby Generation
- **60-second instrumental lullabies** generated in real-time
- **AI-composed music** with gentle piano, soft strings, and peaceful ambient sounds
- **Automatic audio management** - pauses conversation and cry detection during playback

### Triggers
1. **Parent App Command**: Parent can trigger lullaby via `ParentCommandType.playMelody`
2. **Debug Button**: Use the "🎵 Lullaby" button in debug controls
3. **Crying Detection**: (Optional) Modify cry detection to auto-play music

### How It Works

1. **Generation**: When triggered, the app sends a POST request to ElevenLabs Music API with a carefully crafted prompt for baby sleep music
2. **Playback**: Generated music is saved temporarily and played through the device speaker
3. **State Management**: 
   - Stops conversation if active
   - Pauses cry detection during playback
   - Shows "Playing Melody" state with 🎵 emoji
4. **Auto-Resume**: After music finishes, returns to previous state (listening or sleeping)

### Music Parameters

Current settings (customizable in `generateSleepMusic()`):
- **Duration**: 60 seconds (adjustable via `music_length_ms`)
- **Style**: Gentle calming lullaby, soft piano and strings
- **Tempo**: Slow and soothing
- **Mode**: Instrumental only (`force_instrumental: true`)

### Customization Options

You can modify the music prompt in the code:

```swift
let musicRequest: [String: Any] = [
    "prompt": "YOUR CUSTOM PROMPT HERE",
    "music_length_ms": 60000, // 30-120 seconds recommended
    "force_instrumental": true,
    "model_id": "music_v1"
]
```

**Example prompts:**
- `"Soft ambient nature sounds with gentle rain and wind chimes for baby sleep"`
- `"Classical music box lullaby with slow tempo and soft bells"`
- `"Gentle orchestral strings and harp, peaceful and dreamlike"`
- `"Calming white noise with subtle ocean waves and light piano"`

### API Costs
⚠️ **Note**: Each music generation request uses ElevenLabs API credits. Check your plan limits at elevenlabs.io

### Integration with Parent App

The toy sends a notification when music starts:
```swift
ToyMessage(type: .storyStarted, data: ["type": "lullaby"])
```

Parent app can trigger music:
```swift
ParentCommand(type: .playMelody, data: [:])
```

### UI Indicators

When music is playing:
- State changes to `playingMelody` (🎵)
- Status shows "Playing lullaby..."
- Stop button appears in debug controls
- Music player indicator visible

### Advanced: Custom Music Plans

For more control, you can use the `composition_plan` parameter with sections:

```swift
let musicRequest: [String: Any] = [
    "composition_plan": [
        "positive_global_styles": ["lullaby", "soft piano", "slow tempo"],
        "negative_global_styles": ["drums", "loud", "fast"],
        "sections": [
            [
                "section_name": "intro",
                "duration_ms": 15000,
                "positive_local_styles": ["gentle", "calm"],
                "negative_local_styles": [],
                "lines": []
            ],
            [
                "section_name": "main",
                "duration_ms": 45000,
                "positive_local_styles": ["soothing melody"],
                "negative_local_styles": [],
                "lines": []
            ]
        ]
    ],
    "music_length_ms": 60000,
    "force_instrumental": true,
    "model_id": "music_v1"
]
```

## Troubleshooting

### OSStatus Error 561017449 (!pri)
**FIXED!** This was caused by audio session conflicts. The fix:
- Now fully ends the conversation before playing music
- Properly resets the audio session
- Uses simpler `/v1/music` endpoint (not `/detailed`)
- See `FIXED_OSSTATUS_ERROR.md` for details

### "Configure API Key" message
- Make sure you've set `ELEVENLABS_API_KEY` in the code

### 401 Authentication Error
- Check your API key is valid
- Verify you have available credits
- Check network connection
- Review Xcode console for detailed error messages

### No sound during playback
- Ensure device volume is up
- Check audio session is configured (should be automatic)
- Verify the music file was generated (check temp directory)

### Music doesn't stop conversation
- This is intentional - conversation is paused during music playback

## Future Enhancements

Potential improvements:
- **Music library**: Cache generated lullabies for instant playback
- **Style selection**: Let parent choose music style (classical, nature sounds, etc.)
- **Playlist mode**: Queue multiple songs
- **Sleep timer**: Auto-stop after X minutes
- **Volume control**: Fade in/out effects
- **Personalization**: Learn which music works best for each child
