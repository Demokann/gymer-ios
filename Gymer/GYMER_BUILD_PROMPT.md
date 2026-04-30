# GYMER — iOS App Build Prompt for Gemini CLI
# ============================================================
# Usage: gemini -p "$(cat GYMER_BUILD_PROMPT.md)"
# Or paste directly into Gemini CLI session
# ============================================================

You are a senior iOS engineer building a production-quality SwiftUI workout tracking app called **Gymer**. You will build the complete app from the folder structure that already exists. Read `project_context.md` in the root directory first — it is your single source of truth for architecture, design tokens, data models, and screen flow.

---

## STEP 0 — Before You Write Any Code

1. Read `project_context.md` fully.
2. Read `agents/backend_dev.md` fully — this governs all Models, ViewModels, Services you will write.
3. Read `agents/ui_designer.md` fully — this governs all Views and Components you will write.
4. Confirm you understand the design system tokens (colors, typography, spacing) before writing a single View.

Do NOT start coding until you have read all three documents.

---

## STEP 1 — Folder Structure

Create every file and folder listed below inside the `Gymer/` directory. Do not deviate from this structure.

```
Gymer/
├── App/
│   ├── GymerApp.swift
│   └── AppRouter.swift
│
├── Assets.xcassets/
│   ├── AccentColor.colorset/
│   └── AppIcon.appiconset/
│
├── DesignSystem/
│   ├── Colors.swift
│   ├── Typography.swift
│   └── Spacing.swift
│
├── Models/
│   ├── WorkoutTemplate.swift
│   ├── ExerciseSlot.swift
│   ├── WorkoutSession.swift
│   ├── SetLog.swift
│   ├── Exercise.swift
│   └── Enums.swift
│
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── TemplateListViewModel.swift
│   ├── TemplateEditorViewModel.swift
│   ├── ActiveWorkoutViewModel.swift
│   ├── ExerciseLibraryViewModel.swift
│   └── HistoryViewModel.swift
│
├── Views/
│   ├── MainTabView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── WorkoutDetailView.swift
│   ├── StartWorkout/
│   │   ├── StartWorkoutView.swift
│   │   ├── TemplateListView.swift
│   │   ├── TemplateEditorView.swift
│   │   └── ActiveWorkoutView.swift
│   ├── Exercises/
│   │   ├── ExerciseListView.swift
│   │   ├── ExerciseDetailView.swift
│   │   └── NewExerciseView.swift
│   └── Profile/
│       └── ProfileView.swift
│
├── Components/
│   ├── Common/
│   │   ├── GymButton.swift
│   │   ├── SectionHeader.swift
│   │   └── BadgeLabel.swift
│   ├── Workout/
│   │   ├── SetRowView.swift
│   │   ├── SetTypeSelector.swift
│   │   ├── WeightInput.swift
│   │   └── RepInput.swift
│   └── Timer/
│       └── RestTimerOverlay.swift
│
├── Services/
│   ├── DataService.swift
│   ├── TimerService.swift
│   └── ExerciseLibraryService.swift
│
├── Utilities/
│   ├── Extensions.swift
│   ├── Constants.swift
│   └── Formatters.swift
│
└── Resources/
    └── exercises.json
```

---

## STEP 2 — Design System (Implement First, Everything Depends on This)

### `DesignSystem/Colors.swift`
```swift
import SwiftUI

extension Color {
    // Backgrounds
    static let gymBlack   = Color(hex: "#0D0D0D")  // primary background
    static let gymSurface = Color(hex: "#1A1A1A")  // card background
    static let gymCard    = Color(hex: "#222222")  // elevated card

    // Accents
    static let gymLime    = Color(hex: "#C6FF00")  // primary accent — active states, CTAs
    static let gymRed     = Color(hex: "#FF3B30")  // danger, failure, drop set
    static let gymAmber   = Color(hex: "#FF9F0A")  // warm-up, secondary accent

    // Text
    static let gymWhite   = Color(hex: "#F5F5F5")  // primary text
    static let gymMuted   = Color(hex: "#6B6B6B")  // secondary text
    static let gymBorder  = Color(hex: "#2C2C2C")  // dividers and borders
}

// Hex initializer for Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
```

### `DesignSystem/Typography.swift`
Define a `GymFont` enum with cases: `.largeTitle` (34pt bold), `.title` (22pt bold), `.body` (17pt), `.caption` (13pt), `.mono` (17pt monospaced SF Mono). Implement as a `ViewModifier` so views can use `.gymFont(.title)`.

### `DesignSystem/Spacing.swift`
```swift
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum Radius {
    static let small:  CGFloat = 8
    static let medium: CGFloat = 12
    static let large:  CGFloat = 20
    static let pill:   CGFloat = 999
}
```

---

## STEP 3 — Data Models (SwiftData)

File: `Models/Enums.swift`
```swift
enum BodyRegion: String, Codable, CaseIterable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves, abs, fullBody
    
    var displayName: String { /* human readable */ }
    var icon: String { /* SF Symbol name */ }
}

enum SetType: String, Codable, CaseIterable {
    case regular = "Regular"
    case warmUp  = "Warm-up"
    case dropSet = "Drop Set"
    
    var color: Color { /* .gymWhite / .gymAmber / .gymRed */ }
    var abbreviation: String { /* "W" / "D" / "" */ }
}

enum Equipment: String, Codable, CaseIterable {
    case barbell, dumbbell, cable, machine, bodyweight, kettlebell, band, other
}
```

File: `Models/Exercise.swift`
```swift
@Model
class Exercise {
    var id: UUID
    var name: String
    var bodyRegions: [BodyRegion]   // primary muscles
    var equipment: Equipment
    var notes: String
    var isCustom: Bool              // true = user created, false = from bundled library
    var createdAt: Date
    
    // Computed
    var primaryRegion: BodyRegion { bodyRegions.first ?? .fullBody }
}
```

File: `Models/WorkoutTemplate.swift`
```swift
@Model
class WorkoutTemplate {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String            // hex string for card accent
    var slots: [ExerciseSlot]       // ordered exercises
    var createdAt: Date
    var lastUsedAt: Date?
    var sessionCount: Int           // how many times used
}
```

File: `Models/ExerciseSlot.swift`
```swift
@Model
class ExerciseSlot {
    var id: UUID
    var exercise: Exercise
    var order: Int
    var targetSets: Int             // default number of sets
    var targetReps: Int             // default reps per set (0 = failure)
    var targetWeightKg: Double      // default weight
    var defaultRestSeconds: Int     // rest after each set (default 90)
    var notes: String
}
```

File: `Models/WorkoutSession.swift`
```swift
@Model
class WorkoutSession {
    var id: UUID
    var template: WorkoutTemplate?
    var templateName: String        // denormalized — persists even if template deleted
    var startedAt: Date
    var finishedAt: Date?
    var setLogs: [SetLog]
    var notes: String
    
    // Computed (not stored)
    var durationFormatted: String   // "45m" or "1h 23m"
    var totalVolumeKg: Double       // Σ(weight × reps), failure sets excluded
    var exerciseCount: Int
}
```

File: `Models/SetLog.swift`
```swift
@Model
class SetLog {
    var id: UUID
    var exercise: Exercise
    var exerciseName: String        // denormalized
    var setIndex: Int               // 1-based
    var setType: SetType
    var weightKg: Double
    var reps: Int                   // 0 = failure
    var isFailure: Bool
    var isPersonalRecord: Bool      // computed and stored at log time
    var completedAt: Date
    var restSeconds: Int            // how long they actually rested after this set
}
```

---

## STEP 4 — Services

### `Services/TimerService.swift`
Build a `@MainActor @Observable` class `TimerService`. Requirements:
- `start(seconds: Int, onComplete: @escaping () -> Void)` — begins countdown
- `pause()`, `resume()`, `stop()` — full control
- `adjust(by delta: Int)` — add or remove seconds while running (clamp to 0...3600)
- `progress: Double` — 0.0 → 1.0 for the ring animation (currentRemaining / totalSeconds)
- `secondsRemaining: Int` and `isRunning: Bool` published
- Cancels existing timer before starting a new one
- Uses `Task` + `AsyncStream`, NOT `Timer.publish` (no Combine dependency)
- Survives app backgrounding: store `backgroundedAt: Date?` via `scenePhase` observer, recompute on foreground

### `Services/ExerciseLibraryService.swift`
- Load `exercises.json` from bundle at app launch (once, async, cached)
- Bundled JSON has ~60 exercises across all body regions
- Merge with user-created `Exercise` records from SwiftData
- Expose: `allExercises`, `exercises(for: BodyRegion)`, `search(_ query: String)`

### `Services/DataService.swift`
- CRUD helpers wrapping `ModelContext`
- `saveSession(_ session: WorkoutSession)`
- `deleteTemplate(_ template: WorkoutTemplate)`
- `personalRecord(for exercise: Exercise) -> SetLog?` — highest volume set ever for that exercise
- All saves are in `do/catch` — never `try?`

---

## STEP 5 — exercises.json

Create `Resources/exercises.json` with at least 60 exercises. Cover every `BodyRegion`. Structure:
```json
[
  {
    "id": "barbell_bench_press",
    "name": "Barbell Bench Press",
    "bodyRegions": ["chest", "triceps", "shoulders"],
    "equipment": "barbell",
    "notes": "Keep elbows at 75°, retract scapula"
  }
]
```
Include at minimum: Chest (8), Back (10), Shoulders (6), Biceps (5), Triceps (5), Quads (7), Hamstrings (5), Glutes (5), Calves (3), Abs (6).

---

## STEP 6 — App Entry & Navigation

### `App/GymerApp.swift`
```swift
@main
struct GymerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [
                    WorkoutTemplate.self,
                    ExerciseSlot.self,
                    WorkoutSession.self,
                    SetLog.self,
                    Exercise.self
                ])
                .preferredColorScheme(.dark)
        }
    }
}
```

### `Views/MainTabView.swift`
Standard `TabView` with 4 tabs in this exact order:
1. **Profile** — icon: `person.fill` — `ProfileView`
2. **History** — icon: `clock.fill` — `HistoryView`
3. **Start Workout** — CENTRE TAB, special treatment (see below) — `StartWorkoutView`
4. **Exercises** — icon: `dumbbell.fill` — `ExerciseListView`

Centre tab design:
- Oversized circular button (56×56pt), `gymLime` fill, black dumbbell icon
- Lifts 12pt above the tab bar with a shadow
- Uses `.fullScreenCover` to present `StartWorkoutView`
- Tab bar background: `gymSurface` with 1pt top border in `gymBorder`

---

## STEP 7 — Screen Specifications (Build Each Fully)

---

### 7A — Profile Tab (`Views/Profile/ProfileView.swift`)

**Layout:**
```
[Avatar initials circle — 80pt, gymLime ring]
[Name — editable, tap to rename]
[Member since: DD Month YYYY]

[Stats Row — 3 columns]
┌──────────────┬──────────────┬──────────────┐
│  Total       │  This Month  │  Best Streak │
│  Workouts    │  Workouts    │  X days      │
│  [N]         │  [N]         │  [N]         │
└──────────────┴──────────────┴──────────────┘

[Recent PRs section]
— List of last 5 personal records (exercise name, weight × reps, date)

[Favourite Body Regions — horizontal bar chart]
— Shows which body regions they train most (from SetLog history)
```

Data: `HomeViewModel` or `ProfileViewModel` — compute from SwiftData.

---

### 7B — History Tab (`Views/History/HistoryView.swift`)

**Layout:**
- Grouped list by month (e.g. "April 2026", "March 2026")
- Each row is a workout session card:

```
┌─────────────────────────────────────────┐
│ 💪 Push Day A              Mon 21 Apr   │
│ 45 min · 8 exercises · 4,200 kg vol     │
│                               🏆 2 PRs  │
└─────────────────────────────────────────┘
```

- Tap → `WorkoutDetailView`

**`Views/History/WorkoutDetailView.swift`:**
```
[Template name + date + duration]

[Volume: X,XXX kg]  [Sets: N]  [Exercises: N]

For each exercise:
  [Exercise name]  [Body region badge]
  Set 1:  80 kg × 10  [Regular]   🏆 PR
  Set 2:  80 kg × 8   [Regular]
  Set 3:  75 kg × 6   [Drop Set]  
```
PRs highlighted with `gymLime` badge.

---

### 7C — Start Workout (Centre Tab — `Views/StartWorkout/StartWorkoutView.swift`)

This is a sheet/full screen cover. Two sections:

**Section 1: My Templates**
- Horizontal scroll of template cards:
```
┌──────────────────┐
│ 💪               │
│ Push Day A       │
│ 6 exercises      │
│ Last: 3d ago     │
└──────────────────┘
```
Card left border = template's `colorHex`. Tap → confirm and go to `ActiveWorkoutView`.

**Section 2: Quick Start**
- [+ Create New Template] button → `TemplateEditorView`
- [Start Empty Workout] → `ActiveWorkoutView` with no template

**`Views/StartWorkout/TemplateEditorView.swift`:**
- Name field, emoji picker (horizontal scroll of 20 emoji options), color picker (8 preset colors)
- Add exercises via `ExercisePicker` (search + filter sheet)
- For each slot: set target sets, reps, weight, rest time with steppers
- Save → creates `WorkoutTemplate` in SwiftData

---

### 7D — Active Workout (`Views/StartWorkout/ActiveWorkoutView.swift`)

This is the most complex screen. Build it carefully.

**Header:**
```
[✕ Cancel]    PUSH DAY A    [Finish ✓]
              00:47:23        (live timer — elapsed time)
```

**Body — ScrollView, one section per exercise:**
```
[Barbell Bench Press]   [Chest · Triceps]
 ─────────────────────────────────────────
 [W]  Set 1   60 kg  ×  12 reps    [ ✓ ]
 [ ]  Set 2   80 kg  ×  10 reps    [ ✓ ]
 [ ]  Set 3   80 kg  ×  8  reps    [ ✓ ]
              [+ Add Set]
```

**Set Row detail (`Components/Workout/SetRowView.swift`):**
- Leading element: set type badge `[W]` / `[D]` / `[ ]` — tap it → bottom sheet with 3 options (Regular, Warm-up, Drop Set)
- Weight field: tapping opens numeric keypad, stepper (+2.5 / -2.5 kg)
- Reps field: tapping opens numeric keypad, stepper (+1 / -1), toggle button "FAIL" that sets `isFailure = true` and greys out the number
- Checkmark button (right): 44×44pt minimum, `gymLime` when set complete, `gymBorder` when pending
- Completed sets show with a subtle strikethrough tint on the row (not the numbers)

**Rest Timer (`Components/Timer/RestTimerOverlay.swift`):**
After tapping ✓ on a set, present this as a `.sheet` (detent: `.medium`):
```
┌─────────────────────────────────────────┐
│  REST                          [Skip →] │
│                                         │
│           ╭──────────────╮              │
│           │    1:30       │  ← countdown│
│           ╰──────────────╯              │
│      (circular ring, gymLime progress)  │
│                                         │
│      [ − 15s ]        [ + 15s ]         │
└─────────────────────────────────────────┘
```
- Ring drawn with `Canvas` + `TimelineView`
- Haptic on: timer start, every 60s, last 3 seconds (triple pulse)
- `TimerService` drives this — not a local timer
- Dismissing sheet does NOT cancel the timer (it keeps running, shows mini banner in workout)

**Mini timer banner** (when rest sheet is dismissed):
- Slim 36pt bar pinned above tab bar: "REST 0:47 · TAP TO EXPAND" in `gymLime`
- Tap → re-opens sheet

**Finish Workout:**
- Tap [Finish ✓] → confirmation alert "End workout? X sets logged."
- Confirm → persists `WorkoutSession` + all `SetLog`s → navigates to `WorkoutSummaryView`

**`Views/StartWorkout/WorkoutSummaryView.swift`:**
```
🎉 Workout Complete!

Duration:    47 min
Total Volume: 4,200 kg
Sets Logged:  18
Personal Records: 2 🏆

[Personal Records]
  Barbell Bench Press: 90 kg × 8  ← NEW PR

[Done]
```

---

### 7E — Exercises Tab (`Views/Exercises/ExerciseListView.swift`)

**Layout:**
```
[Search bar — "Search exercises..."]
[Filter chips — horizontal scroll]:
  [All] [Chest] [Back] [Shoulders] [Biceps] ...
  
[Alphabetical list — section headers A, B, C...]

A
  Arnold Press              [Shoulders]
  Barbell Back Squat        [Quads · Glutes]
  
B
  ...
  
[+ New Exercise]  ← floating button, bottom right
```

Each row:
- Exercise name (gymWhite, 17pt)
- Body region badges (BadgeLabel components)
- Equipment icon (SF Symbol, gymMuted)
- Custom exercises marked with a small "Custom" chip in `gymAmber`

Tap → `ExerciseDetailView`:
- Name, muscles, equipment, notes
- Chart: last 5 sessions volume for this exercise (simple bar chart using SwiftUI `Chart`)
- Personal record: heaviest set ever

**`Views/Exercises/NewExerciseView.swift`:**
```
[Exercise Name field]
[Primary Muscle — grid of BodyRegion chips, tap to select, gymLime when selected]
[Secondary Muscles — same grid, multi-select]
[Equipment — horizontal chip selector]
[Notes — multiline text field]
[Save Exercise]
```
Saves as `Exercise` with `isCustom = true` via DataService.

---

## STEP 8 — ViewModels

Implement all ViewModels following the contract in `agents/backend_dev.md`. Key requirements:

- All `@Observable @MainActor`
- `ActiveWorkoutViewModel` is the most critical — it must:
  - Track elapsed time (separate from rest timer) using a `Task`-based loop
  - Maintain `[ExerciseState]` array where each has `[SetState]` (transient, not yet in SwiftData)
  - On `completeSet()`: persist `SetLog` immediately, check if it's a PR, trigger `TimerService.start()`
  - On `finishWorkout()`: create `WorkoutSession`, attach all `SetLog`s, call `DataService.saveSession()`
  - Compute PR at log time: query SwiftData for the highest `(weightKg × reps)` for that exercise

---

## STEP 9 — Components

### `GymButton.swift`
Three styles as `ButtonStyle`:
- `.primary` — `gymLime` fill, black text, `Radius.pill`, 52pt height
- `.secondary` — transparent fill, `gymLime` 1pt border, `gymLime` text
- `.ghost` — transparent, `gymMuted` text

### `BadgeLabel.swift`
Small pill badge: `Text` with padding `(h:8, v:4)`, `Radius.pill`, background tint based on content:
- BodyRegion → `gymSurface` bg, `gymMuted` text
- SetType.warmUp → `gymAmber` at 20% opacity, `gymAmber` text
- SetType.dropSet → `gymRed` at 20% opacity, `gymRed` text
- "PR" badge → `gymLime` at 20% opacity, `gymLime` text, "🏆"

### `SetTypeSelector.swift`
Bottom sheet with 3 rows (Regular, Warm-up, Drop Set). Each row has a color swatch, name, and description. Checkmark on currently selected. Dismiss on tap.

---

## STEP 10 — Constants & Utilities

### `Utilities/Constants.swift`
```swift
enum Defaults {
    static let restSeconds = 90
    static let maxSetsPerExercise = 20
    static let warmUpReps = 15
    static let defaultWeight = 20.0  // kg
}
```

### `Utilities/Formatters.swift`
- `formatDuration(_ seconds: Int) -> String` → "47m" or "1h 23m"
- `formatWeight(_ kg: Double) -> String` → "80 kg" or "80.5 kg" (omit .0)
- `formatVolume(_ kg: Double) -> String` → "4,200 kg" with thousands separator
- `formatRestTimer(_ seconds: Int) -> String` → "1:30" or "0:45"

---

## STEP 11 — Quality Rules (Non-Negotiable)

Read `agents/reviewer.md` for the full checklist. These are the hard rules:

1. **No business logic in Views** — computed properties that do work → move to ViewModel
2. **No hardcoded colors** — only `Color.gymXxx` tokens
3. **No hardcoded font sizes** — only `.gymFont()` modifier
4. **All touch targets ≥ 44×44pt** — especially the set checkmark and type badge
5. **All `modelContext.save()` in do/catch** — never `try?`
6. **TimerService is a singleton** — injected via `.environment`, never instantiated twice
7. **SetLog is written immediately on set completion** — never batch at the end
8. **Preview providers for every View** — use `.modelContainer(for:, inMemory: true)` with sample data
9. **No force unwraps** (`!`) anywhere in the codebase
10. **Dark mode only** (`.preferredColorScheme(.dark)` on root)

---

## STEP 12 — After Each File You Create

Append one line to `project_context.md` under section "7. Change Log":
```
[DATE] [AGENT_NAME] [relative/file/path.swift] — [one line description of what was built]
```

---

## STEP 13 — Build Order (Follow This Exactly)

Build in this sequence to avoid missing dependencies:

```
1.  DesignSystem/Colors.swift
2.  DesignSystem/Typography.swift
3.  DesignSystem/Spacing.swift
4.  Models/Enums.swift
5.  Models/Exercise.swift
6.  Models/ExerciseSlot.swift
7.  Models/WorkoutTemplate.swift
8.  Models/SetLog.swift
9.  Models/WorkoutSession.swift
10. Resources/exercises.json
11. Utilities/Constants.swift
12. Utilities/Formatters.swift
13. Utilities/Extensions.swift
14. Services/TimerService.swift
15. Services/ExerciseLibraryService.swift
16. Services/DataService.swift
17. Components/Common/GymButton.swift
18. Components/Common/BadgeLabel.swift
19. Components/Common/SectionHeader.swift
20. Components/Workout/SetTypeSelector.swift
21. Components/Workout/WeightInput.swift
22. Components/Workout/RepInput.swift
23. Components/Workout/SetRowView.swift
24. Components/Timer/RestTimerOverlay.swift
25. ViewModels/ExerciseLibraryViewModel.swift
26. ViewModels/TemplateListViewModel.swift
27. ViewModels/TemplateEditorViewModel.swift
28. ViewModels/ActiveWorkoutViewModel.swift
29. ViewModels/HistoryViewModel.swift
30. ViewModels/HomeViewModel.swift
31. Views/Exercises/NewExerciseView.swift
32. Views/Exercises/ExerciseDetailView.swift
33. Views/Exercises/ExerciseListView.swift
34. Views/StartWorkout/TemplateEditorView.swift
35. Views/StartWorkout/ActiveWorkoutView.swift
36. Views/StartWorkout/WorkoutSummaryView.swift
37. Views/StartWorkout/StartWorkoutView.swift
38. Views/History/WorkoutDetailView.swift
39. Views/History/HistoryView.swift
40. Views/Profile/ProfileView.swift
41. Views/MainTabView.swift
42. App/AppRouter.swift
43. App/GymerApp.swift
```

---

## FINAL CHECKLIST — Before Declaring Done

- [ ] App compiles without errors or warnings
- [ ] All 4 tabs are navigable
- [ ] A template can be created, saved, and used to start a workout
- [ ] Sets can be logged with weight, reps, set type, and failure toggle
- [ ] Rest timer opens after completing a set, counts down, dismisses automatically
- [ ] Workout can be finished and appears in History
- [ ] History shows duration, volume, PR badges correctly
- [ ] Exercise list shows all 60+ exercises, searchable and filterable
- [ ] New custom exercise can be created from Exercise tab
- [ ] Profile shows total workout count, this month count, recent PRs
- [ ] No hardcoded colors (grep for `#` in swift files — must be zero)
- [ ] No force unwraps (grep for `!` excluding `!=` — must be zero in Models/ViewModels)
- [ ] Every View has a `#Preview` block
- [ ] `project_context.md` diff log has an entry for every file created
