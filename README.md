# Gymer

A personal iOS app I built to track my workouts, log weights and reps, and see my progress over time.

---

## 📸 Screenshots

<table>
  <tr>
    <td><img src="Gymer/images/IMG_4172.png" width="200" height="400"/></td>
    <td><img src="Gymer/images/IMG_4173.png" width="200" height="400"/></td>
    <td><img src="Gymer/images/IMG_4174.png" width="200" height="400"/></td>
    <td><img src="Gymer/images/IMG_4175.png" width="200" height="400"/></td>
  </tr>
  <tr>
    <td><img src="Gymer/images/IMG_4178.png" width="200" height="400"/></td>
    <td><img src="Gymer/images/IMG_4179.png" width="200" height="400"/></td>
    <td><img src="Gymer/images/IMG_4181.png" width="200" height="400"/></td>
    <td></td>
  </tr>
</table>

## Why I Built This

I was tired of using notes apps and spreadsheets to track my gym sessions. Big fitness apps like MyFitnessPal or Strong have too many features I don't need, and they feel slow to use between sets.

I wanted something simple: open the app, pick a workout, log my sets, and close it. That's it.

**Problems this app solves for me:**

- I never remember what weight I used last week for bench press, now I can see it instantly
- I used to forget my rest times and either rest too long or too short, the auto rest timer fixes this
- I had no way to track if I was getting stronger over time, personal records (PRs) are now tracked automatically
- Creating a new workout from scratch every time was annoying, templates let me save my Push/Pull/Legs splits and reuse them

---

## What the App Does

- **Workout templates** — Create and save your workout plans (e.g. Push Day, Pull Day, Leg Day). Each template holds your exercises with target sets, reps, and rest time.
- **Live workout tracking** — Start a workout from a template, log each set with weight and reps, and mark sets as complete.
- **Rest timer** — After each set, a countdown timer starts automatically. You can adjust the time or skip it.
- **Personal records** — The app detects when you hit a new PR and marks it automatically.
- **Workout history** — See all your past sessions grouped by month, with volume and exercise count.
- **Exercise library** — A built-in list of exercises filtered by muscle group.

---

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Swift | 5.9+ | Primary language |
| SwiftUI | iOS 17+ | UI framework |
| SwiftData | iOS 17+ | Local data persistence |
| Swift Observation (`@Observable`) | iOS 17+ | State management (replaces `ObservableObject`) |
| Xcode | 15+ | IDE |

No third-party dependencies. Everything is built with Apple frameworks.

---

## Architecture

The app follows **MVVM** (Model-View-ViewModel).

```
Models        — SwiftData @Model classes (source of truth)
ViewModels    — @Observable classes, own business logic and state
Views         — SwiftUI views, read from ViewModels, send user intents back
Components    — Reusable UI pieces (buttons, inputs, timer overlay)
Services      — Data access (DataService) and timer logic (TimerService)
```

---

## Project Structure

```
Gymer/
├── App/
│   ├── GymerApp.swift            # App entry point, SwiftData container setup
│   └── AppRouter.swift           # Root navigation
│
├── Models/
│   ├── WorkoutTemplate.swift     # Saved workout plan
│   ├── ExerciseSlot.swift        # Exercise inside a template
│   ├── WorkoutSession.swift      # A completed or in-progress session
│   ├── SetLog.swift              # One logged set (weight, reps, type)
│   └── Enums.swift               # SetType, BodyRegion, Equipment
│
├── ViewModels/
│   ├── ActiveWorkoutViewModel.swift   # Live workout state + timer logic
│   ├── TemplateEditorViewModel.swift  # Create / edit templates
│   ├── TemplateListViewModel.swift    # Template list management
│   ├── HistoryViewModel.swift         # Past session fetching + grouping
│   └── HomeViewModel.swift            # Dashboard stats
│
├── Views/
│   ├── MainTabView.swift              # Root tab bar (Profile / Start / Exercises)
│   ├── StartWorkout/
│   │   ├── StartWorkoutView.swift     # Workout hub (templates + history)
│   │   ├── ActiveWorkoutView.swift    # Live workout screen
│   │   ├── TemplateEditorView.swift   # Create / edit a template
│   │   └── WorkoutSummaryView.swift   # Post-workout summary
│   ├── History/
│   │   ├── HistoryView.swift          # Past sessions list
│   │   └── WorkoutDetailView.swift    # Detail of one session
│   ├── Exercises/
│   │   ├── ExerciseListView.swift     # Browse exercises
│   │   ├── ExerciseDetailView.swift   # Exercise detail + PRs
│   │   └── NewExerciseView.swift      # Add custom exercise
│   └── Profile/
│       └── ProfileView.swift          # Stats and muscle distribution
│
├── Components/
│   ├── Common/
│   │   ├── GymButton.swift            # Primary / secondary / ghost button
│   │   ├── SectionHeader.swift        # Section header with optional action
│   │   └── BadgeLabel.swift           # Muscle group / set type badges
│   ├── Workout/
│   │   ├── SetRowView.swift           # One set row (type + weight + reps + checkmark)
│   │   ├── WeightInput.swift          # Weight stepper input
│   │   ├── RepInput.swift             # Reps stepper + failure toggle
│   │   ├── SetTypeSelector.swift      # Regular / Drop Set / Warm-up / Failure
│   │   └── RestTimerRowView.swift     # [−15s][1:30][+15s] rest time control
│   └── Timer/
│       └── RestTimerOverlay.swift     # Compact rest countdown sheet
│
├── Services/
│   ├── DataService.swift              # SwiftData CRUD helpers
│   ├── TimerService.swift             # Countdown timer (singleton, @Observable)
│   └── ExerciseLibraryService.swift   # Loads exercises.json into memory
│
├── Utilities/
│   ├── Extensions.swift               # Color+hex, View helpers
│   ├── Constants.swift                # Default rest times, limits
│   └── Formatters.swift               # Time and weight string formatters
│
├── DesignSystem/
│   ├── Colors.swift                   # Color tokens (gymBlack, gymLime, etc.)
│   ├── Typography.swift               # GymFont enum + .gymFont() modifier
│   └── Spacing.swift                  # Spacing and Radius constants
│
└── Resources/
    └── exercises.json                 # Bundled exercise database (~100 exercises)
```

---

## Design System

The app uses a dark theme with electric lime as the accent color.

| Token | Hex | Used for |
|-------|-----|---------|
| `gymBlack` | `#0D0D0D` | Primary background |
| `gymSurface` | `#1A1A1A` | Cards and inputs |
| `gymCard` | `#222222` | Elevated elements |
| `gymLime` | `#C6FF00` | Active states, buttons, accents |
| `gymRed` | `#FF3B30` | Destructive actions, drop sets |
| `gymAmber` | `#FF9F0A` | Warm-up sets |
| `gymWhite` | `#F5F5F5` | Primary text |
| `gymMuted` | `#6B6B6B` | Secondary text, labels |

---

## Data Models

```swift
WorkoutTemplate   — name, emoji, color, list of ExerciseSlots
ExerciseSlot      — exercise reference, targetSets, targetReps, defaultRestSeconds
WorkoutSession    — started/finished timestamps, list of SetLogs, total volume
SetLog            — weight, reps, setType, isFailure, isPersonalRecord
```

All data is stored locally on device with **SwiftData**. There is no account, no server, no sync.

---

## Running the Project

1. Clone the repo
2. Open `Gymer.xcodeproj` in Xcode 15 or later
3. Select a simulator or device running iOS 17+
4. Build and run (`⌘R`)

No API keys or environment setup needed.

---

## Known Limitations

- **No iCloud sync** — data lives on one device only (planned for a future version)
- **No Apple Watch support** — phone only for now
- **No landscape layout** — portrait only
- **Exercise library is read-only** — you can add custom exercises but the bundled list is not editable

---

## Personal Note

I built this app to learn SwiftData and SwiftUI's newer APIs (iOS 17+ observation model), and also because I genuinely needed it. I use it every time I go to the gym. If you find it useful, feel free to fork it and adjust it to fit your own training style.
