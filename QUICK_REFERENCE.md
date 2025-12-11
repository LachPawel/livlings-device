# 🎯 Quick Reference: Client Tools

## Available Tools

| Tool | Purpose | Example Call |
|------|---------|--------------|
| `remember` | Store info about child | `remember("child_name", "Emma")` |
| `notify_parent` | Send alert to parent | `notify_parent("Child scared", "high")` |
| `play_sound` | Play ambient sounds | `play_sound("heartbeat")` |
| `play_lullaby` | Generate music | `play_lullaby("piano")` |

---

## Sound Types

| Type | Description | Use When |
|------|-------------|----------|
| `heartbeat` | Calm rhythmic heartbeat | Child scared, anxious |
| `rain` | Gentle rain on window | Can't sleep, wants calm |
| `ocean` | Soft waves on shore | Relaxation needed |
| `white_noise` | Consistent static | General calming |
| `forest` | Birds, breeze, nature | Nature lover, peaceful |
| `stars` | Magical twinkling | Dreamy, magical requests |

---

## Lullaby Styles

| Style | Description | Use When |
|-------|-------------|----------|
| `music_box` | Classic wind-up box | Traditional, nostalgic |
| `piano` | Solo gentle piano | Modern, minimalist |
| `harp` | Celtic ethereal harp | Magical, dreamy |
| `strings` | Soft string orchestra | Warm, classical |
| `classical` | Brahms-style | Traditional classical |
| `default` | General instrumental | Any request |

---

## Priority Levels

| Priority | When to Use | Parent Action |
|----------|-------------|---------------|
| `high` | Urgent: scared, hurt, very upset | Immediate alert |
| `normal` | Info: can't sleep, needs comfort | Standard notification |
| `low` | FYI: learned name, having fun | Gentle update |

---

## Common Scenarios

### Child Introduction
```
Child: "My name is Emma"
Agent calls: remember("child_name", "Emma")
Result: Name stored, parent notified
```

### Child Scared
```
Child: "I'm scared of monsters"
Agent calls: 
  1. notify_parent("Emma scared of monsters", "high")
  2. play_sound("heartbeat")
Result: Parent alerted + heartbeat plays
```

### Bedtime Request
```
Child: "Can you sing me a song?"
Agent calls: play_lullaby("piano")
Result: Piano lullaby generates & plays
```

### Can't Sleep
```
Child: "I can't sleep"
Agent calls:
  1. play_sound("rain")
  2. play_lullaby("music_box")
Result: Rain plays, then transitions to lullaby
```

---

## API Endpoints Used

### Sound Generation
```
POST https://api.elevenlabs.io/v1/sound-generation
Body: {"text": "prompt", "duration_seconds": 30}
```

### Music Generation
```
POST https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128
Body: {"prompt": "...", "music_length_ms": 60000, "force_instrumental": true}
```

---

## Debugging

### Check Tool Calls
Look for logs:
```
🔧 Tool called: remember
🔧 Tool called: play_sound
🔧 Tool called: play_lullaby
```

### Check Execution
Look for logs:
```
💾 Remembered: child_name = Emma
📬 Notifying parent: Emma is scared [priority: high]
🔊 Playing sound: heartbeat
🎵 Generating piano lullaby...
```

### Check Results
```
✅ Sound playing: heartbeat
✅ Lullaby playing: piano
```

---

## State Indicators

| State | Emoji | When |
|-------|-------|------|
| Sleeping | 😴 | Idle, no activity |
| Waking | 🥱 | Starting conversation |
| Listening | 👂 | Ready for voice input |
| Thinking | 🤔 | Processing response |
| Speaking | 🗣️ | Agent talking |
| Comforting | 🤗 | Comforting child |
| Playing Melody | 🎵 | Lullaby playing |
| Playing Sound | 💓 | Ambient sound playing |

---

## Memory Keys (Suggested)

| Key | Example Value | Purpose |
|-----|---------------|---------|
| `child_name` | "Emma" | Child's name (auto-used in prompts) |
| `age` | "5" | Child's age |
| `favorite_color` | "purple" | Personalization |
| `favorite_animal` | "elephant" | Conversation context |
| `bedtime` | "8pm" | Schedule awareness |
| `fears` | "dark" | Contextual support |

---

## Parent App Messages

### Notification Example
```json
{
  "type": "notification",
  "data": {
    "message": "Emma is scared of dark",
    "priority": "high",
    "child_name": "Emma"
  }
}
```

### Sound Playing
```json
{
  "type": "storyStarted",
  "data": {
    "type": "sound",
    "sound_type": "heartbeat"
  }
}
```

### Lullaby Playing
```json
{
  "type": "storyStarted",
  "data": {
    "type": "lullaby",
    "style": "piano"
  }
}
```

---

## Testing Commands

Say these to test each tool:

| Command | Tests |
|---------|-------|
| "My name is Emma" | `remember` |
| "I'm scared" | `notify_parent` + `play_sound` |
| "Play heartbeat sounds" | `play_sound` |
| "Sing me a lullaby" | `play_lullaby` |
| "I love elephants" | `remember("favorite_animal")` |
| "I can't sleep" | Multiple tools |

---

## Configuration Checklist

### ElevenLabs Dashboard
- [ ] Agent created
- [ ] Tool 1: remember (added)
- [ ] Tool 2: notify_parent (added)
- [ ] Tool 3: play_sound (added)
- [ ] Tool 4: play_lullaby (added)
- [ ] System prompt updated with tool usage
- [ ] Agent tested in playground

### Code
- [x] ClientToolsHandler.swift added
- [x] DeviceBrain updated
- [x] Tools handler initialized
- [x] Conversation callback configured
- [x] Sound generation added
- [x] Lullaby generation added

### Testing
- [ ] Remember tool works
- [ ] Notifications send to parent
- [ ] Sounds generate and play
- [ ] Lullabies generate and play
- [ ] Multiple tools in one conversation
- [ ] Memory persists across wake/sleep

---

## 🎉 You're Ready!

All client tools are integrated and ready to use. Configure your agent on the ElevenLabs dashboard and start testing!
