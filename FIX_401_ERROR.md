er# How to Fix 401 Authentication Error

## The Problem
You're getting "Music API error: Status: 401" which means your API key is **not valid** or **not being accepted** by ElevenLabs.

## Step-by-Step Fix

### 1. Test Your API Key First
I've added a "🔑 Test Key" button in the debug controls. **Click it first** before trying to generate music. This will tell you if your API key is valid.

The logs will show:
- ✅ "API key is VALID!" - Your key works, proceed to music generation
- ❌ "API key is INVALID! Status: 401" - Your key is wrong, follow steps below

### 2. Get a Fresh API Key

1. **Go to ElevenLabs API Keys page:**
   https://elevenlabs.io/app/settings/api-keys

2. **Create a NEW API key:**
   - Click "+ Create"
   - Copy the ENTIRE key (starts with `sk_`)
   - It should look like: `sk_abc123def456...` (around 48 characters)

3. **IMPORTANT: Copy it immediately!**
   - You can only see the full key once
   - If you lost it, you must create a new one

### 3. Check Your Subscription

The Music API requires a **paid subscription**. Free plans don't have access to music generation.

1. **Check your plan:**
   https://elevenlabs.io/app/subscription

2. **Required plan:**
   - You need at least a **Creator** or **Pro** plan
   - Music generation is NOT available on the free tier

3. **If you're on free tier:**
   - Upgrade to Creator or Pro
   - OR use the Text-to-Speech API instead for voice responses

### 4. Update Your Code

Replace the API key in `DeviceMainView.swift`:

```swift
let ELEVENLABS_API_KEY = "sk_YOUR_NEW_KEY_HERE"
```

**Make sure:**
- No extra spaces
- No quotes inside the string
- Entire key is copied
- Key starts with `sk_`

### 5. Verify the Fix

1. **Rebuild the app** (Cmd+B)
2. **Run it** (Cmd+R)
3. **Click "🔑 Test Key"** button
4. **Check the logs** for ✅ success message
5. **Try "🎵 Lullaby"** button

## Common Mistakes

### ❌ Swapped Agent ID and API Key
```swift
// WRONG:
let ELEVENLABS_AGENT_ID = "sk_abc123..." // ← API key in wrong place
let ELEVENLABS_API_KEY = "agent_xyz..."  // ← Agent ID in wrong place

// CORRECT:
let ELEVENLABS_AGENT_ID = "agent_xyz..."  // ← Starts with "agent_"
let ELEVENLABS_API_KEY = "sk_abc123..."   // ← Starts with "sk_"
```

### ❌ Partial Key Copied
Make sure you copy the ENTIRE key, not just part of it.

### ❌ Free Tier Account
Music API requires a paid subscription. Upgrade at:
https://elevenlabs.io/pricing

### ❌ Expired API Key
If you deleted or regenerated the key on the website, you need to update your code.

## Test with curl

You can verify your API key works outside the app:

```bash
curl -X POST "https://api.elevenlabs.io/v1/music/detailed" \
  -H "Content-Type: application/json" \
  -H "xi-api-key: sk_YOUR_KEY_HERE" \
  -d '{"prompt":"test music","music_length_ms":10000,"model_id":"music_v1","force_instrumental":true}'
```

**Expected result:**
- ✅ Status 200 = Key works, returns audio
- ❌ Status 401 = Key is invalid
- ❌ Status 403 = Key valid but no permission (need paid plan)

## Still Not Working?

### Check the Logs
Look for these specific messages in Xcode console:

```
🔑 Using API key: sk_ce463fb8...
📥 Response status: 401
❌ API Error - Status: 401
```

### Contact ElevenLabs Support
If your key tests valid with curl but fails in the app:
1. Email: support@elevenlabs.io
2. Include: "Music API returns 401 with valid key"
3. Mention: You're using the Swift SDK

## Alternative: Use Voice Instead

If music API doesn't work, you can have the agent SING instead:

```swift
case .playMelody:
    if isAgentConnected {
        try? await conversation?.sendMessage(
            "Can you sing me a gentle lullaby to help me fall asleep?"
        )
    }
```

This uses your conversation agent instead of the music API, so it works with the Conversational AI plan.

## Summary

1. ✅ Click "🔑 Test Key" button
2. ✅ Check your ElevenLabs subscription (must be paid)
3. ✅ Get a fresh API key from elevenlabs.io/app/settings/api-keys
4. ✅ Update `ELEVENLABS_API_KEY` in code
5. ✅ Rebuild and test again

---

**Your current key:** `sk_ce463fb88494cfcd27dd5562b56418fc634efdf71a68aea0`

If the "Test Key" button shows this is valid but music still fails, the issue is likely:
- Your subscription doesn't include music API access
- The music API is temporarily down (check status.elevenlabs.io)
