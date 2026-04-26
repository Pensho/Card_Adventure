# Milestones — Card Adventure

**Last updated:** 2026-04-26

---

## M0 — Foundation *(complete)*
- [x] Godot project initialised
- [x] Git + GitHub set up
- [x] GDD complete enough to start M1
- [x] Folder structure created
- [x] GUT addon installed
- [x] CLAUDE.md written

## M1 — Core Loop Playable (no art) *(complete)*
- [x] One card can be played
- [x] Card has an effect on game state
- [x] One enemy with basic AI
- [x] Turn structure: player turn → enemy turn
- [x] Win/loss condition detected and shown
- [x] GUT tests covering card logic and turn flow

## M2 — First Full Run *(complete)*
- [x] Multiple encounter rooms
- [x] Equipment loot after encounters; equipping/unequipping rebuilds the deck
- [x] Equipment screen accessible at respite rooms
- [x] Dungeon junction navigation (unmarked descent: 2–3 passages, no pre-revealed map)
- [x] Persistent run state (autosave on room transition)
- [x] MainMenu with New Run / Continue; CharacterSelect; GameOver screens

## M3 — Full Party Combat *(complete)*
- [x] Both characters shown in HUD with individual HP and active state indicator (GDD §4, §9)
- [x] If a character is downed, their cards are removed from the deck for the rest of that fight (GDD §4)
- [x] Severed state: surviving character plays alone when ally is downed (GDD §4)
- [x] Multiple enemies per encounter; enemies act independently (GDD §8)
- [x] Targeting: player selects which enemy a card hits when multiple are present (TDD §20)
- [x] Core character states wired: Coiled, Wounded, Committed, Braced (GDD §4)
- [x] Performance generation: playing cards in sequence increments Performance; resets on end of turn (GDD §4 Jester)
- [x] Depth 1 Sentinel: flagged final encounter that triggers the victory condition on defeat (GDD §8)
- [x] Defeat clears save immediately so MainMenu never offers a broken Continue (TDD §11)

## M4 — Art Pass
- [ ] Card illustrations via leonardo.ai
- [ ] Character and enemy portraits
- [ ] UI styled
- [ ] Background art per depth
- [ ] Basic animations

## M5 — Polish & Balance
- [ ] Sound effects and music (AudioManager fully implemented)
- [ ] Balance pass on card tolls and effects
- [ ] Credits / end screen

## Backlog (unscheduled)
- Achievements
- Rattled and Severed state full implementation
- Revival items
- Merchant rooms
- Discovery rooms
- Multiple character classes beyond Lancer and Jester
- Online leaderboard
