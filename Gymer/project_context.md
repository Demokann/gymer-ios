# Project Context Snapshot
> Token Optimization File — Agents read this instead of scanning the entire codebase.

**Last Updated:** 30.04.2026
**Updated By:** Demokan

---

## 1. Project Status

```
Version   : 0.1.0 (Scaffolding)
Platform  : iOS (Swift 5.9+, iOS 17+)
UI        : SwiftUI
Pattern   : MVVM
Storage   : SwiftData (local persistence)
State     : @Observable macro (Swift 5.9)
```

---

## 2. File Tree (Source Map)

```
Gymer/
├── App/
│   ├── GymerApp.swift            → @main entry point, SwiftData container setup
│   └── AppRouter.swift           → Root navigation / tab controller
│
├── Assets/
│   ├── Colors/
│   │   └── Colors.xcassets       → Brand color palette (see §3 for tokens)
│   ├── Fonts/
│   │   └── (custom fonts here)
│   └── Icons/
│       └── Icons.xcassets        → SF Symbol overrides + custom icons
│
├── Models/                       → SwiftData @Model classes (source of truth)
│   ├── WorkoutTemplate.swift     → Template entity (Push/Pull/Legs etc.)
│   ├── ExerciseSlot.swift        → Exercise inside a template
│   ├── WorkoutSession.swift      → A completed or in-progress session
│   ├── SetLog.swift              → Individual set record
│   └── BodyRegion.swift          → Enum: chest | back | shoulders | biceps | triceps | quads | hamstrings | glutes | calves | abs | full_body
│
├── ViewModels/
│   ├── TemplateListViewModel.swift
│   ├── TemplateEditorViewModel.swift
│   ├── ActiveWorkoutViewModel.swift   → Owns timer logic + set state
│   └── HistoryViewModel.swift
│
├── Views/
│   ├── Home/
│   │   └── HomeView.swift             → Dashboard: recent sessions + quick-start
│   ├── Template/
│   │   ├── TemplateListView.swift     → List of all workout templates
│   │   ├── TemplateEditorView.swift   → Create / edit a template
│   │   └── ExercisePickerView.swift   → Browse & add exercises to template
│   ├── Workout/
│   │   ├── ActiveWorkoutView.swift    → Main workout screen (sets, reps, weight)
│   │   ├── SetRowView.swift           → Individual set row with type selector
│   │   ├── RestTimerView.swift        → Countdown overlay / sheet
│   │   └── WorkoutSummaryView.swift   → Post-workout summary
│   └── Settings/
│       └── SettingsView.swift
│
├── Components/
│   ├── Common/
│   │   ├── GymButton.swift            → Primary / secondary / ghost button styles
│   │   ├── SectionHeader.swift        → Reusable section header with action
│   │   └── BadgeLabel.swift           → Body region / difficulty badge
│   ├── Workout/
│   │   ├── SetTypeSelector.swift      → Regular | Drop Set | Warm-up | Failure
│   │   ├── RepInput.swift             → Numeric picker + "Failure" toggle
│   │   └── WeightInput.swift          → kg input with +/- stepper
│   └── Timer/
│       └── RestTimerOverlay.swift     → Full-screen rest countdown
│
├── Services/
│   ├── DataService.swift              → SwiftData CRUD helpers
│   ├── TimerService.swift             → Combine-based countdown timer
│   └── ExerciseLibrary.swift          → Bundled exercise catalogue (JSON → in-memory)
│
├── Utilities/
│   ├── Extensions.swift               → Color+hex, View+haptics, etc.
│   ├── Constants.swift                → Rest time defaults, max sets, etc.
│   └── Formatters.swift               → Time, weight string formatters
│
├── Resources/
│   └── exercises.json                 → Bundled exercise database
│       // Schema: { id, name, bodyRegions: [BodyRegion], equipment, notes }
│
└── agents/
    ├── planning.md                    ← READ-ONLY  strategic planning agent
    ├── ui_designer.md                 ← READ + WRITE  UI/UX agent
    ├── backend_dev.md                 ← READ + WRITE  data/logic agent
    ├── reviewer.md                    ← READ-ONLY  code review agent
    └── (project_context.md lives in root, not here)
```

---

## 3. Design System Tokens

### Colors (define in Colors.xcassets + extension)
```swift
extension Color {
    // Backgrounds
    static let gymBlack    = Color("GymBlack")    // #0D0D0D  primary bg
    static let gymSurface  = Color("GymSurface")  // #1A1A1A  card bg
    static let gymCard     = Color("GymCard")      // #222222  elevated card

    // Accents
    static let gymLime     = Color("GymLime")      // #C6FF00  primary accent (electric lime)
    static let gymRed      = Color("GymRed")       // #FF3B30  danger / failure / drop-set
    static let gymAmber    = Color("GymAmber")     // #FF9F0A  warm-up / secondary

    // Text
    static let gymWhite    = Color("GymWhite")     // #F5F5F5  primary text
    static let gymMuted    = Color("GymMuted")     // #6B6B6B  secondary text
    static let gymBorder   = Color("GymBorder")    // #2C2C2C  dividers
}
```

### Typography
```swift
// Use SF Pro (system) — no custom font needed for v1
// Sizes follow iOS HIG scale
enum GymFont {
    case largeTitle   // 34pt bold  — screen titles
    case title        // 22pt bold  — section headings
    case body         // 17pt regular — default text
    case caption      // 13pt regular — badges, labels
    case mono         // 17pt monospaced — weight/rep numbers
}
```

---

## 4. Core Data Models (SwiftData)

```swift
// WorkoutTemplate
@Model class WorkoutTemplate {
    var id: UUID
    var name: String            // "Push Day A", "Upper Body"
    var emoji: String           // "💪"
    var colorHex: String        // accent color for card
    var slots: [ExerciseSlot]   // ordered list of exercises
    var createdAt: Date
    var lastUsedAt: Date?
}

// ExerciseSlot (exercise within a template)
@Model class ExerciseSlot {
    var id: UUID
    var exerciseId: String      // references ExerciseLibrary
    var order: Int
    var targetSets: Int
    var targetReps: Int?        // nil = failure
    var targetWeight: Double?
    var defaultRestSeconds: Int // default rest after each set
}

// WorkoutSession (a live or completed workout)
@Model class WorkoutSession {
    var id: UUID
    var template: WorkoutTemplate?
    var startedAt: Date
    var finishedAt: Date?
    var setLogs: [SetLog]
    var totalVolume: Double      // computed: sum(weight * reps)
}

// SetLog (one recorded set)
@Model class SetLog {
    var id: UUID
    var exerciseId: String
    var setIndex: Int
    var setType: SetType        // .regular | .dropSet | .warmUp | .failure
    var weightKg: Double
    var reps: Int?              // nil = failure (didn't count)
    var isFailure: Bool
    var completedAt: Date
}

enum SetType: String, Codable {
    case regular, dropSet, warmUp, failure
}
```

---

## 5. Screen Flow Map

```
TabView (AppRouter)
 ├── HomeView
 │     └── [Start Workout] → TemplateListView (sheet)
 │           └── tap template → ActiveWorkoutView (full-screen cover)
 │                 ├── SetRowView (per exercise, per set)
 │                 │     ├── SetTypeSelector (swipe-left or leading tap)
 │                 │     ├── WeightInput
 │                 │     └── RepInput (+ Failure toggle)
 │                 ├── [✓ Set Done] → RestTimerOverlay (sheet/overlay)
 │                 │     └── countdown ends / skip → dismiss
 │                 └── [Finish Workout] → WorkoutSummaryView
 │
 ├── TemplateListView
 │     ├── [+] → TemplateEditorView
 │     │         └── ExercisePickerView (filtered by body region)
 │     └── tap → TemplateEditorView (edit mode)
 │
 └── SettingsView
       ├── Default rest time
       ├── Weight unit (kg / lbs)
       └── About
```

---

## 6. Key Business Rules

| Rule | Detail |
|------|--------|
| Set completion | Tapping checkmark on a set → logs it → auto-triggers rest timer |
| Rest timer | Default per template slot; overridable per session; shown as fullscreen countdown overlay |
| Failure reps | `isFailure = true` → reps field shows "F" in UI, stored as `nil` |
| Drop set | Visual indicator (red badge); no automatic weight change — user edits manually |
| Volume calc | `totalVolume = Σ (weightKg × reps)` — failure sets excluded |
| Template copy | Long-press template → "Duplicate" option |

---

## 7. Change Log (Diff Log)

> Format: `[DATE] [AGENT] [FILE] — [WHAT CHANGED]`

```
[2026-04-25] [Planning] agents/ — Initial agent files scaffolded
[2026-04-25] [Planning] project_context.md — First version created, full structure defined
./Components/Common/BadgeLabel.swift
./Components/Common/GymButton.swift
./ContentView.swift
./DesignSystem/Colors.swift
./DesignSystem/Spacing.swift
./DesignSystem/Typography.swift
./GymerApp.swift
./Models/Enums.swift
./Models/Exercise.swift
./Models/ExerciseSlot.swift
./Models/SetLog.swift
./Models/WorkoutSession.swift
./Models/WorkoutTemplate.swift
./Resources/exercises.json
./Services/DataService.swift
./Services/ExerciseLibraryService.swift
./Services/TimerService.swift
./Utilities/Constants.swift
./Utilities/Extensions.swift
./Utilities/Formatters.swift
```

---

## 8. Known Constraints & Tech Debt

| # | Issue | Level | Target |
|---|-------|-------|--------|
| 1 | No iCloud sync (SwiftData local only) | MEDIUM | v1.1 |
| 2 | Exercise library is bundled JSON, not user-editable | MEDIUM | v1.1 |
| 3 | No Apple Watch companion app | LOW | v2.0 |
| 4 | No progressive overload suggestions | LOW | v1.2 |
| 5 | Accessibility (a11y / VoiceOver) not audited | MEDIUM | v1.1 |
| 6 | Landscape layout not designed | LOW | v1.1 |

---

## 9. Agent Update Protocol

**When to update this file:**
- After creating a new file → add to File Tree
- After adding a new public function/ViewModel → add to API surface
- After changing a Model → update §4
- After screen flow changes → update §5
- Always → append a line to Change Log §7

**How to update:**
- Only edit the changed section
- Do NOT rewrite the whole file
- Always append to the diff log, never edit past entries
- Use real date (format: DD.MM.YYYY)
[2026-04-30] [Backend Dev] Components/Common/SectionHeader.swift — Reusable section header with optional action button
[2026-04-30] [Backend Dev] Components/Workout/SetTypeSelector.swift — Selection sheet for set types (Regular, Warm-up, Drop Set)
[2026-04-30] [Backend Dev] Components/Workout/WeightInput.swift — Numeric input for weight with +/- 2.5kg steppers
[2026-04-30] [Backend Dev] Components/Workout/RepInput.swift — Numeric input for reps with +/- 1 steppers and failure toggle
[2026-04-30] [Backend Dev] Components/Workout/SetRowView.swift — Integrated row component for logging sets with weight, reps, and type
[2026-04-30] [Backend Dev] Components/Timer/RestTimerOverlay.swift — Full-screen rest timer with progress ring and adjustments
[2026-04-30] [Backend Dev] ViewModels/ExerciseLibraryViewModel.swift — Manages exercise list, searching, and filtering by body region
[03.05.2026] [Backend Dev] ViewModels/TemplateListViewModel.swift — Manages workout template list, deletion, and duplication
[03.05.2026] [Backend Dev] ViewModels/TemplateEditorViewModel.swift — Handles creating and editing workout templates with exercise slots
[03.05.2026] [Backend Dev] ViewModels/ActiveWorkoutViewModel.swift — Manages live workout state, set logging, and rest timer integration
[03.05.2026] [Backend Dev] ViewModels/HistoryViewModel.swift — Fetches and groups workout sessions by month for history view
[03.05.2026] [Backend Dev] ViewModels/HomeViewModel.swift — Calculates dashboard stats, streaks, and muscle group distribution
[03.05.2026] [UI Designer] Views/Exercises/NewExerciseView.swift — Form for creating custom exercises with muscle group and equipment selection
[04.05.2026] [UI Designer] Views/Exercises/ExerciseDetailView.swift — Detail view for exercises with personal records and volume history chart
[04.05.2026] [UI Designer] Views/Exercises/ExerciseListView.swift — Searchable and filterable list of all exercises with alphabetical grouping
[04.05.2026] [UI Designer] Views/StartWorkout/TemplateEditorView.swift — Editor for workout templates including name, emoji, color, and exercise slots with target settings
[04.05.2026] [UI Designer] Views/StartWorkout/ActiveWorkoutView.swift — Live workout tracking screen with set logging, exercise management, and rest timer integration
[04.05.2026] [UI Designer] Views/StartWorkout/WorkoutSummaryView.swift — Post-workout summary screen displaying key stats and new personal records
[04.05.2026] [UI Designer] Views/StartWorkout/StartWorkoutView.swift — Workout initiation hub with template selection and quick start options
[05.05.2026] [UI Designer] Views/History/WorkoutDetailView.swift — Detail view for completed workout sessions with exercise breakdown and PRs
[05.05.2026] [UI Designer] Views/History/HistoryView.swift — Grouped list of past workout sessions with summary cards
[05.05.2026] [UI Designer] Views/Profile/ProfileView.swift — User profile screen with workout stats, recent PRs, and muscle distribution chart
[05.05.2026] [UI Designer] Views/MainTabView.swift — Root tab navigation with custom oversized centre button for starting workouts
[05.05.2026] [Backend Dev] App/AppRouter.swift — Root navigation controller hosting the main tab view
[05.05.2026] [Backend Dev] App/GymerApp.swift — App entry point with SwiftData container and global dark theme setup
[07.05.2026] [Reviewer] Components/Common/BadgeLabel.swift — API güncellendi: BadgeType → Style enum, text/style parametreleri eklendi
[07.05.2026] [Reviewer] Utilities/Formatters.swift — weight(_ kg: Double) static func eklendi
[07.05.2026] [Reviewer] Views/MainTabView.swift — StartWorkoutView'a modelContext argümanı eklendi
'[07.05.2026] [Reviewer] Views/StartWorkout/WorkoutSummaryView.swift — #Preview bloğu closure pattern ile yeniden yazıldı, return keyword ve SetLog setIndex parametresi düzeltildi'
