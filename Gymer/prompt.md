I'm adding a "pre-fill from last session" feature to the Gymer iOS app (SwiftUI + SwiftData, iOS 17+, MVVM with @Observable).

## What I want
When the user taps a WorkoutTemplate to start a workout, the active workout screen should open with each set pre-filled with the weight, reps, and set type from the last time that same template was used — so the user only needs to change values if something is different today. If I just created an template with initial weight eventhough haven't any workouts made yet it should come with the initial weights I created that template if there has been a workout completed same template comes with the last workout weights, and reps etc.

## Exact behavior
1. When a workout is started from a template, look up the most recent completed `WorkoutSession` that was created from that template.
2. For each `ExerciseSlot` in the template, find the matching sets from that previous session (match by exercise identity).
3. Pre-fill the current session's set rows with: `weight`, `reps`, `setType`, and `isFailure` from the previous session's corresponding `SetLog` entries.
4. If a previous session had fewer sets than the template's `targetSets`, pre-fill what exists and leave the rest at defaults.
5. If no previous session exists for this template, fall back to the existing default behavior (targetReps, defaultRestSeconds, weight = 0).
6. The pre-filled values are editable — the user can change anything freely. Pre-fill is just a starting point.
7. `isPersonalRecord` should always start as `false` for the new session regardless of what it was before.

## Data model context
- `WorkoutTemplate` — has a list of `ExerciseSlot`
- `ExerciseSlot` — has `exercise` reference, `targetSets`, `targetReps`, `defaultRestSeconds`
- `WorkoutSession` — has `startedAt`, `finishedAt`, list of `SetLog`, and a reference back to its template
- `SetLog` — has `weight`, `reps`, `setType`, `isFailure`, `isPersonalRecord`

Check the actual SwiftData model files to confirm property names and relationships before making changes.

## Files to touch
- `Models/WorkoutSession.swift` — confirm there is a template reference; if not, add one so sessions know which template they came from (needed for the lookup)
- `Services/DataService.swift` — add a method `lastSession(for template: WorkoutTemplate) -> WorkoutSession?` that fetches the most recent finished session for a given template, sorted by `finishedAt` descending, limit 1
- `ViewModels/ActiveWorkoutViewModel.swift` — update the initializer / `startWorkout(from:)` method to call `DataService.lastSession(for:)` and apply pre-fill logic before the view appears
- `Views/StartWorkout/ActiveWorkoutView.swift` — no logic changes expected here, but verify the set rows display pre-filled values correctly on first render

## Constraints
- Do not change how sets are saved or how PRs are detected — only the initial state of a new session changes
- Stay within SwiftData — no extra persistence layer
- No third-party libraries
- iOS 17+, use `@Observable`
- Read all relevant files before making changes to understand current data flow
