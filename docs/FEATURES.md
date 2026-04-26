# Features — Card Adventure

This document is a registry of confirmed mechanics and ideas under active consideration. It sits between the GDD (design commitments) and the open questions section — anything confirmed here should also be reflected in the GDD before implementation begins.

**Status key:** `Planned` — committed, not yet built | `In Progress` — actively being implemented | `Done` — shipped

---

## Confirmed Mechanics

### Core Loop

| Feature | Status | Notes |
|---------|--------|-------|
| Gear-based deck building | Planned | Equip/unequip items = cards added/removed from shared deck immediately |
| Roguelike run structure | Planned | Death resets the run; roster unlocks persist across runs |
| Unmarked descent navigation | Planned | No map; environmental hints describe area character across several rooms, not just the immediate next room; hint reliability degrades with depth |
| 4 depths + final depth | Planned | Depth character shifts from near-normal to incoherent; Sentinel marks each threshold |
| Fluid room behaviour | Planned | No explicit room type labels; type discovered on entry; rooms can combine behaviours |

### Party System

| Feature | Status | Notes |
|---------|--------|-------|
| 2-character party, shared deck | Planned | Player chooses 2 from roster at run start |
| Individual character HP | Planned | Downed character's cards leave the deck for the remainder of that combat |
| Character states (emergent) | Planned | Coiled, Wounded, Committed, Braced, Rattled, Severed — arise from play, not choice |
| Revival system | Planned | Requires a revival item in an equipment slot; cost tier (Disabled/Damaged/Destroyed) baked into the item |
| Cursed revival interaction | Planned | Destroying a cursed revival item removes its curse cards — intentional escape valve |

### Roster

| Feature | Status | Notes |
|---------|--------|-------|
| Blood Mage | Planned | HP as toll; Wounded state synergy; power scales with self-damage |
| Plague Doctor | Planned | Diagnosis reveals enemy state/intent; wrong medicine procedures |
| Symbiote | Planned | Absorption slot; absorb enemy trait (positive card + curse card); 2-combat rejection lag on swap |
| Lancer | Planned | Momentum stacks; Committed state interaction; directional power |
| Jester | Planned | Performance stacks; sequence-based card upgrades; event manipulation |
| Roster unlock system | Planned | Three routes: Narrative, Merchant, Reputation |
| Starter pair: Lancer + Jester | Planned | Subject to change if narrative establishes a more natural default |

### Equipment

| Feature | Status | Notes |
|---------|--------|-------|
| Equipment slots (4 per character) | Planned | Weapon, Off-hand, Armour, Accessory — 8 active slots across the party |
| Symbiote Absorption slot | Planned | Extra slot, outside normal equipment system; combat-earned only |
| Equipment tiers | Planned | Standard, Cursed, Corrupted, Eldritch artefact |
| Curse cards | Planned | Negative cards from cursed/eldritch gear; removed by unequipping, respite actions, or merchant purge |

### Toll System

| Feature | Status | Notes |
|---------|--------|-------|
| Per-card toll costs (no energy counter) | Planned | HP, Exhaust, Discard, Wound, Momentum, Performance, State, Free |
| Combined tolls | Planned | A single card may demand multiple toll types simultaneously |
| No turn card limit | Planned | Play as many cards as tolls can be paid; resource exhaustion ends productive play naturally |

### Combat

| Feature | Status | Notes |
|---------|--------|-------|
| Draw → play → enemy intent turn structure | Planned | Hand size ~5 (tuning TBD) |
| Enemy intent icons | Planned | Atmospheric design, not clinical; communicates category and rough magnitude |
| Diagnosis (Plague Doctor) | Planned | Reveals hidden enemy state and intent beyond the base icon |

### Dungeon & Rooms

| Feature | Status | Notes |
|---------|--------|-------|
| Room types: Encounter, Respite, Merchant, Discovery, Empty | Planned | All discoverable on entry only |
| Lightweight narrative via discoveries and Sentinels | Planned | No meta-framing device; story delivered through events in the run |

---

## Under Consideration

Ideas that haven't been committed to. Each entry includes the appeal, the concern holding it back, and a decision gate — what would need to be true to commit or drop it.

---

### Revert toll system to conventional energy

**Appeal:** If the toll system produces confusion or balance problems that resist iteration, a conventional energy counter (as in Slay the Spire) is a proven fallback that players understand immediately.

**Concern:** Abandoning the toll system loses the primary mechanical differentiator — each class's resource feels completely distinct because tolls *are* the resource.

**Decision gate:** If playtesting reveals that new players cannot form correct mental models of available actions within 2–3 combats, or if balance tuning becomes intractable, revert. Otherwise keep.

**GDD note:** Explicitly acknowledged in GDD §6 as a design experiment.

---

### Persistent lore / bestiary between runs

**Appeal:** A bestiary or lore log that grows across runs rewards repeat play and deepens the world without affecting run balance. Fits the "dungeon that grew" tone — knowledge accumulates.

**Concern:** Adds scope. Requires UI, writing, and an unlock/discovery system. Risks feeling like padding if entries aren't genuinely interesting.

**Decision gate:** Scope this for post-v1.0 unless a natural implementation emerges from the discovery/event system already being built.

---

### Persistent story state between runs

**Appeal:** Story events and Sentinel encounters could leave permanent marks — a character you failed to save stays gone, a choice you made changes what appears in later runs.

**Concern:** Significant design and writing complexity. Could make the game feel unfair to new players or punishing in ways that don't serve the roguelike loop.

**Decision gate:** Only pursue if a specific, limited story beat makes it feel essential rather than systemic. Don't architect a full persistent state system speculatively.

**GDD note:** Listed as an open question in GDD §11.

---

### Expanded roster (beyond 5 characters)

**Appeal:** More classes = more run variety and more thematic space to explore.

**Concern:** Each class requires significant design work (secondary mechanic, equipment set, cursed interactions, narrative unlock). Scope risk.

**Decision gate:** Explicitly out of scope for v1.0. Revisit after v1.0 ships and the unlock system has been proven to work in practice.

---

### Multiple dungeons / biomes

**Appeal:** A second dungeon with different room logic and enemy aesthetics extends replayability significantly.

**Concern:** A major scope expansion. The current dungeon is deeply designed — a second one done poorly would undermine the first.

**Decision gate:** Explicitly out of scope for v1.0. Only revisit if v1.0 is complete and the dungeon generation system is designed to accommodate it cleanly.

---

### In-game contextual glossary / mechanic unlocking

**Appeal:** The current dev-only Glossary scene is a flat reference dump. Replacing it with contextual explanations that unlock as players encounter mechanics for the first time (first toll paid, first state triggered, first curse card drawn, etc.) would teach the game organically without a separate reference screen.

**Concern:** Requires a discovery/unlock tracking system and per-trigger copy for each mechanic. Significant scope for what is currently a dev convenience.

**Decision gate:** Design and scope after v1.0 ships and the discovery/event system is in place. The dev Glossary scene can be stripped from release builds or replaced at that point.

---

*Last updated: 2026-04-26*
