# Technical Design Document — Card Adventure

**Status:** Draft  
**Last updated:** 2026-04-22

---

## 1. Tech Stack

| Concern       | Choice                  |
|---------------|-------------------------|
| Engine        | Godot 4                 |
| Language      | GDScript                |
| Testing       | GUT (Godot Unit Testing) |
| Version control | Git + GitHub          |
| Art generation | leonardo.ai            |

## 2. Architecture Overview

> High-level description of how the game is structured.

## 3. Scene & Node Architecture

### Key Scenes
| Scene | Purpose |
|-------|---------|
| `game/Battle.tscn` | Main battle scene |
| `ui/HUD.tscn` | In-battle HUD |
| `cards/Card.tscn` | Individual card node |

### Ownership Rules
- Who owns game state? (e.g. a singleton `GameState` autoload)
- Who drives turns?

## 4. Data Architecture

- How are card definitions stored? (Resources, JSON, etc.)
- How is game state saved / loaded?

## 5. Signal Conventions

Use signals for:
- Cross-scene communication
- UI updates triggered by game logic

Do not use signals for:
- Calls within the same node/script

## 6. Autoloads / Singletons

| Name | Responsibility |
|------|---------------|
| `GameState` | Current run state, player stats |
| `CardDatabase` | All card definitions |

## 7. Testing Strategy

- Unit-test all card effect logic
- Unit-test game state transitions
- Do not test rendering or animations
- GUT test files mirror the `scripts/` structure under `tests/`

## 8. Performance Considerations

> To be filled in as the game grows.

## 9. Open Technical Questions

- [ ] Question 1
