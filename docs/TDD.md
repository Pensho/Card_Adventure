# Technical Design Document — Card Adventure

**Status:** Draft v0.4
**Last updated:** 2026-04-23

---

## 1. Tech Stack

| Concern | Choice |
|---------|--------|
| Engine | Godot 4 |
| Language | GDScript |
| Testing | GUT (Godot Unit Testing) |
| Version control | Git + GitHub |
| Art generation | leonardo.ai |

---

## 2. Target Platforms & Distribution

| Platform | Store | Status |
|----------|-------|--------|
| Windows | Steam | v1.0 |
| Linux | Steam | v1.0 |
| Android | Google Play | v1.0 |

macOS is not in scope for v1.0.

---

## 3. Display & Resolution

### Base Viewport

| Setting | Value |
|---------|-------|
| Base resolution | 1280 × 720 |
| Orientation | Landscape (locked on Android) |
| Stretch mode | `canvas_items` |
| Stretch aspect | `expand` |

### Rationale

1280 × 720 scales exactly 1.5× to 1920 × 1080 and exactly 2× to 2560 × 1440 on PC. Touch targets at this base are large enough to be comfortable on mid-range Android hardware. The `expand` aspect mode lets wider viewports (ultrawide PC, 20:9 Android phones) show slightly more scene content without distortion — portrait notch and navigation bar insets are handled via `DisplayServer.get_display_safe_area()`.

### Safe Zone

All interactive controls and HUD elements must be positioned within the **1120 × 630 safe zone** centred in the base viewport (80 px margin each side). Background art and decorative elements may bleed to the full 1280 × 720 and beyond.

### Card Art Dimensions

Card source art is generated at **512 × 768 px** (2:3 ratio). Display size in-hand is determined during UI prototyping; the 2× source ensures crispness on high-DPI Android screens.

---

## 4. Input Handling

### Primary Input Methods

| Platform | Primary | Secondary |
|----------|---------|-----------|
| PC (Windows / Linux) | Mouse | Keyboard shortcuts |
| Android | Touch | — |

Mouse button events and screen touch events share the same response logic wherever possible. Avoid platform-specific branches in game logic — use Godot's built-in input abstraction.

### Card Interaction

| Action | PC | Android |
|--------|----|---------|
| Play card | Drag to play area, or click to select then click target | Tap to select, tap target |
| Inspect card | Right-click | Long-press |
| End turn | Click End Turn button | Tap End Turn button |

The End Turn button and any other primary action controls must meet a **minimum 80 × 80 px logical touch target** on Android.

### Keyboard Shortcuts (PC)

| Key | Action |
|-----|--------|
| `1` – `5` | Select the corresponding card in hand (left to right) |
| `Enter` | Accept / confirm / proceed (end turn, confirm choice) |
| `Escape` | Cancel / decline / back |
| `Tab` | Cycle targeting through available enemies |

This list is intentionally minimal. Additional shortcuts will be added as specific UI flows are prototyped. When adding a shortcut, ensure it does not conflict with Godot editor defaults in debug builds.

### Controller

Not in scope for v1.0.

---

## 5. Architecture Overview

The game uses a scene-per-screen structure with a persistent `GameState` autoload as the single source of truth for all run state. `GameState` survives scene transitions and holds the active deck, party state, depth, and equipped items. Scenes read from `GameState` and emit or listen to signals; `GameState` never holds direct references to scene nodes.

Card effect logic and game rules live in scripts and resource classes, not in scene nodes. Scene nodes are responsible for display and input only.

---

## 6. Scene & Node Architecture

### Key Scenes

| Scene | Purpose |
|-------|---------|
| `game/Battle.tscn` | Main battle scene; drives turn loop |
| `game/DungeonJunction.tscn` | Passage selection between rooms |
| `ui/HUD.tscn` | In-battle HUD (instantiated inside Battle) |
| `ui/MainMenu.tscn` | Main menu |
| `ui/CharacterSelect.tscn` | Run-start character selection |
| `ui/EquipmentScreen.tscn` | Gear management at respite / merchant |
| `ui/Discovery.tscn` | Discovery / event screen |
| `ui/GameOver.tscn` | Game over and victory screen |
| `cards/Card.tscn` | Individual card node (display only) |

### Ownership Rules

- `GameState` owns all persistent run data; it is the only writer of run state
- `Battle.tscn` owns combat execution — spawns enemies, resolves turns, drives the combat state machine
- `HUD.tscn` observes `GameState` signals and updates display; it does not mutate state directly
- `Card.tscn` nodes are display-only; card effect logic lives in `CardEffect` resource subclasses

---

## 7. Data Architecture

### Card Definitions

Cards are defined as Godot `Resource` subclasses (`.tres` files) and indexed by `CardDatabase` at startup. Using resources over JSON gives static typing, editor tooling, and built-in serialisation.

```
res://scripts/data/card_data.gd       # Base CardData resource
res://scripts/data/card_effect.gd     # Base CardEffect resource
res://data/cards/                     # .tres card definition files
```

### Persistence Files

| File | Contents | When written |
|------|----------|-------------|
| `user://savegame.json` | Full run state snapshot | Every room transition |
| `user://persistent.json` | Roster unlocks; cross-run state | Run end (win or death) |

`user://` maps to platform-appropriate internal storage on all three targets. No additional Android permissions are required. Saves are not encrypted for v1.0.

If `savegame.json` exists on launch, the game offers to resume. Incompatible or corrupt saves are discarded with a warning — no recovery beyond the last autosave.

---

## 8. Card Data Pipeline

When a character equips or unequips an item, the deck is rebuilt immediately:

1. `GameState.equip_item(character, slot, item)` stores the change
2. `GameState._rebuild_deck()` collects all `CardData` entries from every equipped item across both characters, shuffles the result using the run RNG, and sets `GameState.deck`
3. If in combat, `GameState` emits `deck_changed`; `Battle` observes this and updates the live draw pile

Curse cards contributed by an item are removed when the item is unequipped (Symbiote absorption exception applies per GDD rules).

---

## 9. Signal Conventions

Use signals for:
- Cross-scene communication
- UI updates triggered by game logic
- `GameState` broadcasting state changes to scene observers

Do not use signals for:
- Calls within the same node / script
- Chains longer than 2 hops — restructure with a direct call or intermediate autoload instead

---

## 10. Autoloads / Singletons

| Name | Responsibility |
|------|---------------|
| `GameState` | Active run state: party, deck, depth, equipped items |
| `CardDatabase` | All card definitions, indexed by resource ID |
| `AudioManager` | Music and SFX playback; bus routing |

---

## 11. Save & Persistence

See Section 7 for file locations and write timing.

**Save file versioning:** A `version` field is written to both save files. On load, if the version does not match the current build, the save is discarded. A migration path can be added post-v1.0 if needed.

**What persists between runs (`persistent.json`):**
- Roster unlocks — array of unlocked character IDs
- Discovered lore entries — array of lore entry IDs (shown in a lore log; ID added on first encounter)
- Discovered bestiary entries — array of enemy IDs (shown in a bestiary; ID added on first encounter)

New IDs are simply appended to the relevant array when something is encountered for the first time. The lore log and bestiary screens display entries whose IDs are present; everything else is hidden.

**What resets on death:**
- Everything else: deck, party HP, items, depth, run seed

### Save File Migration

Two-tier strategy:

1. **Additive change** (new field added to the save format): assign a sensible default on load if the field is absent. Old saves load without issue — no version bump required.
2. **Structural change** (field renamed, removed, or format changed): increment the `version` field in `project.godot`. On load, if the save version does not match, discard the save and show the message: *"A game update changed save data. Your previous run could not be continued."* For a roguelike, losing a run to a version mismatch is an acceptable tradeoff over maintaining a migration layer.

Structural changes should be batched where possible so players are affected at most once per minor release.

---

## 12. RNG & Reproducibility

All randomness (deck shuffles, room content, loot rolls) routes through a single `RandomNumberGenerator` instance held by `GameState`. The seed is generated at run start and stored in `savegame.json`.

This enables:
- Reproducible runs for debugging — set seed manually in debug builds
- Consistent behaviour across save and resume cycles

The dungeon layout is not pre-generated. Passages are resolved lazily at each junction using the seeded RNG. No run replay or share-seed feature is planned for v1.0.

---

## 13. Audio Architecture

### Bus Layout

```
Master
├── Music       (overall volume, pitch)
└── SFX
    ├── UI      (card plays, button clicks, menu transitions)
    └── Combat  (attacks, card effects, ambient dungeon)
```

### Ownership

`AudioManager` autoload handles all playback. Scenes request sounds by name or ID; they do not own `AudioStreamPlayer` nodes for shared sounds.

### Music

One track per context, swapped on scene transition. Dynamic layer mixing is not in scope for v1.0.

| Track | Context |
|-------|---------|
| `menu` | Main menu |
| `dungeon` | Dungeon navigation / junction view |
| `combat` | Battle scene |
| `discovery` | Discovery / event screen |
| `sting_victory` | Short one-shot on combat win |
| `sting_death` | Short one-shot on party wipe |

All tracks loop except stings. `AudioManager` crossfades between looping tracks with a short fade to avoid hard cuts.

### Formats

- Music: `.ogg` (looping)
- SFX: `.wav` for short clips, `.ogg` for longer ambient loops

---

## 14. Asset Pipeline

### Textures

| Asset type | Source size | Filter | Compression |
|------------|-------------|--------|-------------|
| Card art | 512 × 768 px | Linear | Lossy |
| Character portrait | 240 × 240 px | Linear | Lossy |
| Enemy sprite | TBD | Linear | Lossy |
| UI icons | 2× display size | Linear | Lossless |
| Background art | 1280 × 720 px | Linear | Lossy |

All source art is generated via leonardo.ai at the sizes above. See `docs/ART_STYLE.md` for generation guidelines.

### Import Notes

- Enable **Mipmaps** on backgrounds and large textures rendered at varying sizes
- Disable mipmaps on pixel-art or icon assets where sharpness matters more than downscale quality
- Android texture compression: use **ETC2** (supported on all Android 7+ devices)

---

## 15. Testing Strategy

- Unit-test all card effect logic
- Unit-test game state transitions: equip / unequip deck rebuild, toll resolution, character state transitions
- Unit-test RNG-dependent logic using fixed seeds
- Do not test rendering or animations
- GUT test files mirror the `scripts/` structure under `tests/`

---

## 16. Build & Export

| Target | Export template | Notes |
|--------|----------------|-------|
| Windows | Godot 4 Windows x86_64 | Steam build |
| Linux | Godot 4 Linux x86_64 | Steam build |
| Android | Godot 4 Android | Google Play; requires release keystore |

CI is not configured for v1.0. Manual export via the Godot editor.

**Versioning:** `MAJOR.MINOR.PATCH` stored in `project.godot`. Increment patch for hotfixes, minor for feature releases.

**Android specifics:**
- Minimum SDK: 24 (Android 7.0)
- Target SDK: 34
- Orientation locked to landscape in Android export settings
- Release keystore stored outside the repo; path and credentials configured in local editor settings only

### Google Play Pre-Submission Checklist

Complete the following in the Google Play Console before submitting for review:

**Age Rating (IARC questionnaire)**
Google uses the IARC system — one questionnaire that generates ratings for all regions simultaneously. Based on Card Adventure's content (fantasy combat, cosmic horror themes, no gore, no sexual content, no gambling), expected ratings are **PEGI 12 / ESRB Teen** in most regions. Answer the questionnaire honestly; it takes approximately 5 minutes.

**Privacy Policy**
Required by Google Play even when the app collects no personal data. Host a simple page at a stable URL (GitHub Pages is sufficient) containing the following statement, adapted as needed:

> *Card Adventure does not collect, store, or share any personal data. Save files are stored locally on your device and are never transmitted.*

Link this URL in the Play Console store listing under "Privacy Policy".

**Data Safety Form**
Declare what data the app collects and shares. For Card Adventure v1.0:
- Data collected by the app: **None**
- Data shared with third parties: **None**
- Security practices: check "Data is encrypted in transit" (Google Play handles this)

Submit the form; it takes effect on the store listing immediately.

---

## 17. Accessibility

Minimum bar for v1.0:

- All interactive elements meet a **44 × 44 dp minimum touch target** on Android
- Body text minimum **16 px logical** at base resolution
- Colour is never the sole carrier of information — card types and character states use shape or label in addition to colour

Colourblind palette support and font-size scaling are post-v1.0.

---

## 18. Performance Considerations

### Targets

| Platform | Target | Notes |
|----------|--------|-------|
| PC | 60 fps | Uncapped acceptable |
| Android | 60 fps | Mid-range target: Snapdragon 680-class or equivalent |

### Guidelines

- Battle scene: no more than ~50 active nodes at peak
- Card animations use `Tween` rather than `AnimationPlayer` where practical
- Avoid per-frame allocations in combat hot paths (no `Array` / `Dictionary` literals inside `_process`)
- Profile on Android before optimising for PC — bottlenecks differ

---

## 20. Combat State Machine

`Battle.tscn` manages combat through an explicit state machine. State is stored as an enum in `battle.gd` and transitions are driven by method calls — never by external scenes or UI nodes.

### States

| State | Description |
|-------|-------------|
| `INITIALIZING` | Spawn enemies, build starting deck from equipped items, initialise character states |
| `ROUND_START` | Apply start-of-round triggers; grant `Coiled` to characters who did not act last turn |
| `DRAWING` | Draw cards to fill hand; if the deck is empty, shuffle the discard pile into it first |
| `PLAYER_TURN` | Awaiting player input — card selection, card play, or end turn |
| `TARGETING` | A card requiring an explicit target is selected; awaiting target confirmation or cancellation |
| `RESOLVING` | A card effect or enemy action is executing; all player input is blocked until resolution completes |
| `ENEMY_TURN` | Enemies execute their intents one at a time; each action passes through `RESOLVING` |
| `COMBAT_OVER` | Terminal state; a `victory: bool` flag determines which outcome sequence plays |

### Transitions

| From | To | Trigger |
|------|----|---------|
| `INITIALIZING` | `ROUND_START` | Setup complete |
| `ROUND_START` | `DRAWING` | Start-of-round effects applied |
| `DRAWING` | `PLAYER_TURN` | Hand filled |
| `PLAYER_TURN` | `TARGETING` | Card requiring a target is selected |
| `PLAYER_TURN` | `RESOLVING` | Card without an explicit target is played |
| `PLAYER_TURN` | `ENEMY_TURN` | End turn pressed |
| `TARGETING` | `PLAYER_TURN` | Targeting cancelled |
| `TARGETING` | `RESOLVING` | Target confirmed |
| `RESOLVING` | `PLAYER_TURN` | Effect resolved; player phase active; no outcome |
| `RESOLVING` | `ENEMY_TURN` | Effect resolved; enemy phase active; no outcome |
| `RESOLVING` | `COMBAT_OVER` | All enemies dead (victory) or full party downed (defeat) |
| `ENEMY_TURN` | `RESOLVING` | An enemy executes its intent |
| `ENEMY_TURN` | `ROUND_START` | All enemies have acted; no outcome |

### Outcome Check

`_check_outcome()` is called at the end of every `RESOLVING` exit, before transitioning to the next state:
- All enemies at 0 HP → `COMBAT_OVER` with `victory = true`
- All characters downed → `COMBAT_OVER` with `victory = false`
- Otherwise → return to the appropriate in-progress state

### Return Context

`RESOLVING` stores a `_return_state` variable (set before entering `RESOLVING`) so it knows whether to return to `PLAYER_TURN` or `ENEMY_TURN` after resolution. This is the only state that requires a stored context.

### Input Blocking

Player input (card selection, end turn) is only accepted in `PLAYER_TURN` and `TARGETING` states. `Card.tscn` and `HUD.tscn` check `Battle.current_state` before processing any input event.

---

## 21. Scene Transitions

All scene changes route through a `SceneManager` autoload. Direct calls to `get_tree().change_scene_to_file()` are not used outside of `SceneManager`.

### API

```gdscript
SceneManager.go_to(scene_path: String, data: Dictionary = {}) -> void
```

`data` is an optional payload the incoming scene reads from `SceneManager.incoming_data` in its `_ready()` (e.g. which passage was chosen, post-combat loot results). `incoming_data` is cleared after each transition.

### Transition Style

Dip to black: fade out (0.2 s) → load scene → fade in (0.2 s). `SceneManager` owns a `CanvasLayer` at the highest z-index containing a full-screen black `ColorRect`; a `Tween` drives the alpha. This default is used for all v1.0 transitions.

The duration can be overridden per call if a specific screen requires different pacing, but the style (dip to black) does not change.

### Signals

| Signal | Fired when |
|--------|------------|
| `transition_started` | Fade-out begins |
| `transition_finished` | Fade-in completes and the new scene is interactive |

---

## 22. Localization

Multiple languages are supported. The translation infrastructure is in place from the start so no string retrofitting is needed later.

### Rules

- All player-visible strings are wrapped in `tr()` at the point of use — never hardcoded
- Translation keys use `SCREAMING_SNAKE_CASE` with a namespace prefix (see table below)
- English is the source language; the English `.csv` is the canonical definition
- Untranslated keys fall back to English automatically via Godot's `TranslationServer`

### Key Naming Convention

| Prefix | Used for |
|--------|---------|
| `UI_` | Buttons, labels, HUD elements |
| `CARD_NAME_` | Card display names |
| `CARD_DESC_` | Card descriptions |
| `ITEM_NAME_` | Equipment names |
| `ITEM_DESC_` | Equipment descriptions |
| `ENEMY_NAME_` | Enemy names |
| `STATE_` | Character state names and tooltips |
| `LORE_` | Lore log entries |
| `DISCOVERY_` | Discovery / event text |

### Files

```
res://data/i18n/
├── ui.en.csv
├── cards.en.csv
├── items.en.csv
└── world.en.csv        # enemies, lore, discovery text
```

When a language is added, the translated file is placed alongside its English counterpart (e.g. `ui.de.csv`).

### Dynamic Values

Card descriptions that embed numeric values use format strings:

```gdscript
label.text = tr("CARD_DESC_LANCE_CHARGE").format({"damage": effect.value})
```

The source `.csv` entry uses `{damage}` as the placeholder token. All dynamic tokens are documented in the English source file as a comment on the same row.

---

## 19. Open Technical Questions

- [ ] **Enemy sprite dimensions** — define source size in §14 once first enemy designs are drafted
- [ ] **Lore log / bestiary UI** — scope and screen design (post-prototype)
- [ ] **Steam-specific requirements** — Steamworks SDK integration, achievements, cloud saves (post-v1.0 candidates)
