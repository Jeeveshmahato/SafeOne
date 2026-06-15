# Women Safety App - Complete Testing Guide

## Table of Contents
1. [Initial Setup](#initial-setup)
2. [Emergency Contacts Management](#emergency-contacts-management)
3. [Settings Configuration](#settings-configuration)
4. [SOS (Emergency Alert)](#sos-emergency-alert)
5. [Check-In (I'm Safe)](#check-in-im-safe)
6. [Siren](#siren)
7. [Flashlight](#flashlight)
8. [SOS Blink (Morse Code)](#sos-blink-morse-code)
9. [Audio Recording](#audio-recording)
10. [Safety Timer](#safety-timer)
11. [Follow Me (Live Tracking)](#follow-me-live-tracking)
12. [Emergency Helplines](#emergency-helplines)
13. [Share Location](#share-location)
14. [Fake Call (Upgraded)](#fake-call-upgraded)
15. [Safety Tips & First Aid](#safety-tips--first-aid)
16. [Hide App (Decoy Calculator)](#hide-app-decoy-calculator)
17. [Medical Information](#medical-information)
18. [Nearby Help](#nearby-help)

---

## Initial Setup

### Prerequisites
- App installed and running on your device
- At least one emergency contact to test SOS/Check-in features

### Steps to Start
1. Open the Women Safety app
2. You should see the **Home Screen** with:
   - Large red "SOS" button in the center
   - A grid of 10 feature tiles below it
   - Settings icon (gear) in the top-right

---

## Emergency Contacts Management

This is the **first feature** you must set up before testing other features.

### Location
- Tap the **"Contacts"** tile in the grid, OR
- Add contacts: Tap the "Add" button (bottom-right floating action button)

### How to Add a Contact

**Step-by-step:**
1. From Home Screen, tap the **"Contacts"** tile
2. Tap the **"Add"** button (blue floating action button at bottom)
3. A popup dialog appears with two fields:
   - **Name**: Enter the person's name (e.g., "Mom", "Best Friend")
   - **Phone number**: Enter their full phone number (e.g., "+91-98765-43210")
4. Tap **"Save"** to save the contact

**Expected behavior:**
- Contact appears in the list below the "Add" button
- Each contact shows:
  - A person icon (avatar)
  - Name and phone number
  - Red delete icon on the right
- Message appears: "No contacts yet..." disappears after adding first contact
- Success message at bottom (optional)

### How to View Contacts

1. Tap the **"Contacts"** tile from Home Screen
2. All saved contacts appear as a scrollable list
3. Each contact shows:
   - Person icon
   - Name (title)
   - Phone number (subtitle)
   - Red delete button

### How to Delete a Contact

1. Go to Contacts Screen
2. Find the contact you want to remove
3. Tap the red **delete icon** on the right
4. Contact is removed immediately

**Test Case:**
- ✓ Add at least 2 contacts (required for testing SOS/Check-in)
- ✓ Verify contacts save properly
- ✓ Test deleting and re-adding a contact
- ✓ Try empty phone number (should show error "Please enter a phone number")
- ✓ Try empty name (should show error "Please enter a name")

---

## Settings Configuration

### Location
- Home Screen → Tap **Settings icon** (gear icon, top-right), OR
- Home Screen → Tap **"Contacts"** → Go back → Tap Settings

### Settings Available

#### 1. SOS Countdown Length

**What it does:**
- Controls how long you have to cancel an SOS before it's sent
- Higher countdown = more time to cancel
- Lower countdown = faster alert

**How to Test:**
1. Go to Settings
2. Under "SOS countdown length" section, select from:
   - **3 seconds** (fast)
   - **5 seconds** (medium)
   - **10 seconds** (default)
   - **15 seconds** (slow)
3. Tap your choice (a filled radio button confirms selection)
4. Go back to Home Screen
5. Test: Tap SOS button and verify the countdown duration matches

**Expected behavior:**
- Selected option shows as filled radio button
- Countdown dialog on SOS button reflects your choice

---

#### 2. Shake to Send SOS

**What it does:**
- When **ON**: Shaking your phone quickly triggers SOS countdown
- When **OFF**: Shake does nothing

**How to Test (if enabled):**
1. Go to Settings
2. Find **"Shake to send SOS"** toggle
3. Turn it **ON** (blue toggle)
4. Go back to Home Screen
5. **Shake your phone** in a quick motion
6. SOS countdown dialog should appear automatically

**Expected behavior:**
- Toggle switch shows state (ON = blue, OFF = gray)
- When ON: Shaking device starts SOS countdown
- When OFF: Shaking has no effect

**Note:** This feature works best on physical devices. Simulators may not detect shake properly.

---

#### 3. Custom SOS Message

**What it does:**
- Customize the message sent to contacts when SOS is triggered
- Use `{location}` placeholder where you want the map link to appear
- Message is sent via SMS

**How to Test:**
1. Go to Settings
2. Scroll to **"SOS message"** section
3. You'll see a text area with default message
4. Tap the text field and modify it
   - **Example:** "I'm in danger! Please call police immediately. {location}"
5. Changes save automatically as you type
6. Go back to Home Screen
7. Test: (Once contacts are set) Trigger SOS and verify the message received matches your custom message

**Default message:**
```
I'm in an unsafe situation. Please help me. {location}
```

**Expected behavior:**
- Text saves automatically (no Save button needed)
- `{location}` placeholder replaced with actual Google Maps link when SOS is sent
- Message appears exactly as typed (when viewing via SMS)

**Test Cases:**
- ✓ Add custom text before `{location}`
- ✓ Add custom text after `{location}`
- ✓ Add custom text both before and after
- ✓ Remove and re-add `{location}` in different positions
- ✓ Message saves when you leave Settings screen

---

## SOS (Emergency Alert)

### ⚠️ IMPORTANT
This feature sends SMS messages to all your emergency contacts. **Only test with real contacts who are expecting the alert** or use test contacts.

### Location
- **Big red "SOS" button** on Home Screen (center, top)

### How to Test

**Step-by-step:**
1. Ensure you have **at least 1 emergency contact** saved
2. Go to Home Screen
3. Tap the large red **"SOS"** button
4. A countdown dialog appears showing:
   - Time left (e.g., "10 seconds")
   - **Cancel** button (red)
   - Message about sending to all contacts
5. **Two options:**
   - **Option A (Test):** Tap **Cancel** before countdown ends
     - Message: "SOS cancelled"
     - No SMS sent
   - **Option B (Real):** Let countdown complete
     - SOS is sent to all contacts
     - Each contact receives an SMS with your message and location link

### Expected Behavior

**When you tap SOS:**
- Countdown dialog appears with chosen duration (e.g., 10 seconds)
- Countdown ticks down visually

**If you cancel (before time runs out):**
- Message: "SOS cancelled." (green notification at bottom)
- No SMS sent
- Back to Home Screen

**If time runs out (let countdown finish):**
- Spinner appears showing "Sending..."
- SOS sent to all emergency contacts
- Each contact gets SMS: Your custom message + location link
- Success message: "SOS alert sent to {number} contact(s)" (green)
- If failed: "Failed to send SOS" (red/orange)

### Test Cases

**Test 1: Cancel SOS**
- ✓ Tap SOS button
- ✓ Tap "Cancel" button in countdown
- ✓ Verify message "SOS cancelled."
- ✓ No SMS should be sent

**Test 2: Let SOS Complete**
- ✓ Tap SOS button
- ✓ Wait for countdown to finish
- ✓ Contacts should receive SMS with message and location link
- ✓ Verify success message appears

**Test 3: SOS with No Contacts**
- ✓ Delete all contacts
- ✓ Tap SOS button
- ✓ Error message appears: "Please add at least one emergency contact first."
- ✓ No countdown shown

---

## Check-In (I'm Safe)

### Location
- **"I'm safe"** tile in the grid (second row, first tile)

### What it Does
- Sends a reassuring "I've reached my destination safely" message to all contacts
- No countdown - sends immediately
- Useful for confirming you arrived safely

### How to Test

**Step-by-step:**
1. Ensure you have **at least 1 emergency contact** saved
2. From Home Screen, tap the **"I'm safe"** tile
3. Spinner appears briefly (showing "Sending...")
4. Contacts receive SMS: "I have reached safely."
5. Green notification appears: "Check-in message sent to {number} contact(s)"

**Expected behavior:**
- Tapping does NOT show countdown
- Message sends immediately
- No Cancel option
- Success message confirms delivery

### Test Cases

**Test 1: Check-in with Contacts**
- ✓ Have at least 1 contact saved
- ✓ Tap "I'm safe" tile
- ✓ Contacts receive SMS
- ✓ Green success message appears

**Test 2: Check-in with No Contacts**
- ✓ Delete all contacts
- ✓ Tap "I'm safe"
- ✓ Error message: "Please add at least one emergency contact first."
- ✓ No SMS sent

**Test 3: Multiple Check-ins**
- ✓ Tap "I'm safe" multiple times
- ✓ Each tap should send a new message

---

## Siren

### Location
- **"Siren"** tile in grid (first row, first tile)

### What it Does
- Plays a loud alarm siren sound to draw attention
- Useful to alert people nearby of danger
- Can be toggled on/off

### How to Test

**Step-by-step:**

**Turn Siren ON:**
1. From Home Screen, tap the **"Siren"** tile (first tile in grid)
2. Loud siren/alarm sound starts playing
3. Tile changes color to **orange** and text changes to **"Stop siren"**
4. Phone may vibrate (depends on settings)

**Turn Siren OFF:**
1. Tap the **"Stop siren"** tile (now orange)
2. Sound stops immediately
3. Tile returns to **original color** and text changes back to **"Siren"**

**Expected behavior:**
- Sound is loud and clear (alarm/siren type)
- Sound stops immediately when tapped
- Visual indicator (tile color/text) changes between ON/OFF states
- Sound doesn't interfere with other app functions

### Test Cases

- ✓ Tap Siren → sound plays
- ✓ Tap again → sound stops
- ✓ Toggle on/off multiple times
- ✓ Verify sound is loud enough to draw attention
- ✓ Test with phone on silent mode (may not play depending on device settings)
- ✓ Verify color change: Normal → Orange (when active)

---

## Flashlight

### Location
- **"Flashlight"** tile in grid (first row, middle tile)

### What it Does
- Turns on your phone's LED flashlight
- Useful to see in dark environments or as a distress signal
- Can be toggled on/off

### How to Test

**Step-by-step:**

**Turn Flashlight ON:**
1. From Home Screen, tap **"Flashlight"** tile
2. Your phone's LED flashlight turns **ON** (bright light from back of phone)
3. Tile changes to **orange** and text becomes **"Stop light"**

**Turn Flashlight OFF:**
1. Tap the **"Stop light"** tile (orange)
2. Flashlight turns **OFF**
3. Tile returns to **original color** and text changes to **"Flashlight"**

**Expected behavior:**
- LED is bright and stable
- Light turns on/off immediately
- Visual indicator (tile) shows current state
- Tile color change: Normal → Orange (when active)

### Test Cases

- ✓ Tap Flashlight → LED turns on
- ✓ Tap again → LED turns off
- ✓ Toggle multiple times
- ✓ Verify brightness is visible in dark environment
- ✓ If device has no flashlight: Error message "This phone has no flashlight."
- ✓ Test color change: Normal → Orange (when active)

---

## SOS Blink (Morse Code)

### Location
- **"SOS blink"** tile in grid (first row, right side — after Flashlight)

### What it Does
- Blinks the phone's LED flashlight in **Morse code "SOS"** pattern: `··· ––– ···` (dot dot dot, dash dash dash, dot dot dot)
- The international **distress signal** — recognizable anywhere
- Especially effective at night to signal for help
- Repeats the pattern until you tap Stop

### Prerequisites
- Phone must have a flashlight/LED
- Works best in dark environments

### How to Test

**Turn SOS Blink ON:**
1. From Home Screen, tap the **"SOS blink"** tile
2. Flashlight starts blinking in the Morse pattern
3. Tile changes to **orange** and text becomes **"Stop blink"**
4. In darkness, you'll see: quick flashes (S), longer flashes (O), quick flashes (S), then pause and repeat

**Turn SOS Blink OFF:**
1. Tap the **"Stop blink"** tile (orange)
2. Flashlight stops and turns off
3. Tile returns to **original color**

**Expected behavior:**
- Pattern is accurate: 3 quick, 3 long, 3 quick flashes
- Repeats continuously until stopped
- Visual tile indicator shows state (Normal → Orange)
- Torch is off when stopped

### Test Cases

- ✓ Tap "SOS blink" in dark room
- ✓ Verify Morse pattern is clear and repeating
- ✓ Tap again to stop
- ✓ Toggle on/off multiple times
- ✓ Verify pattern stays consistent
- ✓ If no flashlight: Error message "This phone has no flashlight."
- ✓ Test with Flashlight (only one can run at a time — switching stops the other)

---

## Audio Recording

### Location
- **"Record"** tile in grid (first row, right tile)

### What it Does
- Records audio using your phone's microphone
- Saves recording to phone storage
- Useful for documenting threats or evidence

### Prerequisites
- Microphone permission must be granted
- First time: App may ask for microphone permission

### How to Test

**Start Recording:**
1. From Home Screen, tap **"Record"** tile
2. If first time: Permission dialog may appear → Tap **"Allow"**
3. Recording starts immediately
4. Tile changes to **orange** and text becomes **"Stop rec"**
5. Green notification: "Recording started."
6. Speak or play audio near microphone

**Stop Recording:**
1. Tap the **"Stop rec"** tile (orange)
2. Recording stops
3. File is saved to phone storage
4. Green notification: "Recording saved." or "Recording stopped."
5. Tile returns to normal color and text becomes **"Record"**

**Expected behavior:**
- Microphone captures clear audio
- Recording saves with timestamp
- Tile color/text indicates recording state
- Files stored locally on device (offline)

### Test Cases

**Test 1: Start and Stop Recording**
- ✓ Tap "Record"
- ✓ Speak clearly near microphone for 5-10 seconds
- ✓ Tap "Stop rec"
- ✓ Notification shows "Recording saved"

**Test 2: Multiple Recordings**
- ✓ Record message 1 (5 seconds)
- ✓ Stop recording
- ✓ Record message 2 (5 seconds)
- ✓ Stop recording
- ✓ Both files should be saved separately

**Test 3: Microphone Permission**
- ✓ First run: Grant microphone permission
- ✓ Subsequent runs: Permission remembered
- ✓ If permission denied: Error "Microphone permission denied."

**Test 4: Permission Denied Case**
- ✓ Disable microphone permission in phone settings
- ✓ Try to record
- ✓ Error message: "Microphone permission denied."
- ✓ No recording happens

---

## Safety Timer

### Location
- **"Safety timer"** tile in grid (second row, middle tile)

### What it Does
- Countdown timer for your journey/travel time
- If you don't tap "I'm safe" before timer ends → automatic SOS is sent
- Useful for safety during commute or travel

### Prerequisites
- At least 1 emergency contact saved
- Keep app open during journey (doesn't work in background for v1)

### How to Test

**Step 1: Set Timer Duration**
1. From Home Screen, tap **"Safety timer"** tile
2. Screen shows:
   - Explanation text
   - Time choices: 5 min, 10 min, 15 min, 30 min, 60 min
   - "Start timer" button
3. Tap your desired duration (e.g., **5 min** for testing)
   - Selected option highlighted in blue

**Step 2: Start Timer**
1. Tap **"Start timer"** button
2. Countdown begins immediately
3. Large timer display shows remaining time (e.g., "05:00")
4. Big green button appears: **"I'm safe"**

**Step 3: Option A - Cancel by Arriving Safe**
1. Before timer ends, tap **"I'm safe"** button
2. Timer stops
3. Green message: "Glad you are safe! Timer cancelled."
4. Back to main setup screen

**Step 4: Option B - Let Timer Run Out (Auto SOS)**
1. Don't tap "I'm safe" - let timer count to 00:00
2. Timer reaches 00:00 automatically
3. SOS is sent to all emergency contacts
4. Message shows: "Time up! SOS alert sent to {number} contact(s)"
5. Back to setup screen

**Expected behavior:**
- Timer counts down accurately (1 second per second)
- Time display format: MM:SS (e.g., "15:45")
- Tapping "I'm safe" stops timer (no SOS sent)
- Timer ending sends automatic SOS to all contacts
- App must stay open during timer (no background service)

### Test Cases

**Test 1: Set and Cancel (Arrived Safe)**
- ✓ Choose 5 minute timer
- ✓ Start timer
- ✓ Wait 2-3 seconds
- ✓ Tap "I'm safe"
- ✓ Verify: "Glad you are safe! Timer cancelled."

**Test 2: Let Timer Complete (Auto SOS)**
- ✓ Choose 3 minute timer (shorter for testing)
- ✓ Start timer
- ✓ Don't tap "I'm safe"
- ✓ Wait for timer to reach 00:00
- ✓ Verify: SOS sent to all contacts
- ✓ Check contacts received emergency message

**Test 3: Different Durations**
- ✓ Test 5 min timer
- ✓ Test 10 min timer
- ✓ Test 15 min timer
- ✓ Verify each counts down correctly

**Test 4: No Contacts Error**
- ✓ Delete all contacts
- ✓ Set and start timer
- ✓ Let timer run to 00:00
- ✓ Should show error or message about no contacts

---

## Follow Me (Live Tracking)

### Location
- **"Follow Me"** tile in grid (third row, second tile — after Share location)

### What it Does
- Sends your **live location to emergency contacts automatically** every 2/5/10 minutes
- Contacts can watch your journey in real-time
- Useful during commutes, travel, or long trips
- You control the update frequency and can stop anytime
- Each update is sent as an SMS with a Google Maps link

### Prerequisites
- At least **1 emergency contact** saved
- Location (GPS) permission granted
- SMS permission granted
- Keep app open during journey (v1 has no background service)

### How to Test

**Step 1: Choose Update Frequency**
1. From Home Screen, tap **"Follow Me"** tile
2. Screen shows:
   - Explanation text
   - Time choices: **2 min**, **5 min**, **10 min**
   - "Start sharing" button
3. Tap your desired interval (e.g., **5 min** for testing)
   - Selected option highlighted in blue

**Step 2: Start Sharing**
1. Tap **"Start sharing"** button
2. **First location is sent immediately** to all contacts
3. Screen changes to show:
   - Green location icon
   - "Sharing your location…" message
   - **Updates sent:** counter
   - **Last update:** timestamp
   - Big red **"Stop"** button
4. Timer automatically sends updates on your chosen interval

**Step 3: Check Updates**
1. Each time an update sends, the counter increases
2. Timestamp shows when the last update was sent
3. Your contacts receive SMS with location link each time

**Step 4: Stop Sharing**
1. Tap the red **"Stop"** button
2. No more updates will be sent
3. Returns to setup screen

**Expected behavior:**
- First location sends immediately
- Updates send on chosen interval (2/5/10 min)
- Timestamps are accurate
- Contacts receive location SMS each time
- Stopping prevents further updates

### Test Cases

**Test 1: Start and Stop Follow Me**
- ✓ Have at least 1 contact saved
- ✓ Choose 2-minute interval
- ✓ Tap "Start sharing"
- ✓ Verify first location sends immediately
- ✓ Wait 2-3 minutes for next update
- ✓ Verify contact receives SMS with new location
- ✓ Tap "Stop"
- ✓ Verify no more updates sent

**Test 2: Different Intervals**
- ✓ Test 2-minute interval
- ✓ Test 5-minute interval
- ✓ Test 10-minute interval
- ✓ Verify each interval is accurate

**Test 3: No Contacts Error**
- ✓ Delete all contacts
- ✓ Tap "Follow Me"
- ✓ Tap "Start sharing"
- ✓ Error message: "Please add at least one emergency contact first."

**Test 4: Permission Denied**
- ✓ Disable location permission
- ✓ Try to start Follow Me
- ✓ Should show location error

---

## Emergency Helplines

### Location
- **"Helplines"** tile in grid (second row, middle tile)

### What it Does
- List of India's emergency helpline numbers
- One-tap calling - opens phone dialer with number pre-filled
- Does NOT auto-call (safe - no accidental calls)
- Includes: Police, Ambulance, Women Helpline, etc.

### Helplines Available
- **Police** - 100
- **Emergency (All-in-one)** - 112
- **Women Helpline** - 1091
- **Domestic Abuse Helpline** - 181
- **Ambulance** - 102
- **Child Helpline** - 1098
- **Cyber Crime** - 1930

### How to Test

**Step-by-step:**
1. From Home Screen, tap **"Helplines"** tile
2. List appears with all emergency numbers
3. Each helpline shows:
   - Icon (police badge, emergency, ambulance, etc.)
   - Name (title)
   - Phone number (subtitle)
   - Green phone icon on right
4. Tap any helpline
5. Phone's native **dialer app opens** with number pre-filled
6. Number NOT auto-dialed (you must press call button)

**Expected behavior:**
- Dialer opens with correct number filled in
- You can review number before calling
- You must manually tap "Call" button in dialer
- Number matches the one shown in list

### Test Cases

- ✓ Tap Police (100) → Dialer opens with "100"
- ✓ Tap Women Helpline (1091) → Dialer opens with "1091"
- ✓ Tap Ambulance (102) → Dialer opens with "102"
- ✓ Verify all 7 helplines work
- ✓ Don't actually call (just verify dialer opens)
- ✓ Tap back to return to app without calling

---

## Share Location

### Location
- **"Share location"** tile in grid (third row, first tile)

### What it Does
- Gets your current GPS location
- Shares it immediately via SMS/message to contacts
- Useful for letting someone know where you are right now

### Prerequisites
- Location permission must be granted
- GPS or internet access for location

### How to Test

**Step-by-step:**
1. From Home Screen, tap **"Share location"** tile
2. App requests location permission (first time only)
3. Spinner appears briefly (finding location)
4. SMS/message app opens automatically with:
   - Location link (Google Maps URL)
   - Pre-filled text ready to send
5. Manually select contact and tap "Send"

**Expected behavior:**
- Location acquired within few seconds
- Correct coordinates sent
- Format: Google Maps link (e.g., `https://maps.google.com/?q=...`)
- Works with internet connection (offline may fail)

### Test Cases

**Test 1: Share Location Successfully**
- ✓ Tap "Share location"
- ✓ Grant location permission
- ✓ Wait for location to be found (5-10 seconds)
- ✓ SMS/Message app opens with location link
- ✓ Select contact and send

**Test 2: Location Permission Denied**
- ✓ Disable location permission in phone settings
- ✓ Tap "Share location"
- ✓ Error message appears: "Location permission denied" or similar
- ✓ No SMS/message app opens

**Test 3: Multiple Shares**
- ✓ Share location multiple times
- ✓ Each share should get fresh GPS coordinates

---

## Fake Call (Upgraded)

### Location
- **"Fake call"** tile in grid (third row, middle tile)

### What it Does
- **Setup screen** lets you customize who is calling (Mom, Dad, Boss, anyone) and when the call rings
- You can start the call immediately or set a delay (0, 5, 10, 30 seconds)
- When the call arrives, a realistic incoming-call screen appears with vibration pattern
- Useful to create an excuse to leave an uncomfortable or unsafe situation
- Tap "Accept" or "Decline" to exit the fake call screen

### How to Test

**Step 1: Set Up the Call**
1. From Home Screen, tap **"Fake call"** tile
2. **Setup screen appears** with:
   - Text field for caller name (default: "Mom")
   - Time choices: **Now**, **5 sec**, **10 sec**, **30 sec**
   - "Start fake call" button
3. **Customize the caller:**
   - Tap the text field and change "Mom" to anyone (e.g., "Boss", "Dad", "Friend")
4. **Choose when to ring:**
   - Tap **"Now"** for immediate call
   - Or tap **"5 sec"** / **"10 sec"** / **"30 sec"** for a delay
5. Tap **"Start fake call"** button

**Step 2A: Immediate Call (Now)**
- If you chose "Now":
  - **Fake call screen appears immediately** showing:
    - Dark/black background
    - Large contact icon (person avatar)
    - Caller name you entered
    - Text: **"Incoming call…"**
    - Two buttons: **"Decline" (red)** and **"Accept" (green)**
  - Phone vibrates in pattern (like real incoming call)

**Step 2B: Delayed Call (5/10/30 sec)**
- If you chose a delay:
  - **Countdown screen appears** showing:
    - Phone icon
    - "Calling in N…" (where N is seconds left)
    - "Keep this screen open. You can put the phone to your ear."
    - "Cancel" button
  - After the countdown reaches zero → fake call screen appears

**Step 3: Respond to Call**
- **Option A - Decline:**
  - Tap red **"Decline"** button
  - Vibration stops
  - Back to Home Screen
- **Option B - Accept:**
  - Tap green **"Accept"** button
  - Vibration stops
  - Back to Home Screen

**Expected behavior:**
- Caller name displays exactly as you typed it
- Countdown is accurate
- Vibration pattern mimics real incoming call
- Visual design looks realistic
- Buttons are responsive
- Returns to home screen after action

### Test Cases

**Test 1: Immediate Call with Default Caller**
- ✓ Tap "Fake call"
- ✓ Don't change name (stays "Mom")
- ✓ Select "Now"
- ✓ Tap "Start fake call"
- ✓ Call screen appears immediately
- ✓ Verify "Mom" is shown as caller
- ✓ Tap "Decline" → Back to home

**Test 2: Custom Caller with Delay**
- ✓ Tap "Fake call"
- ✓ Change name to "Boss"
- ✓ Select "10 sec"
- ✓ Tap "Start fake call"
- ✓ Countdown screen shows "Calling in 10…"
- ✓ Wait for countdown to reach zero
- ✓ Call screen appears with "Boss" as caller
- ✓ Tap "Accept" → Back to home

**Test 3: Cancel Delayed Call**
- ✓ Tap "Fake call"
- ✓ Enter custom name
- ✓ Select "10 sec"
- ✓ Tap "Start fake call"
- ✓ On countdown screen, tap "Cancel"
- ✓ Returns to setup screen (no call)

**Test 4: Different Callers**
- ✓ Test with "Dad"
- ✓ Test with "Friend"
- ✓ Test with a long name
- ✓ Verify each shows correct name on call screen

**Test 5: Vibration**
- ✓ Verify phone vibrates when call appears
- ✓ Verify vibration stops when you accept/decline
- ✓ If vibration disabled in phone settings, call still works (no vibration)

---

## Safety Tips & First Aid

### Location
- **"Safety tips"** tile in grid (fourth row, second tile)

### What it Does
- **Offline guide** with safety advice and basic first-aid information
- Works with **zero internet** — all content is built into the app
- Covers: being followed, bleeding, choking, CPR, burns, safe travel at night, escaping a grab
- General information only — **NOT a substitute for professional medical help**
- In a real emergency, call 112 (or your local emergency number) first

### How to Test

**Step-by-step:**
1. From Home Screen, tap **"Safety tips"** tile
2. **Safety tips screen appears** with:
   - Warning banner (yellow/amber background) with disclaimer
   - Scrollable list of **7 safety topics**
3. Each topic shows:
   - An icon (e.g., walking person, water drop, heart, etc.)
   - Title (e.g., "If you feel you are being followed")
   - **Expandable** (tap to show steps)
4. Tap any topic to expand and read the steps
5. Tap again to collapse

**Topics Available:**
1. **If you feel you are being followed** — Stay calm, go to a public place, call someone
2. **Severe bleeding** — Press firmly with cloth, raise the limb, get help
3. **Choking** — Back blows and abdominal thrusts
4. **CPR (no breathing)** — Push hard and fast on the chest, call for help
5. **Burns** — Cool with water for 20+ min, remove tight items, cover loosely
6. **Safe travel at night** — Share trip, sit near driver, note vehicle number
7. **If someone grabs you** — Shout, aim for weak points, use Siren, run to people

**Expected behavior:**
- All text is readable and clear
- Topics expand smoothly
- Works fully offline (no internet needed)
- Scrollable if content is long
- Easy to navigate

### Test Cases

- ✓ Open "Safety tips" → Content appears
- ✓ Tap first topic to expand
- ✓ Read the steps clearly
- ✓ Tap again to collapse
- ✓ Expand different topics
- ✓ Scroll down to see all 7 topics
- ✓ Test offline (disable internet) → Content still shows
- ✓ Verify disclaimer is visible at top

---

## Hide App (Decoy Calculator)

### Location
- **"Hide app"** tile in grid (fourth row, third tile)

### What it Does
- Disguises the app as a **fully-functional calculator**
- If someone is watching your phone, they see an ordinary calculator, not a safety app
- The calculator actually works — you can do math on it
- **Long-press the big number display** at the top to secretly return to the Women Safety app
- No one else will know how to unlock it

### Prerequisites
- None — this is a standalone screen

### How to Test

**Step 1: Open the Decoy**
1. From Home Screen, tap **"Hide app"** tile
2. A **realistic calculator screen appears** with:
   - Dark background (like a real calculator)
   - Large number display at the top showing "0"
   - Grid of buttons: numbers 0-9, basic operations (+, -, ×, ÷), equals, clear, decimal

**Step 2: Use the Calculator (Optional)**
- Tap **7**, **3**, then **+** → Display shows "73 +"
- Tap **2**, **7** → Display shows "27"
- Tap **=** → Display shows "100"
- Tap **C** to clear → Display shows "0"

**Step 3: Exit the Decoy**
1. **Long-press** (hold finger down for 1-2 seconds) on the **big number display** at the top
2. App returns immediately to the **Women Safety home screen**
3. No one watching would know the secret exit

**Expected behavior:**
- Calculator looks and works like a real calculator
- All buttons are responsive
- Math is correct
- Display is clear and readable
- Long-press exit is instant
- No visible "exit" button to give away the secret

### Test Cases

- ✓ Tap "Hide app" → Calculator appears
- ✓ Do a simple sum (e.g., 5 + 3 = 8)
- ✓ Verify math is correct
- ✓ Tap "C" → Display clears to "0"
- ✓ Long-press the display → Back to Women Safety app
- ✓ Test multiple calculations before exiting
- ✓ Verify the exit is smooth and instant

---

## Medical Information

### Location
- **"Medical info"** tile in grid (third row, right tile)

### What it Does
- Store emergency medical information on your phone
- Information available to show doctors/paramedics in emergency
- All data stored locally on device (offline)
- Includes: Name, blood group, allergies, medications, notes

### How to Test

**Step 1: Open Medical Info Screen**
1. From Home Screen, tap **"Medical info"** tile
2. Screen shows several text fields:
   - Full name
   - Blood group (e.g., "O+")
   - Allergies
   - Current medications
   - Other notes (larger text box)
3. Blue "Save" button at bottom

**Step 2: Add Medical Information**
1. Tap each field and enter information:
   - **Full name:** Enter your full name
   - **Blood group:** Enter type (e.g., "A+", "B-", "O+")
   - **Allergies:** Enter any allergies (e.g., "Penicillin, Aspirin")
   - **Medications:** Current medications (e.g., "Aspirin 500mg daily")
   - **Notes:** Any other important medical info
2. Tap **"Save"** button
3. Green message: "Medical info saved."

**Step 3: Edit Medical Information**
1. Re-open "Medical info" screen
2. Previously saved information appears in fields
3. Modify any field
4. Tap "Save" again
5. New information saved

**Expected behavior:**
- Fields save correctly
- Information persists when reopening
- Data stored locally on device
- No internet needed
- Clear, easy-to-read layout

### Test Cases

**Test 1: Add Complete Medical Info**
- ✓ Enter full name: "John Doe"
- ✓ Enter blood group: "O+"
- ✓ Enter allergies: "Penicillin"
- ✓ Enter medications: "Metformin 500mg"
- ✓ Enter notes: "Diabetic, sensitive to heat"
- ✓ Tap Save
- ✓ Green message confirms save

**Test 2: Edit Information**
- ✓ Open Medical info
- ✓ Change blood group to "A+"
- ✓ Tap Save
- ✓ Reopen Medical info
- ✓ Verify blood group changed to "A+"

**Test 3: Partial Information**
- ✓ Enter only name and blood group
- ✓ Leave allergies/medications empty
- ✓ Tap Save
- ✓ Information saves correctly

**Test 4: Clear Information**
- ✓ Delete all text from a field
- ✓ Tap Save
- ✓ Field should be empty on next open

---

## Nearby Help

### Location
- **"Nearby help"** tile in grid (third row, first tile — or scroll to find it)

### What it Does
- Opens **Google Maps** showing emergency / useful places around you
- Choose a place type: Police, Hospital, Pharmacy, Hotel, Petrol pump, ATM, Bus/Taxi, Crowded place
- Maps centers on your **live location** and shows the nearest places
- 100% **free** — uses public Google Maps (no API key needed)
- Works offline-installed, uses only your GPS + the phone's Maps app

### Prerequisites
- Location (GPS) permission granted
- Google Maps app installed (standard on all Android)

### How to Test

**Step 1: Open Nearby Help**
1. From Home Screen, tap **"Nearby help"** tile
2. **Nearby places screen appears** showing:
   - Explanation text about turning on GPS
   - **2×4 grid** of place types with icons
3. Each tile shows:
   - Icon (police badge, hospital cross, pharmacy, hotel, etc.)
   - Place name (e.g., "Police station", "Hospital")

**Step 2: Select a Place Type**
1. Tap any place type (e.g., **"Police station"**)
2. A spinner appears briefly (getting your location)
3. **Google Maps opens** showing:
   - Your current location (center of map)
   - All nearby police stations marked on the map
   - Zoom level is set for local view (15z)
4. If GPS is off/denied, Maps shows a "near me" search anyway

**Step 3: Interact with the Map**
- You can:
  - Tap any marker to see the place details
  - Get directions
  - Call the place
  - Search for more nearby

**Place Types Available:**
1. **Police station** — Police stations near you
2. **Hospital** — Medical hospitals nearby
3. **Pharmacy** — Drug stores / medical shops
4. **Hotel / Lodge** — Accommodation options
5. **Petrol pump** — Gas stations
6. **ATM / Bank** — ATM and bank branches
7. **Bus / Taxi** — Bus stands and taxi stands
8. **Crowded place** — Malls, markets, restaurants (safer areas)

**Expected behavior:**
- Maps opens instantly or after brief location wait
- Correct place type is searched
- Map is centered on your location
- Zoom level shows local area clearly
- Places are marked with red pins

### Test Cases

**Test 1: Open Police Stations**
- ✓ Have location enabled
- ✓ Tap "Nearby help" tile
- ✓ Tap "Police station"
- ✓ Maps opens showing nearest police stations
- ✓ Your location is roughly in the center

**Test 2: Try Different Place Types**
- ✓ Test Hospital
- ✓ Test Pharmacy
- ✓ Test Hotel / Lodge
- ✓ Test Petrol pump
- ✓ Verify each shows correct type of place

**Test 3: Location Permission Denied**
- ✓ Disable location permission
- ✓ Tap "Nearby help"
- ✓ Tap a place type
- ✓ Error message should appear explaining location is needed
- ✓ (If Maps opens anyway with fallback "near me" search, that's fine)

**Test 4: Maps Integration**
- ✓ Tap a place marker on the map
- ✓ Details popup should show
- ✓ Can tap "Directions" to get route
- ✓ Can call the place from the popup

---

## Complete Testing Checklist

Use this checklist to verify all features work correctly:

### Setup Phase
- [ ] Add 2-3 emergency contacts (needed for SOS, Check-in, Follow Me, Safety Timer)
- [ ] Configure SOS countdown (10 seconds recommended for testing)
- [ ] Customize SOS message with `{location}` placeholder
- [ ] Enable "Shake to SOS" toggle
- [ ] Grant Location permission (for SOS, Follow Me, Share Location, Nearby Help)
- [ ] Grant Microphone permission (for Recording)
- [ ] Grant SMS permission (for SOS, Check-in, Follow Me)

### Feature Testing (15 tools total)
- [ ] **SOS Button** - Can cancel and complete
- [ ] **Check-in** - Messages send to contacts
- [ ] **Siren** - On/off, color changes, sound works
- [ ] **Flashlight** - On/off, LED turns on/off
- [ ] **SOS Blink** - Morse pattern visible, repeats until stopped
- [ ] **Recording** - Record audio, saves, playback works
- [ ] **Safety Timer** - Different durations, auto-SOS on timeout
- [ ] **Follow Me** - Sends location updates on interval, can stop
- [ ] **Helplines** - All 7 numbers open in dialer
- [ ] **Share Location** - Location acquired and sent
- [ ] **Fake Call** - Custom caller name, delay works, vibration pattern works
- [ ] **Safety Tips** - All 7 topics expand/collapse, works offline
- [ ] **Hide App** - Calculator works, long-press exit works
- [ ] **Medical Info** - Can add, edit, and save information
- [ ] **Nearby Help** - Maps opens with correct places near you
- [ ] **Settings** - All settings save and apply

### Data Persistence
- [ ] Close app and reopen → Contacts still there
- [ ] Close app and reopen → Settings unchanged
- [ ] Close app and reopen → Medical info unchanged

### Permissions
- [ ] Microphone permission works for recording
- [ ] Location permission works for sharing location
- [ ] Vibration permission works for fake call
- [ ] Camera/flashlight permission works

### Error Handling
- [ ] No contacts error on SOS/Check-in
- [ ] No flashlight error (if device has no LED)
- [ ] Location permission denied error
- [ ] Microphone permission denied error

---

## Tips for Effective Testing

1. **Use a test contact number** (your own number or a friend's who's aware)
2. **Test in safe environment** - Don't actually trigger SOS unless intentional
3. **Keep app open** - For Safety Timer feature (doesn't work in background)
4. **Test on real device** - Emulator may lack features (vibration, camera, GPS)
5. **Document issues** - Note what doesn't work and any error messages
6. **Test permissions** - Grant/deny permissions and verify error handling
7. **Test offline** - Some features (SOS, Check-in) need internet but should handle gracefully

---

## Quick Test Script (10-15 minutes)

If you want a quick overview test of **all 15 features**:

1. Add 1-2 emergency contacts
2. Customize SOS message in Settings
3. Tap **SOS** and cancel (don't send)
4. Tap **Check-in** ("I'm safe") — send one location
5. Tap **Siren** (on/off)
6. Tap **Flashlight** (on/off)
7. Tap **SOS blink** in dark room — watch Morse pattern
8. Record 5 seconds of audio with **Record** button
9. View **Safety Timer** (don't start)
10. Tap **Follow Me** — send one location update
11. View **Helplines** (don't call)
12. Tap **Share location**
13. Tap **Fake call** — set custom caller name, use delay, accept/decline
14. View **Safety tips** — expand one topic
15. Tap **Hide app** — do a math sum, long-press display to exit
16. View **Nearby help** — open a place type in Maps
17. View **Medical Info** and add blood group

✓ If all above works → **All 15 safety tools are functioning correctly!**

---

## New Features Summary (v2.0)

| Feature | Purpose | Location |
|---------|---------|----------|
| 🆘 **SOS blink** | Morse distress signal | Grid, row 1 |
| 🟣 **Follow Me** | Live location tracking | Grid, row 3 |
| 📖 **Safety tips** | Offline first-aid guide | Grid, row 4 |
| 📞 **Fake call** (upgraded) | Custom caller + delay | Grid, row 3 |
| 📵 **Hide app** | Disguise as calculator | Grid, row 4 |

All features are **100% free**, **offline-first**, and **no login required**.

